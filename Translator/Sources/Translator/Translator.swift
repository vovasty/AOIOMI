//
//  File.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation

public protocol Dictionary {
    func translate(terms: Set<String>) throws -> Translator.TranslationResult
}

public final class Translator {
    public typealias Validator = (String) -> Bool
    public enum Error: Swift.Error {
        case wrongData, wrongPath
    }

    public struct TranslationResult: Equatable {
        let translated: [String: String]
        let missing: Set<String>

        init(translated: [String: String], missing: Set<String>) {
            self.translated = translated
            self.missing = missing
        }
    }

    private let dictionaries: [Dictionary]
    private let termExtractor: TermExtractor
    private let cache = CacheDictionary()
    private var blackList = Set<String>()

    public init(dictionaries: [Dictionary], skipKeys: Set<String>, validator: @escaping TermExtractor.Validator) throws {
        self.dictionaries = [cache] + dictionaries
        termExtractor = TermExtractor(skipKeys: skipKeys, validator: validator)
    }

    public func translate(json: String, path: [String]) throws -> String {
        guard let data = json.data(using: .utf8) else { throw Error.wrongData }
        let parsed = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let parsedPaths = path.map { $0.split(separator: ".").map(String.init) }
        let pathMatcher = PathMatcher(paths: parsedPaths)

        var missingTerms = termExtractor.extract(terms: parsed, pathMatcher: pathMatcher).subtracting(blackList)
        guard !missingTerms.isEmpty else { return json }

        var translatedTerms = [String: String]()
        var updateBlackList = true
        for dictionary in dictionaries {
            do {
                let result = try dictionary.translate(terms: missingTerms)
                translatedTerms.merge(result.translated) { current, _ in current }
                missingTerms = result.missing
                guard !missingTerms.isEmpty else { break }
            } catch {
                updateBlackList = false
            }
        }

        if updateBlackList {
            blackList.formUnion(missingTerms)
        }

        cache.append(translatedTerms)

        let translated = TermReplacer(pathMatcher: pathMatcher).replace(terms: translatedTerms, any: parsed)
        let encodedJSON = try JSONSerialization.data(withJSONObject: translated, options: .fragmentsAllowed)
        guard let resultString = String(data: encodedJSON, encoding: .utf8) else { throw Error.wrongData }
        return resultString
    }
}
