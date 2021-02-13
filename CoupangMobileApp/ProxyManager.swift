//
//  ProxyManager.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/12/21.
//

import Combine
import Foundation

class ProxyManager: ObservableObject {
    let caPath = FileManager.default.urls(for: .applicationSupportDirectory,
                                          in: .userDomainMask)
        .first!
        .appendingPathComponent("Charles")
        .appendingPathComponent("ca")
        .appendingPathComponent("charles-proxy-ssl-proxying-certificate.pem")
    let proxy = "10.0.2.2:8888"
}
