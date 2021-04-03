//
//  File.swift
//
//
//  Created by vlsolome on 1/22/21.
//

import Foundation

public struct TermExtractor {
    public typealias Validator = (String) -> Bool
    let skipKeys: Set<String>
    let validator: Validator

    func extract(terms: Any, pathMatcher: PathMatcher) -> Set<String> {
        var result = Set<String>()
        extract(from: terms, path: [], pathMatcher: pathMatcher, result: &result)
        return result
    }

    private func extract(from any: Any, path: [String], pathMatcher: PathMatcher, result: inout Set<String>) {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return }

        if let dict = any as? [String: Any] {
            extract(from: dict, path: path, pathMatcher: pathMatcher, result: &result)
        } else if let array = any as? [Any] {
            extract(from: array, path: path, pathMatcher: pathMatcher, result: &result)
        } else if let string = any as? String, validator(string) {
            guard match == .match else { return }
            result.insert(string)
        }
    }

    private func extract(from dict: [String: Any], path: [String], pathMatcher: PathMatcher, result: inout Set<String>) {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return }

        for (key, value) in dict {
            guard !skipKeys.contains(key) else { continue }
            extract(from: value, path: path + [key], pathMatcher: pathMatcher, result: &result)
        }
    }

    private func extract(from array: [Any], path: [String], pathMatcher: PathMatcher, result: inout Set<String>) {
        let match = pathMatcher.match(path: path)
        guard match != .noMatch else { return }

        for (index, value) in array.enumerated() {
            extract(from: value, path: path + [String(index)], pathMatcher: pathMatcher, result: &result)
        }
    }
}
