//
//  DefaultsKeys.swift
//
//
//  Created by vlsolome on 3/11/22.
//

import Foundation
import SwiftyUserDefaults

public extension DefaultsKeys {
    var isTranslationActive: DefaultsKey<Bool> { .init("isTranslationActive", defaultValue: false) }
}
