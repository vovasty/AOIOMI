//
//  ProxyPayload.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import Foundation
import KVStore

public struct ProxyPayload: StoreItem {
    public static func < (lhs: ProxyPayload, rhs: ProxyPayload) -> Bool {
        lhs.name > rhs.name
    }

    public var id = UUID()
    public var name = ""
    public var regex = ""
    public var isActive = false
    public var payload = ""

    public init(id: UUID, name: String, regex: String, isActive: Bool, payload: String) {
        self.id = id
        self.name = name
        self.regex = regex
        self.payload = payload
        self.isActive = isActive
    }

    public init() {}
}
