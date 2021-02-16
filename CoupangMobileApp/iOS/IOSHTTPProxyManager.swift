//
//  HTTPProxyManager.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/13/21.
//

import Foundation
import HTTPProxyManager
import IOSSimulator

extension HTTPProxyManager {
    var iosDefaults: AppManager.Defaults? {
        guard let p = proxy(type: .ios) else { return nil }
        return AppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": p.host, "port": p.port])
    }
}
