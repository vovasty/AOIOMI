//
//  HTTPProxyManager.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/13/21.
//

import HTTPProxyManager

extension HTTPProxyManager.Proxy {
    var asString: String {
        "\(host):\(port)"
    }
}
