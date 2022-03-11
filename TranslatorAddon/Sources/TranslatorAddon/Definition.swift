//
//  Definition.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import Foundation
import KVStore

public struct Definition: StoreItem {
    public init(id: UUID = UUID(), name: String, isActive: Bool = false, definition: TranslatorAddon.Definition) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.definition = definition
    }

    public static func < (lhs: Definition, rhs: Definition) -> Bool {
        lhs.name > rhs.name
    }

    public var id = UUID()
    public var name: String
    public var isActive: Bool = false
    public var definition: TranslatorAddon.Definition
}
