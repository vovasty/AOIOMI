//
//  AddonManager.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Combine
import Foundation
import MITMProxy
import PayloadAddon
import PermzoneAddon
import TranslatorAddon

final class AddonManager: ObservableObject {
    private let payloads: PayloadStore
    private let permzones: PermzoneStore
    private let translator: TranslatorStore
    private let mitmProxy: MITMProxy
    private var tokens = Set<AnyCancellable>()
    let objectWillChange = PassthroughSubject<Void, Never>()

    init(mitmProxy: MITMProxy, payloads: PayloadStore, permzones: PermzoneStore, translator: TranslatorStore) {
        self.payloads = payloads
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
