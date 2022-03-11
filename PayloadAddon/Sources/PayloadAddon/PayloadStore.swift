//
//  PayloadStore.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Foundation
import KVStore
import MITMProxy

public final class PayloadStore: Store<Payload> {
    public convenience init(manager: Manager) throws {
        try self.init(database: try manager.database(name: "payloads"))
    }

    public var addon: Addon? {
        let payloads = items
            .filter(\.isActive)
            .reduce([String: String]()) { result, payload -> [String: String] in
                var result = result
                result[payload.regex] = payload.payload
                return result
            }

        return payloads.isEmpty ? nil : PayloadAddon(payloads: payloads)
    }

    public var isActive: Bool {
        items.contains { $0.isActive }
    }
}

#if DEBUG
    extension PayloadStore {
        static var preview: PayloadStore {
            let manager = try! Manager(data: URL(fileURLWithPath: "/tmp/test"))
            return try! PayloadStore(manager: manager)
        }
    }
#endif
