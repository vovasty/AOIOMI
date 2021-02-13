//
//  File.swift
//
//
//  Created by vlsolome on 2/12/21.
//

import Foundation

public protocol AsyncCommand {
    var parameters: [String]? { get }
    var executable: Executable { get }
}
