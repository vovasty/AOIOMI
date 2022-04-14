//
//  AOSOpenLinkCommand.swift
//
//
//  Created by vlsolome on 4/13/22.
//

import CommandPublisher
import Foundation

struct AOSOpenLinkCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(url: URL) {
        parameters = ["adb", "shell", "am", "start", "-a", "android.intent.action.VIEW", "-d", url.absoluteString]
    }

    func parse(stdout _: String) throws {}
}
