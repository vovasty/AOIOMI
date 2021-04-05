//
//  ProxyPayload.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import Foundation

struct ProxyPayload: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id
        case isChecked = "checked"
        case regex
        case payload
    }

    var id: String = ""
    var regex: String = ""
    var isChecked: Bool = false
    var payload: String = ""
}
