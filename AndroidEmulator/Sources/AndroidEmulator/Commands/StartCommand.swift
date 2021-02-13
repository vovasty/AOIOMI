//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct StartCommand: AsyncCommand {
    var executable: Executable = .helper
    let parameters: [String]? = ["start"]
}
