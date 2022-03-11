//
//  PermZone.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Foundation
import KVStore

private struct PermZoneDefinition: Decodable {
    struct Host: Decodable {
        let host: String
        let port: String
    }

    let hosts: [String: Host]
}

public struct PermZone: StoreItem, Hashable {
    public static func < (lhs: PermZone, rhs: PermZone) -> Bool {
        lhs.name > rhs.name
    }

    enum ValidationError: Error {
        case emptyId, invalidBody
    }

    public var id = UUID()
    public var name = ""
    public var body = ""
    public var isActive = false

    public init(id: UUID, name: String, body: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.body = body
        self.isActive = isActive
    }

    public init() {}

    func validate() throws {
        guard !name.isEmpty else { throw ValidationError.emptyId }
        guard let data = body.data(using: .utf8) else { throw ValidationError.invalidBody }
        _ = try JSONDecoder().decode(PermZoneDefinition.self, from: data)
    }

    var headers: [String: String] {
        ["X-Manual-Override": body]
    }
}

extension PermZone.ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidBody: return "Body is invalid"
        case .emptyId: return "Id is invalid"
        }
    }
}
