//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct GetEmulatorPIDCommand: Command {
    enum Error: Swift.Error {
        case noPID
    }

    var executable: Executable = .helper
    let parameters: [String]? = ["get_emulator_pid"]
    func parse(stdout: String) throws -> Int {
        guard let pid = Int(stdout.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw Error.noPID }
        return pid
    }
}
