//
//  main.swift
//  macdict
//
//  Created by Jak Wings on 2014-10-26.
//
//

import AppKit
import CoreServices
import Foundation
import PrivateAPI
import SwiftSoup

public class MacDictionary {
    private let dictionary: DCSDictionary
    enum Error: Swift.Error {
        case noDictionary
    }

    public init(name: String) throws {
        let availableDictionaries: NSArray = DCSCopyAvailableDictionaries().takeUnretainedValue()
        let result = availableDictionaries.first {
            let dict = $0 as! DCSDictionary
            let dictName: String = DCSDictionaryGetName(dict).takeUnretainedValue() as String
            return dictName == name
        }

        guard result != nil else { throw Error.noDictionary }

        let res = result as! DCSDictionary
        dictionary = res
    }

    func lookUp(string: String) throws -> [String]? {
        let range: CFRange = DCSGetTermRangeInString(dictionary, string as CFString, 0)

        guard range.location != kCFNotFound else { return nil }

        let term = String(string[string.index(string.startIndex, offsetBy: range.location) ..< string.index(string.startIndex, offsetBy: range.location + range.length)])

        guard let records = DCSCopyRecordsForSearchString(dictionary, term as CFString, nil, nil)?.takeUnretainedValue() as NSArray? else { return nil }

        let result = try records.compactMap { record -> [String]? in
            guard let html = DCSRecordCopyData(record as CFTypeRef).takeUnretainedValue() as String? else { return nil }
            let doc = try SwiftSoup.parse(html)
            let trans = try doc.select("span[class=trans]")
            return try trans.map { try $0.text() }
        }
        .flatMap { $0 }

        guard !result.isEmpty else { return nil }
        return result
    }
}

extension MacDictionary: Dictionary {
    public func translate(terms: Set<String>) throws -> Translator.TranslationResult {
        var translated = [String: String]()
        var missing = Set<String>()
        for term in terms {
            guard let translatedTerm = try lookUp(string: term)?.first else {
                missing.insert(term)
                continue
            }
            translated[term] = translatedTerm
        }

        return Translator.TranslationResult(translated: translated, missing: missing)
    }
}
