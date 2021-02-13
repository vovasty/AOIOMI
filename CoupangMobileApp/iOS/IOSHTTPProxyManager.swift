//
//  HTTPProxyManager.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/13/21.
//

import Foundation
import HTTPProxyManager
import iOSSimulator

extension HTTPProxyManager {
    var iosDefaults: AppManager.Defaults {
        let p = proxy(type: .ios)
        return AppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": p.host, "port": p.port])
    }
}
