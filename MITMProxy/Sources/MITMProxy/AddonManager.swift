//
//  File.swift
//
//
//  Created by vlsolome on 4/3/21.
//

import Foundation

public class AddonManager {
    private var addons: [Addon] = []

    let script: URL
    let dataDir: URL

    init(script: URL, dataDir: URL) {
        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: false, attributes: nil)
        self.script = script
        self.dataDir = dataDir
    }

    public func set(addons: [Addon]) throws {
        self.addons = addons
        try writeScript()
    }

    func writeScript() throws {
        let script = makeScript()
        try script.data(using: .utf8)?.write(to: self.script, options: .atomicWrite)
    }

    private func makeScript() -> String {
        let sysString = addons.compactMap {
            if let sysPath = $0.sysPath {
                return "sys.path.append('\(sysPath)')"
            } else {
                return nil
            }
        }.joined(separator: "\n")

        let importString = addons.map(\.importString).joined(separator: "\n")

        let initString = addons.map {
            "\($0.id) = \($0.constructor(dataDir: dataDir))"
        }.joined(separator: "\n")

        let addonString = addons.map(\.id).joined(separator: ",")

        let script = """
        import sys
        \(sysString)
        \(importString)
        \(initString)
        addons = [\(addonString)]
        """
        return script
    }
}
