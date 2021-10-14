//
//  PermZone.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Foundation

private struct PermZoneDefinition: Decodable {
    struct Host: Decodable {
        let host: String
        let port: String
    }

    let hosts: [String: Host]
}

struct PermZone: Hashable, Identifiable, Codable {
    enum ValidationError: Error {
        case emptyId, invalidBody
    }

    var id: String = ""
    var body: String = ""

    func validate() throws {
        guard !id.isEmpty else { throw ValidationError.emptyId }
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
