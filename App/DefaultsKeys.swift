//
//  DefaultsKeys.swift
//  AOIOMI
//
//  Created by vlsolome on 3/11/22.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var iosProxyHost: DefaultsKey<String?> { .init("iosProxyHost") }
    var iosProxyPort: DefaultsKey<Int?> { .init("iosProxyPort") }
}
