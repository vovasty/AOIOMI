//
//  File.swift
//
//
//  Created by vlsolome on 3/9/22.
//

import Foundation
import SwiftLMDB

public class Manager {
    private let environment: Environment

    public init(data: URL) throws {
        try? FileManager.default.createDirectory(at: data, withIntermediateDirectories: true, attributes: nil)
        environment = try Environment(path: data.path, flags: [], maxDBs: 8, maxReaders: 32, mapSize: 1024 * 1024 * 1024)
    }

    public func open<Value: Codable>(name: String) throws -> Store<Value> {
        let database = try environment.openDatabase(named: name, flags: [.create])
        return try Store<Value>(database: database)
    }

    public func database(name: String) throws -> Database {
        try environment.openDatabase(named: name, flags: [.create])
    }
}

#if DEBUG
    public extension Manager {
        static var preview: Manager = {
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("aoiomi")
            try! FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
            return try! Manager(data: tmp)
        }()
    }
#endif
