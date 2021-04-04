//
//  File.swift
//
//
//  Created by vlsolome on 4/3/21.
//

import Foundation

public protocol Addon {
    var id: String { get }
    var sysPath: String? { get }
    var importString: String { get }
    var constructor: String { get }
}
