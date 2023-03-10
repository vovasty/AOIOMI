//
//  TranslatorStore.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Combine
import Foundation
import KVStore
import MITMProxy
import SwiftyUserDefaults

public final class TranslatorStore: Store<Definition> {
    @Published public var isActive: Bool
    public var addon: Addon? {
        guard isActive else { return nil }
        let definitions = items.filter(\.isActive).map(\.definition)
        guard !definitions.isEmpty else { return nil }
        return TranslatorAddon(definitions: definitions)
    }

    private var sub: AnyCancellable?

    public init(manager: Manager) throws {
        isActive = Defaults.isTranslationActive
        try super.init(database: try manager.database(name: "translator"))
        if items.isEmpty {
            items = defaults
        }
        sub = $isActive.sink {
            Defaults.isTranslationActive = $0
        }
    }

    private var defaults: [Definition] {
        [
            Definition(name: "Search Filter",
                       definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/152/v3/search-filter",
                                                              paths: ["rData"])),
            Definition(name: "Recommended Keywords",
                       definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/modular/v1/endpoints/26/recommended-keywords/list",
                                                              paths: ["rData.freshTrendingKeywords.*.keywords.content", "rData.recommendedKeywords.*.content"])),
            Definition(name: "Hot Keywords",
                       definition: TranslatorAddon.Definition(url: "https://cmapi.coupang.com/v3/hot-keywords",
                                                              paths: ["rData.entityList.*.entity.links.*.nameAttr"])),
        ]
    }
}
