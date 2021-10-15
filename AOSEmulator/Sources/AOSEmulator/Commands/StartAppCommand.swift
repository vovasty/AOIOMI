//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import CommandPublisher
import Foundation

struct StartAppCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?

    init(activityId: String) {
        parameters = ["run_app", activityId]
    }

    func parse(stdout _: String) throws {}
}
