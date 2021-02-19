//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import CommandPublisher
import Foundation

struct RunAppCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(id: String, bundleId: String) {
        parameters = ["run_app", id, bundleId]
    }

    func parse(stdout _: [String]) throws {}
}
