//
//  TranslateDefinition.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import Foundation
import MITMProxy

struct TranslateDefinition: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case isChecked = "checked"
        case definition
    }

    let name: String
    var isChecked: Bool = false
    let definition: TranslateAddon.Definition
}

extension TranslateDefinition: Identifiable {
    var id: String {
        name
    }
}
