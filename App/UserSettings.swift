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
import MITMProxyAddons
import TranslatorAddon
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

    @UserDefault("translateDefinitions", defaultValue: [
        TranslatorDefinition(name: "Search Filter",
                             definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/152/v3/search-filter",
                                                                    paths: ["rData"])),
        TranslatorDefinition(name: "Recommended Keywords",
                             definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/26/recommended-keywords/list",
                                                                    paths: ["rData.freshTrendingKeywords.*.keywords.content", "rData.recommendedKeywords.*.content"])),
        TranslatorDefinition(name: "Hot Keywords",
                             definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/v3/hot-keywords",
                                                                    paths: ["rData.entityList.*.entity.links.*.nameAttr"])),
    ])
    var translateDefinitions: [TranslatorDefinition] {
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

    @UserDefault("payloads", defaultValue: [ProxyPayload]())
    var payloads: [ProxyPayload] {
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
            addons.append(TranslatorAddon(definitions: translateDefinitions.filter(\.isChecked).map(\.definition)))
        }

        if !payloads.isEmpty {
            let payloads = self.payloads.reduce([String: String]()) { result, payload -> [String: String] in
                var result = result
                result[payload.regex] = payload.payload
                return result
            }
            addons.append(ReplaceResponseContentAddon(payloads: payloads))
        }

        return addons
    }

    var iosDefaults: IOSAppManager.Defaults? {
        guard let iosProxy = iosProxy else { return nil }
        return IOSAppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": iosProxy.host, "port": iosProxy.port])
    }

    var isPayloadEnabled: Bool {
        !payloads.isEmpty
    }
}
