//
//  UserSettings.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import HTTPProxyManager
import IOSSimulator
import MITMProxy
import TranslatorAddon
import UserDefaults

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    @UserDefault("proxyPort", defaultValue: 9999)
    var proxyPort: Int {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyGUIPort", defaultValue: 9998)
    var proxyGUIPort: Int {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyAllowedHosts", defaultValue: [])
    var proxyAllowedHosts: [String] {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyExternalPort", defaultValue: 9000)
    var proxyExternalPort: Int? {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyExternalHost", defaultValue: "127.0.0.1")
    var proxyExternalHost: String? {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("proxyExternalEnabled", defaultValue: false)
    var proxyExternalEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("iosProxy", defaultValue: nil)
    var iosProxy: HTTPProxyManager.Proxy? {
        willSet {
            objectWillChange.send()
        }
    }
}

extension UserSettings {
    var iosDefaults: IOSAppManager.Defaults? {
        guard let iosProxy = iosProxy else { return nil }
        return IOSAppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": iosProxy.host, "port": iosProxy.port])
    }
}
