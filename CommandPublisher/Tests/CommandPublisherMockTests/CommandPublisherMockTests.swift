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
    var parameters: [String]? = nil
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

    func testAsync() {
        let mock = CommanderMock(allowedCommands: [])
        let process = mock.run(command: ACommand())

        XCTAssert(process.isRunning)

        let e = expectation(description: "running")

        process.onCompletion {
            e.fulfill()
        }
        process.stop()

        waitForExpectations(timeout: 1)

        XCTAssertFalse(process.isRunning)
    }
}
