//
//  OpenLinkCommand.swift
//
//
//  Created by vlsolome on 4/13/22.
//

import CommandPublisher
import Foundation

struct IOSOpenLinkCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(simulatorName: String, url: URL) {
        parameters = ["simulator", "openurl", simulatorName, url.absoluteString]
    }

    func parse(stdout _: String) throws {}
}
