//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import Foundation
import SwiftShell

public enum Executable {
    case helper
}

public protocol Command {
    associatedtype Result

    var parameters: [String]? { get }
    var executable: Executable { get }
    func parse(stdout: [String]) throws -> Result
}
