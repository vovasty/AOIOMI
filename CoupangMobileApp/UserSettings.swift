//
//  UserSettings.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import MITMProxy
import UserDefaults

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("permZones", defaultValue: [])
    var permZones: [PermZone] {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("activePermZone", defaultValue: nil)
    var activePermZone: PermZone? {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyPort", defaultValue: 9999)
    var proxyPort: Int {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyAllowedHosts", defaultValue: ["cmapi.coupang.com"])
    var proxyAllowedHosts: [String] {
        willSet {
            objectWillChange.send()
        }
    }
}

extension UserSettings {
    var addons: [Addon] {
        if let activePermZone = activePermZone {
            return [AddRequestHeadersAddon(headers: activePermZone.headers)]
        } else {
            return []
        }
    }
}
