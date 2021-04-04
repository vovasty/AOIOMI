//
//  File.swift
//
//
//  Created by vlsolome on 4/1/21.
//

import Foundation
import MITMProxy

public struct AddRequestHeadersAddon: Addon {
    public var sysPath: String?
    public let id = "addRequestHeaderAddon"
    public let importString = "from addrequestheadersaddon import AddRequestHeadersAddon"
    public let constructor: String

    public init(headers: [String: String]) {
        let headersString = headers.map {
            "'\($0.key)': '\(String($0.value.filter { !"\n\r".contains($0) }))'"
        }
        .joined(separator: ",")
        constructor =
            """
            AddRequestHeadersAddon({\(headersString)})
            """
        sysPath = Bundle.module.url(forResource: "python", withExtension: "")?.path
    }
}
