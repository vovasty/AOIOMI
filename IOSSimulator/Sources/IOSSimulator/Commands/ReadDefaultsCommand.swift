//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import CommandPublisher
import Foundation

struct ReadDefaultsCommand: Command {
    enum Error: Swift.Error {
        case noContainer, wrongFormat
    }

    var executable: Executable = .helper
    let parameters: [String]?
    private let bundleId: String

    init(id: String, bundleId: String) {
        parameters = ["get_app_container", id, bundleId, AppContainerType.data.rawValue]
        self.bundleId = bundleId
    }

    func parse(stdout: [String]) throws -> Any? {
        guard let appPath = stdout.first else { throw Error.noContainer }

        let defaultsFile = URL(fileURLWithPath: appPath)
            .appendingPathComponent("Library")
            .appendingPathComponent("Preferences")
            .appendingPathComponent("\(bundleId).plist")
        do {
            let data = try Data(contentsOf: defaultsFile)

            return try PropertyListSerialization.propertyList(from: data,
                                                              options: .mutableContainersAndLeaves,
                                                              format: nil)
        } catch {
            return nil
        }
    }
}
