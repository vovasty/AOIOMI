//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import CommandPublisher
import Foundation

struct CreateSimulatorCommand: Command {
    enum Error: Swift.Error {
        case invalidData
    }

    var executable: Executable = .helper
    let parameters: [String]?

    init(name: String, deviceType: SimctlList.DeviceType, caURL: [URL]?) {
        parameters = ["create", name, deviceType.name].compactMap { $0 == nil ? "none" : $0 } + (caURL?.map(\.path) ?? [])
    }

    init(id: String, caURL: URL) {
        parameters = ["install_ca", id, caURL.path]
    }

    func parse(stdout: [String]) throws -> String {
        let udid = stdout.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !udid.isEmpty else {
            throw Error.invalidData
        }

        return udid
    }
}
