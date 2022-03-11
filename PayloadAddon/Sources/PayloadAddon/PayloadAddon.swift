//
//  PayloadAddon.swift
//
//
//  Created by vlsolome on 4/5/21.
//

import Foundation
import MITMProxy

public struct PayloadAddon: Addon {
    public var sysPath: String?
    public let id = "PayloadAddon"
    public let importString = "from payloadaddon import PayloadAddon"
    private let payloads: [String: String]

    public init(payloads: [String: String]) {
        self.payloads = payloads
        sysPath = Bundle.module.url(forResource: "payloadaddon", withExtension: "")?.deletingLastPathComponent().path
    }

    public func constructor(dataDir: URL) -> String {
        let path = dataDir.appendingPathComponent("payloadaddon.json")
        let data = try! JSONEncoder().encode(payloads)
        try! data.write(to: path)

        return """
            PayloadAddon.PayloadAddon('\(path.path)')
        """
    }
}
