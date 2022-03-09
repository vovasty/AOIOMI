//
//  ProxyAddonManager.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Combine
import Foundation
import KVStore
import MITMProxy
import MITMProxyAddons
import TranslatorAddon

final class ProxyAddonManager: ObservableObject {
    private let userSettings: UserSettings
    private let payloads: PayloadStore
    private let permzones: PermzoneStore
    private let translator: TranslateStore
    private let mitmProxy: MITMProxy
    private var tokens = Set<AnyCancellable>()
    let objectWillChange = PassthroughSubject<Void, Never>()

    init(mitmProxy: MITMProxy, userSettings: UserSettings, payloads: PayloadStore, permzones: PermzoneStore, translator: TranslateStore) {
        self.payloads = payloads
        self.userSettings = userSettings
        self.mitmProxy = mitmProxy
        self.permzones = permzones
        self.translator = translator
        payloads.$items.sink { _ in
            DispatchQueue.main.async { [weak self] in
                try? self?.update()
            }
        }
        .store(in: &tokens)

        permzones.$activePermZone.sink { _ in
            DispatchQueue.main.async { [weak self] in
                try? self?.update()
            }
        }
        .store(in: &tokens)

        translator.$items.sink { _ in
            DispatchQueue.main.async { [weak self] in
                try? self?.update()
            }
        }
        .store(in: &tokens)

        translator.$isActive.sink { _ in
            DispatchQueue.main.async { [weak self] in
                try? self?.update()
            }
        }
        .store(in: &tokens)
    }

    func update() throws {
        let addons = makeAddons()
        try mitmProxy.addonManager.set(addons: addons)
    }

    private func makeAddons() -> [Addon] {
        [translator.addon, permzones.addon, payloads.addon].compactMap { $0 }
    }
}

#if DEBUG
    extension ProxyAddonManager {
        static var preview: ProxyAddonManager {
            let manager = try! Manager(data: URL(fileURLWithPath: "/tmp/test"))
            let userSettings = UserSettings()
            return try! ProxyAddonManager(mitmProxy: MITMProxy.preview,
                                          userSettings: userSettings,
                                          payloads: PayloadStore(manager: manager),
                                          permzones: PermzoneStore(manager: manager),
                                          translator: TranslateStore(manager: manager, userSettings: userSettings))
        }
    }
#endif
