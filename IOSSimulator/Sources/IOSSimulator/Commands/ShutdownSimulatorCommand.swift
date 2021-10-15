//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import CommandPublisher
import Foundation

struct ShutdownSimulatorCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(id: String) {
        parameters = ["stop", id]
    }

    func parse(stdout _: String) throws {}
}
