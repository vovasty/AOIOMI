//
//  DefaultsKeys.swift
//
//
//  Created by vlsolome on 3/11/22.
//

import Foundation
import SwiftyUserDefaults

public extension DefaultsKeys {
    var proxyPort: DefaultsKey<Int> { .init("proxyPort", defaultValue: 9999) }
    var proxyGUIPort: DefaultsKey<Int> { .init("proxyGUIPort", defaultValue: 9998) }
    var proxyExternalPort: DefaultsKey<Int?> { .init("proxyExternalPort", defaultValue: 9000) }
    var proxyExternalHost: DefaultsKey<String?> { .init("proxyExternalHost", defaultValue: "127.0.0.1") }
    var proxyExternalEnabled: DefaultsKey<Bool> { .init("proxyExternalEnabled", defaultValue: false) }
    var proxyAllowedHosts: DefaultsKey<[String]> { .init("proxyAllowedHosts", defaultValue: []) }
}
