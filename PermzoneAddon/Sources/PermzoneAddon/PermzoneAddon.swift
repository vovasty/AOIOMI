//
//  File.swift
//
//
//  Created by vlsolome on 4/1/21.
//

import Foundation
import MITMProxy

public struct PermzoneAddon: Addon {
    public var sysPath: String?
    public let id = "PermzoneAddon"
    public let importString = "from permzoneaddon import PermzoneAddon"
    private let constructorString: String

    public init(headers: [String: String]) {
        let headersString = headers.map {
            "'\($0.key)': '\(String($0.value.filter { !"\n\r".contains($0) }))'"
        }
        .joined(separator: ",")
        constructorString =
            """
                PermzoneAddon.PermzoneAddon({\(headersString)})
            """
        sysPath = Bundle.module.url(forResource: "permzoneaddon", withExtension: "")?.deletingLastPathComponent().path
    }

    public func constructor(dataDir _: URL) -> String {
        constructorString
    }
}
