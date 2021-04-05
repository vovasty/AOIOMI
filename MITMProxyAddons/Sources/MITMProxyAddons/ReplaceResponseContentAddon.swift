//
//  File.swift
//
//
//  Created by vlsolome on 4/5/21.
//

import Foundation
import MITMProxy

public struct ReplaceResponseContentAddon: Addon {
    public var sysPath: String?
    public let id = "replaceResponseContentAddon"
    public let importString = "from replaceresponsecontentaddon import ReplaceResponseContentAddon"
    private let payloads: [String: String]

    public init(payloads: [String: String]) {
        self.payloads = payloads
        sysPath = Bundle.module.url(forResource: "python", withExtension: "")?.path
    }

    public func constructor(dataDir: URL) -> String {
        let path = dataDir.appendingPathComponent("replaceResponseContentAddon.json")
        let data = try! JSONEncoder().encode(payloads)
        try! data.write(to: path)

        return """
        ReplaceResponseContentAddon('\(path.path)')
        """
    }
}
