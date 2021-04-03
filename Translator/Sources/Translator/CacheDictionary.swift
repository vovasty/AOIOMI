//
//  CacheDictionary.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation

class CacheDictionary {
    private var cache = [String: String]()

    init() {}

    func append(_ dict: [String: String]) {
        cache.merge(dict) { current, _ in current }
    }
}

extension CacheDictionary: Dictionary {
    func translate(terms: Set<String>) throws -> Translator.TranslationResult {
        var translated = [String: String]()
        var missing = Set<String>()
        for term in terms {
            guard let translatedTerm = cache[term] else {
                missing.insert(term)
                continue
            }
            translated[term] = translatedTerm
        }

        return Translator.TranslationResult(translated: translated, missing: missing)
    }
}
