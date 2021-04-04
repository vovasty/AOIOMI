//
//  TranslateDefinition.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import Foundation
import MITMProxy
import TranslatorAddon

struct TranslatorDefinition: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case isChecked = "checked"
        case definition
    }

    let name: String
    var isChecked: Bool = false
    let definition: TranslatorAddon.Definition
}

extension TranslatorDefinition: Identifiable {
    var id: String {
        name
    }
}
