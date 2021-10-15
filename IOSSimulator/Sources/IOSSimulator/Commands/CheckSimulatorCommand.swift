//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import CommandPublisher
import Foundation

struct CheckSimulatorCommand: Command {
    enum Error: Swift.Error {
        case invalidData
    }

    var executable: Executable = .helper
    let parameters: [String]?
    private let id: String

    init(id: String) {
        self.id = id
        parameters = ["list"]
    }

    func parse(stdout: String) throws -> SimctlList.DeviceState {
        guard let data = stdout.data(using: .utf8) else {
            throw Error.invalidData
        }
        let result = try JSONDecoder().decode(SimctlList.self, from: data)

        for devices in result.devices {
            guard let device = devices.value.first(where: { $0.name == id }) else { continue }
            return device.state
        }
        return .notCreated
    }
}
