//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Combine
import Foundation
import SwiftShell

public protocol Commander {
    func run<CommandType: Command>(command: CommandType) -> AnyPublisher<CommandType.Result, Error>
    func run<AsyncCommandType: AsyncCommand>(command: AsyncCommandType) -> AnyPublisher<AsyncCommandPublisher.Result, Error>
}
