//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Foundation

enum AppContainerType {
    case app, data, groups, group(String)
}

extension AppContainerType {
    var rawValue: String {
        switch self {
        case .app:
            return "app"
        case .data:
            return "data"
        case .groups:
            return "groups"
        case let .group(id):
            return id
        }
    }
}
