//
//  IOSAppManager.swift
//  AOIOMI
//
//  Created by vlsolome on 3/11/22.
//

import Foundation
import IOSSimulator
import SwiftyUserDefaults

extension IOSAppManager {
    var iosDefaults: IOSAppManager.Defaults? {
        guard let host = SwiftyUserDefaults.Defaults.iosProxyHost else { return nil }
        guard let port = SwiftyUserDefaults.Defaults.iosProxyPort else { return nil }
        return IOSAppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": host, "port": port])
    }
}
