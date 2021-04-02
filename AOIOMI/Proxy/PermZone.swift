//
//  PermZone.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import Foundation

struct PermZone: Hashable, Identifiable, Codable {
    var id: String = ""
    var body: String = ""

    var isValid: Bool {
        !body.isEmpty && !id.isEmpty
    }

    var headers: [String: String] {
        ["X-Manual-Override": body]
    }
}
