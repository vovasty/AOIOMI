import Combine
import CommandPublisherMock
import Foundation
import XCTest

public extension JSONDecoder {
    enum DecodeError: Error {
        case noFile
    }

    func decode<Type: Decodable>(fileName: String, type: Type.Type, bundle: Bundle) throws -> Type {
        guard let jsonURL = bundle.url(forResource: "\(fileName)", withExtension: nil) else {
            throw DecodeError.noFile
        }

        let data = try Data(contentsOf: jsonURL)
        return try decode(type, from: data)
    }
}

public extension JSONEncoder {
    enum EncodeError: Error {
        case badData
    }

    func toString<Type: Encodable>(_ object: Type) throws -> String {
        let data = try encode(object)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodeError.badData
        }

        return string
    }
}

public protocol TestObjectProtocol: ObservableObject {
    associatedtype StateType: Equatable
    // Wrapped value
    var state: StateType { get }

    // Publisher
    var statePublisher: Published<StateType>.Publisher { get }
}

public protocol StatesTestCase: XCTestCase {
    associatedtype TestObject: TestObjectProtocol

    func getTestObject(commanderMock _: CommanderMock) -> TestObject
    func testStates(file: StaticString, line: UInt, allowedCommands: [CommanderMock.AllowedCommand], allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand], expected: [TestObject.StateType], action: (TestObject) -> Void)
}

public extension StatesTestCase {
    func testStates(file: StaticString = #filePath, line: UInt = #line, allowedCommands: [CommanderMock.AllowedCommand] = [], allowedAsyncCommands: [CommanderMock.AllowedAsyncCommand] = [], expected: [TestObject.StateType], action: (TestObject) -> Void) {
        let commanderMock = CommanderMock(allowedCommands: allowedCommands, allowedAsyncCommands: allowedAsyncCommands)
        let testObject = getTestObject(commanderMock: commanderMock)
        var actual = [TestObject.StateType]()
        var tokens = Set<AnyCancellable>()
        let e = expectation(description: "test")

        testObject.statePublisher
            .timeout(.seconds(0.1), scheduler: DispatchQueue.main, options: nil, customError: nil)
            .collect()
            .sink(receiveCompletion: { _ in
                e.fulfill()
            }, receiveValue: {
                actual = $0
            })
            .store(in: &tokens)

        action(testObject)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}
