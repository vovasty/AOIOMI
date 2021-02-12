//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

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

    func parse(output: [String]) throws -> SimctlList.DeviceState {
        guard let data = output.joined(separator: "\n").data(using: .utf8) else {
            throw Error.invalidData
        }
        let result = try JSONDecoder().decode(SimctlList.self, from: data)
        if let device = result.devices.values.first(where: { $0.first(where: { $0.udid == id }) != nil })?.first {
            return device.state
        } else {
            return .notCreated
        }
    }
}
