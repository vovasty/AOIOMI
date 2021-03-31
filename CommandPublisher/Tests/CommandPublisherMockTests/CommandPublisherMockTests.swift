//
//  File.swift
//
//
//  Created by vlsolome on 2/17/21.
//

import Combine
import CommandPublisher
import CommandPublisherMock
import XCTest

private struct EchoCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?
    func parse(stdout: [String]) throws -> [String] {
        stdout
    }
}

private struct VoidCommand: Command {
    var executable: Executable = .helper
    let parameters: [String]?
    func parse(stdout: [String]) throws -> String {
        stdout.joined()
    }
}

private struct ACommand: AsyncCommand {
    var parameters: [String]?
    var executable: Executable = .helper
}

final class CommandPublisherMockTests: XCTestCase {
    func testSuccess() {
        let stdout = ["hello", "world"]
        let mock = CommanderMock(allowedCommands: [
            CommanderMock.AllowedCommand(type: EchoCommand.self, stdout: stdout),
        ]
        )

        let e = expectation(description: "running")
        var token = Set<AnyCancellable>()
        mock.run(command: EchoCommand(parameters: nil))
            .sink { completion in
                switch completion {
                case .failure:
                    XCTFail()
                case .finished:
                    break
                }
                e.fulfill()
            } receiveValue: { result in
                XCTAssertEqual(stdout, result)
            }
            .store(in: &token)
        waitForExpectations(timeout: 1)
    }

    func testFailure() {
        let stdout = ["hello", "world"]
        let mock = CommanderMock(allowedCommands: [
            CommanderMock.AllowedCommand(type: VoidCommand.self, stdout: stdout),
        ]
        )

        let e = expectation(description: "running")
        var token = Set<AnyCancellable>()
        mock.run(command: EchoCommand(parameters: nil))
            .sink { completion in
                switch completion {
                case .failure:
                    break
                case .finished:
                    XCTFail()
                }
                e.fulfill()
            } receiveValue: { _ in
                XCTFail()
            }
            .store(in: &token)
        waitForExpectations(timeout: 1)
    }

    func testAsyncFailure() {
        let mock = CommanderMock()
        let e = expectation(description: "running")
        var token = Set<AnyCancellable>()
        mock.run(command: ACommand())
            .sink { completion in
                switch completion {
                case .failure:
                    break
                case .finished:
                    XCTFail()
                }
                e.fulfill()
            } receiveValue: { _ in
                XCTFail()
            }
            .store(in: &token)
        waitForExpectations(timeout: 1)
    }

    func testAsyncSuccess() {
        let mock = CommanderMock(allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand(type: ACommand.self)])
        let e = expectation(description: "running")
        var token = Set<AnyCancellable>()
        mock.run(command: ACommand())
            .sink { completion in
                switch completion {
                case .failure:
                    XCTFail()
                case .finished:
                    break
                }
                e.fulfill()
            } receiveValue: { _ in
            }
            .store(in: &token)
        waitForExpectations(timeout: 1)
    }
}
