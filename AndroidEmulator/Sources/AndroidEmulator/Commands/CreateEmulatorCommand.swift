//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct CreateEmulatorCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(proxy: String, caPath: URL) {
        parameters = ["create", proxy, caPath.path]
    }

    func parse(stdout _: [String]) throws {}
}
