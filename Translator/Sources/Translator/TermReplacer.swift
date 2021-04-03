//
//  File.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation

struct TermReplacer {
    let pathMatcher: PathMatcher

    func replace(terms: [String: String], path: [String] = [], any: Any) -> Any {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return any }

        if let dict = any as? [String: Any] {
            return replace(terms: terms, path: path, dict: dict)
        } else if let array = any as? [Any] {
            return replace(terms: terms, path: path, pathMatcher: pathMatcher, array: array)
        } else if let string = any as? String {
            guard match == .match else { return any }
            return terms[string] ?? string
        }

        return any
    }

    private func replace(terms: [String: String], path: [String], dict: [String: Any]) -> [String: Any] {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return dict }

        var result = [String: Any]()
        for (key, value) in dict {
            result[key] = replace(terms: terms, path: path + [key], any: value)
        }

        return result
    }

    private func replace(terms: [String: String], path: [String], pathMatcher: PathMatcher, array: [Any]) -> [Any] {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return array }

        return array.enumerated().map { replace(terms: terms, path: path + [String($0)], any: $1) }
    }
}
