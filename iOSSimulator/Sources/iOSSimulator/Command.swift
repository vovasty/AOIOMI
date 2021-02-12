//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import CommandPublisher
import Foundation
import SwiftShell

enum Executable {
    case helper
}

protocol Command {
    associatedtype Result

    var parameters: [String]? { get }
    var executable: Executable { get }
    func parse(stdout: [String]) throws -> Result
}

extension Command {
    func run(helperPath: URL, context: Context & CommandRunning) -> AnyPublisher<Result, Swift.Error> {
        let executable: String
        switch self.executable {
        case .helper:
            executable = helperPath.path
        }
        return CommandPublisher(context: context,
                                command: executable,
                                parameters: parameters)
            .tryMap {
                try parse(stdout: $0.stdout.lines())
            }
            .eraseToAnyPublisher()
    }
}
