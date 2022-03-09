//
//  PayloadStore.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Foundation
import KVStore
import MITMProxyAddons
import MITMProxy

final class PayloadStore: Store<ProxyPayload> {
    convenience init(manager: Manager) throws {
        try self.init(database: try manager.database(name: "payloads"))
    }

    var addon: Addon? {
        let payloads = items
            .filter(\.isActive)
            .reduce([String: String]()) { result, payload -> [String: String] in
                var result = result
                result[payload.regex] = payload.payload
                return result
            }

        return payloads.isEmpty ? nil : ReplaceResponseContentAddon(payloads: payloads)
    }

    var isActive: Bool {
        items.contains { $0.isActive }
    }
}
