//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct IsCreatedCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]? = ["is_created"]
    func parse(stdout _: [String]) throws {
        ()
    }
}
