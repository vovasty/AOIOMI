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
    public var name: String = ""
    public var regex: String = ""
    public var isActive: Bool = false
    public var payload: String = ""

    public init(id _: UUID, name: String, regex: String, isActive _: Bool, payload: String) {
        self.name = name
        self.regex = regex
        self.payload = payload
    }

    public init() {}
}
