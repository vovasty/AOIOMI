//
//  Migration18.swift
//  AOIOMI
//
//  Created by vlsolome on 3/10/22.
//

import Foundation
import PayloadAddon
import PermzoneAddon
import TranslatorAddon

struct Migration18: Migration {
    var version: Int = 18
    private let df = UserDefaults.standard
    let transtatorStore: TranslateStore
    let payloadStore: PayloadStore
    let permzoneStore: PermzoneStore

    func migrate() throws {
        migratePayloads()
        migratePermzones()
        cleanupTranslateDefinitions()
        cleanupPayloads()
        cleanupPermzones()
    }

    private func cleanupTranslateDefinitions() {
        df.removeObject(forKey: "translateDefinitions")
        df.removeObject(forKey: "isTranslating")
    }

    private func migratePayloads() {
        guard let entries = getJSON(key: "payloads") as? [[String: Any]] else { return }
        let payloads: [ProxyPayload] = entries.compactMap { entry in
            guard let name = entry["id"] as? String else { return nil }
            guard let regex = entry["regex"] as? String else { return nil }
            guard let isChecked = entry["checked"] as? Bool else { return nil }
            guard let payload = entry["payload"] as? String else { return nil }
            return ProxyPayload(id: UUID(),
                                name: name,
                                regex: regex,
                                isActive: isChecked,
                                payload: payload)
        }
        payloadStore.items = payloads
    }

    private func cleanupPayloads() {
        df.removeObject(forKey: "payloads")
    }

    private func migratePermzones() {
        guard let entries = getJSON(key: "permZones") as? [[String: Any]] else { return }
        func parsePermzone(_ entry: [String: Any]) -> PermZone? {
            guard let name = entry["id"] as? String else { return nil }
            guard let body = entry["body"] as? String else { return nil }
            return PermZone(id: UUID(),
                            name: name,
                            body: body,
                            isActive: false)
        }

        let payloads: [PermZone] = entries.compactMap(parsePermzone)
        permzoneStore.items = payloads
    }

    private func cleanupPermzones() {
        df.removeObject(forKey: "activePermZone")
        df.removeObject(forKey: "permZones")
    }

    private func getJSON(key: String) -> Any? {
        guard let value = df.object(forKey: key) as? Data else { return nil }
        return try? JSONSerialization.jsonObject(with: value, options: .fragmentsAllowed)
    }
}
