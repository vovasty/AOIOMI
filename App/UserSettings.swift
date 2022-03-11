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
