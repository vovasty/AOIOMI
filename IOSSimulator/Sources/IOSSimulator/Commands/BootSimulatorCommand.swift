//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import CommandPublisher
import Foundation

struct BootSimulatorCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(id: String) {
        parameters = ["start", id]
    }

    func parse(stdout _: String) throws {}
}
