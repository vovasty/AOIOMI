//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

struct GetAppContainerPathCommand: Command {
    enum Error: Swift.Error {
        case noContainer
    }

    enum ContainerType {
        case app, data, groups, group(String)
    }

    var executable: Executable = .helper
    let parameters: [String]?

    init(id: String, bundleId: String, type: ContainerType) {
        parameters = ["get_app_container", id, bundleId, type.asString]
    }

    func parse(stdout: [String]) throws -> URL {
        guard let path = stdout.first else { throw Error.noContainer }
        return URL(fileURLWithPath: path)
    }
}

extension GetAppContainerPathCommand.ContainerType {
    var asString: String {
        switch self {
        case .app:
            return "app"
        case .data:
            return "data"
        case .groups:
            return "groups"
        case let .group(id):
            return id
        }
    }
}
