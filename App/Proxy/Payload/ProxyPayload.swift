//
//  ProxyPayload.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import Foundation
import KVStore

struct ProxyPayload: StoreItem {
    static func < (lhs: ProxyPayload, rhs: ProxyPayload) -> Bool {
        lhs.name > rhs.name
    }

    var id = UUID()
    var name: String = ""
    var regex: String = ""
    var isActive: Bool = false
    var payload: String = ""
}
