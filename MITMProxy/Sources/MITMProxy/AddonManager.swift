//
//  File.swift
//
//
//  Created by vlsolome on 4/3/21.
//

import Foundation

public class AddonManager {
    private var addons: [Addon] = []

    let scriptURL: URL

    init(scriptURL: URL) {
        self.scriptURL = scriptURL
    }

    public func set(addons: [Addon]) throws {
        self.addons = addons
        try writeScript()
    }

    func writeScript() throws {
        let script = makeScript()
        try script.data(using: .utf8)?.write(to: scriptURL, options: .atomicWrite)
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
            "\($0.id) = \($0.constructor)"
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
