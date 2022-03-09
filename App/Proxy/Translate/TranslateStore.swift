//
//  TranslateStore.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Combine
import Foundation
import KVStore
import MITMProxy
import TranslatorAddon

final class TranslateStore: Store<TranslateDefinition> {
    let userSettings: UserSettings
    let objectWillChange = PassthroughSubject<Void, Never>()
    @Published var isActive: Bool
    var addon: Addon? {
        guard isActive else { return nil }
        let definitions = items.filter(\.isActive).map(\.definition)
        guard !definitions.isEmpty else { return nil }
        return TranslatorAddon(definitions: definitions)
    }

    private var sub: AnyCancellable?

    init(manager: Manager, userSettings: UserSettings) throws {
        self.userSettings = userSettings
        isActive = userSettings.isTranslationActive
        try super.init(database: try manager.database(name: "translator"))
        if items.isEmpty {
            items = defaults
        }
        sub = $isActive.sink { value in
            userSettings.isTranslationActive = value
        }
    }

    private var defaults: [TranslateDefinition] {
        [
            TranslateDefinition(name: "Search Filter",
                                definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/152/v3/search-filter",
                                                                       paths: ["rData"])),
            TranslateDefinition(name: "Recommended Keywords",
                                definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/26/recommended-keywords/list",
                                                                       paths: ["rData.freshTrendingKeywords.*.keywords.content", "rData.recommendedKeywords.*.content"])),
            TranslateDefinition(name: "Hot Keywords",
                                definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/v3/hot-keywords",
                                                                       paths: ["rData.entityList.*.entity.links.*.nameAttr"])),
        ]
    }
}
