//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

struct CreateSimulatorCommand: Command {
    enum Error: Swift.Error {
        case invalidData
    }

    var executable: Executable = .helper
    let parameters: [String]?

    init(name: String, deviceType: SimctlList.DeviceType) {
        parameters = ["create", name, deviceType.name]
    }

    func parse(stdout: [String]) throws -> String {
        guard let udid = stdout.first, !udid.isEmpty else {
            throw Error.invalidData
        }

        return udid
    }
}
