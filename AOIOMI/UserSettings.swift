//
//  UserSettings.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import HTTPProxyManager
import IOSSimulator
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

    @UserDefault("proxyGUIPort", defaultValue: 9998)
    var proxyGUIPort: Int {
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

    @UserDefault("translateDefinitions", defaultValue: [
        TranslateDefinition(name: "Search Filter",
                            definition: TranslateAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/152/v3/search-filter",
                                                                  paths: ["rData"])),
        TranslateDefinition(name: "Recommended Keywords",
                            definition: TranslateAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/26/recommended-keywords/list",
                                                                  paths: ["rData.freshTrendingKeywords.*.keywords.content", "rData.recommendedKeywords.*.content"])),
        TranslateDefinition(name: "Hot Keywords",
                            definition: TranslateAddon.Definition(url: "https://cmapi.coupang.com/v3/hot-keywords",
                                                                  paths: ["rData.entityList.*.entity.links.*.nameAttr"])),
    ])
    var translateDefinitions: [TranslateDefinition] {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("isTranslating", defaultValue: false)
    var isTranslating: Bool {
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
    var addons: [Addon] {
        var addons = [Addon]()
        if let activePermZone = activePermZone {
            addons.append(AddRequestHeadersAddon(headers: activePermZone.headers))
        }

        if isTranslating {
            addons.append(TranslateAddon(definitions: translateDefinitions.filter(\.isChecked).map(\.definition)))
        }

        return addons
    }

    var iosDefaults: IOSAppManager.Defaults? {
        guard let iosProxy = iosProxy else { return nil }
        return IOSAppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": iosProxy.host, "port": iosProxy.port])
    }
}
