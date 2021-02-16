//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct InstallAPKCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(apk: URL) {
        parameters = ["install_apk", apk.path]
    }

    func parse(stdout _: [String]) throws {}
}
