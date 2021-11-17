//
//  Migration15.swift
//  AOIOMI
//
//  Created by vlsolome on 11/17/21.
//

import Foundation

struct Migration15: Migration {
    var version: Int = 15
    func migrate() throws {
        let paths = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".aoiomi"),
        ]

        for path in paths {
            try? FileManager.default.removeItem(at: path)
        }
    }
}
