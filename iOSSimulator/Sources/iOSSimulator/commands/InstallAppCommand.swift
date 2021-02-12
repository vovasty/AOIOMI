//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

struct InstallAppCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(id: String, path: URL) {
        parameters = ["install", id, path.path]
    }

    func parse(stdout _: [String]) throws {}
}
