import Combine
import CommandPublisherMock
import Foundation
import XCTest

public extension JSONDecoder {
    enum DecodeError: Error {
        case noFile
    }

    func decode<Type: Decodable>(fileName: String, type: Type.Type) throws -> Type {
        guard let jsonURL = Bundle.module.url(forResource: "Resources/\(fileName)", withExtension: nil) else {
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

open class StatesTestCase<TestObject: TestObjectProtocol>: XCTestCase {
    open func getTestObject(commanderMock _: CommanderMock) -> TestObject {
        fatalError("should be overwritten")
    }

    public func testStates(file: StaticString = #filePath, line: UInt = #line, _ allowedCommands: [CommanderMock.AllowedCommand], expected: [TestObject.StateType], action: (TestObject) -> Void) {
        let commanderMock = CommanderMock(allowedCommands: allowedCommands)
        let testObject = getTestObject(commanderMock: commanderMock)
        var actual = [TestObject.StateType]()
        var tokens = Set<AnyCancellable>()
        let e = expectation(description: "test")

        testObject.statePublisher
            .timeout(.seconds(0.1), scheduler: DispatchQueue.main, options: nil, customError: nil)
            .sink(receiveCompletion: { _ in
                e.fulfill()
            }, receiveValue: {
                actual.append($0)
            })
            .store(in: &tokens)

        action(testObject)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}
