//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import CommandPublisher
import Foundation

struct WriteDefaultsCommand: Command {
    enum Error: Swift.Error {
        case noContainer, wrongFormat
    }

    var executable: Executable = .helper
    let parameters: [String]?
    private let bundleId: String
    private let defaults: AppManager.Defaults

    init(id: String, bundleId: String, defaults: AppManager.Defaults) {
        parameters = ["get_app_container", id, bundleId, AppContainerType.data.rawValue]
        self.bundleId = bundleId
        self.defaults = defaults
    }

    func parse(stdout: [String]) throws {
        guard let appPath = stdout.first else { throw Error.noContainer }

        let defaultsFile = URL(fileURLWithPath: appPath)
            .appendingPathComponent("Library")
            .appendingPathComponent("Preferences")
            .appendingPathComponent("\(bundleId).plist")
        try write(defaults: defaults, path: defaultsFile)
    }
}

private func write(defaults: AppManager.Defaults, path: URL) throws {
    var defaultsDict: [AnyHashable: Any]
    if FileManager.default.isReadableFile(atPath: path.path) {
        let inputData = try Data(contentsOf: path)
        guard let dict = try PropertyListSerialization.propertyList(from: inputData,
                                                                    options: .mutableContainersAndLeaves,
                                                                    format: nil) as? [AnyHashable: Any]
        else {
            throw WriteDefaultsCommand.Error.wrongFormat
        }
        defaultsDict = dict
    } else {
        defaultsDict = [:]
    }

    update(dictionary: &defaultsDict, at: defaults.path, with: defaults.data)
    let ouputData = try PropertyListSerialization.data(fromPropertyList: defaultsDict, format: .xml, options: 0)
    try ouputData.write(to: path)
}

// https://stackoverflow.com/a/55284347
private func update(dictionary dict: inout [AnyHashable: Any], at keys: [AnyHashable], with value: Any) {
    if keys.count < 2 {
        for key in keys { dict[key] = value }
        return
    }

    var levels: [[AnyHashable: Any]] = []

    for key in keys.dropLast() {
        if let lastLevel = levels.last {
            if let currentLevel = lastLevel[key] as? [AnyHashable: Any] {
                levels.append(currentLevel)
            } else if lastLevel[key] != nil, levels.count + 1 != keys.count {
                break
            } else { return }
        } else {
            if let firstLevel = dict[keys[0]] as? [AnyHashable: Any] {
                levels.append(firstLevel)
            } else { return }
        }
    }

    if levels[levels.indices.last!][keys.last!] != nil {
        levels[levels.indices.last!][keys.last!] = value
    } else { return }

    for index in levels.indices.dropLast().reversed() {
        levels[index][keys[index + 1]] = levels[index + 1]
    }

    dict[keys[0]] = levels[0]
}
