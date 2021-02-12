//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

struct ListDeviceTypesCommand: Command {
    enum Error: Swift.Error {
        case invalidData
    }

    var executable: Executable = .helper
    let parameters: [String]?

    init() {
        parameters = ["list"]
    }

    func parse(stdout: [String]) throws -> [SimctlList.DeviceType] {
        guard let data = stdout.joined(separator: "\n").data(using: .utf8) else {
            throw Error.invalidData
        }

        do {
            let result = try JSONDecoder().decode(SimctlList.self, from: data)
            return result.devicetypes
        } catch {
            throw error
        }
    }
}
