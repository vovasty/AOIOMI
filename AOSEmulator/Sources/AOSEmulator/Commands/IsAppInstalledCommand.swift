//
//  StartEmulatorCommand.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct IsAppInstalledCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(packageId: String) {
        parameters = ["is_app_installed", packageId]
    }

    func parse(stdout _: String) throws {}
}
