//
//  PathMatcher.swift
//
//
//  Created by vlsolome on 2/7/21.
//

import Foundation

struct PathMatcher {
    enum Match {
        case lesser, match, noMatch
    }

    let paths: [[String]]

    func match(path: [String]) -> Match {
        for p in paths {
            let result = match(path: p, matchingPath: path)
            guard result == .noMatch else { return result }
        }

        return .noMatch
    }

    private func match(path: [String], matchingPath: [String]) -> Match {
        let count = min(path.count, matchingPath.count)
        for i in 0 ..< count {
            guard path[i] == "*" || path[i] == matchingPath[i] else { return .noMatch }
        }

        if path.count == 1, path.first == "*", matchingPath.isEmpty {
            return .match
        }

        return path.count <= matchingPath.count ? .match : .lesser
    }
}
