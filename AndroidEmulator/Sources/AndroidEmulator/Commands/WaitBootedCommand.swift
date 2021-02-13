//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct WaitBootedCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]? = ["wait_booted"]
    func parse(stdout _: [String]) throws {}
}
