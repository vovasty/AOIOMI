import Combine
import Foundation
@testable import KVStore
import XCTest

private struct TestValue: StoreItem {
    static func < (lhs: TestValue, rhs: TestValue) -> Bool {
        lhs.id.uuidString < rhs.id.uuidString
    }

    let id: UUID
    let data: String
    init() {
        id = UUID()
        data = ""
    }

    init(data: String) {
        id = UUID()
        self.data = data
    }
}

final class KVStoreTests: XCTestCase {
    var dbURL: URL!

    override func setUp() {
        super.setUp()
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
        dbURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                    isDirectory: true).appendingPathComponent("test")
    }

    override func tearDown() {
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
    }

    func testInsert() throws {
        let manager = try Manager(data: dbURL)
        let store1: Store<TestValue> = try manager.open(name: "test")
        store1.items.append(TestValue())
        store1.items.append(TestValue())
        wait(store: store1, items: 2)
        XCTAssertEqual(store1.items.count, 2)
        let store2: Store<TestValue> = try manager.open(name: "test")
        XCTAssertEqual(store1.items.count, store2.items.count)
    }

    func testRemove() throws {
        let manager = try Manager(data: dbURL)
        let store1: Store<TestValue> = try manager.open(name: "test")
        store1.items.append(TestValue())
        store1.items.append(TestValue())
        wait(store: store1, items: 2)
        XCTAssertEqual(store1.items.count, 2)
        store1.items.remove(at: 0)
        wait(store: store1, items: 0)
        let store2: Store<TestValue> = try manager.open(name: "test")
        XCTAssertEqual(store2.items.count, 1)
        XCTAssertEqual(store2.items.count, store1.items.count)
    }

    func testLargeValue() throws {
        let manager = try Manager(data: dbURL)
        let store1: Store<TestValue> = try manager.open(name: "test")
        for _ in 0 ... 9 {
            store1.items.append(TestValue(data: String(repeating: "x", count: 600_000)))
        }
        wait(store: store1, items: 10)
        XCTAssertEqual(store1.items.count, 10)
        let store2: Store<TestValue> = try manager.open(name: "test")
        XCTAssertEqual(store2.items.count, 10)
    }

    private func wait(store: Store<TestValue>, items: Int) {
        let e = expectation(description: "save")
        var counter = 0
        var subs = Set<AnyCancellable>()
        store.$state.sink {
            guard $0 == .idle else { return }
            counter += 1
            if counter == items + 1 {
                e.fulfill()
            }
        }
        .store(in: &subs)
        wait(for: [e], timeout: 1)
    }
}
