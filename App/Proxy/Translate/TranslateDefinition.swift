//
//  TranslateDefinition.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import Foundation
import KVStore
import TranslatorAddon

struct TranslateDefinition: StoreItem {
    static func < (lhs: TranslateDefinition, rhs: TranslateDefinition) -> Bool {
        lhs.name > rhs.name
    }

    var id = UUID()
    var name: String
    var isActive: Bool = false
    var definition: TranslatorAddon.Definition
}
