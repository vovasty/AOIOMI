//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

enum Executable {
    case helper
}

protocol Command {
    associatedtype Result

    var parameters: [String]? { get }
    var executable: Executable { get }
    func parse(output: [String]) throws -> Result
}
