//
//  File.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Combine
import Foundation

private struct GoogleResponse: Decodable {
    struct Translation: Decodable {
        let trans: String
        let orig: String
    }

    let sentences: [Translation]
}

private func stopRunloop() {
    DispatchQueue.main.async {
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
}

public class GoogleDictionary {
    private let fromLanguage: String
    private let toLanguage: String
    private var token: AnyCancellable?

    public init(fromLanguage: String, toLanguage: String) {
        self.fromLanguage = fromLanguage
        self.toLanguage = toLanguage
    }

    enum Error: Swift.Error {
        case badResponse
    }

    func lookup(terms: [String]) throws -> [String: String] {
        guard let query = terms
            .joined(separator: "#\n")
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        else {
            return [:]
        }

        let urlString = "https://translate.googleapis.com/translate_a/single?dt=t&dt=ss&client=gtx&dj=1&ie=UTF-8&oe=UTF-8&sl=\(fromLanguage)&tl=\(toLanguage)&q=\(query)"
        let url = URL(string: urlString)!

        var response: GoogleResponse?

        token = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GoogleResponse.self,
                    decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in // 2
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
                stopRunloop()
            }) { resp in
                response = resp
            }

        CFRunLoopRun()
        guard let sentences = response?.sentences else { throw Error.badResponse }

        var result = [String: String]()
        let trans = sentences.reduce("") { $0 + $1.trans }
        let orig = sentences.reduce("") { $0 + $1.orig }
        let translated = trans.split(separator: "#").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let original = orig.split(separator: "#").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard translated.count == original.count else {
//            try orig.write(to: URL(fileURLWithPath: "/Users/vlsolome/Documents/dict/orig.txt"), atomically: true, encoding: .utf8)
//            try trans.write(to: URL(fileURLWithPath: "/Users/vlsolome/Documents/dict/trans.txt"), atomically: true, encoding: .utf8)
            throw Error.badResponse
        }
        for (index, term) in original.enumerated() {
            result[term] = translated[index]
        }

        return result
    }
}

extension GoogleDictionary: Dictionary {
    public func translate(terms: Set<String>) throws -> Translator.TranslationResult {
        var translated = [String: String]()
        var missing = Set<String>()

        let result = try lookup(terms: Array(terms))

        for (term, trans) in result {
            if term == trans {
                missing.insert(term)
            } else {
                translated[term] = trans
            }
        }

        return Translator.TranslationResult(translated: translated, missing: missing)
    }
}
