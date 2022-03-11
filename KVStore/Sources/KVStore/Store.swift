import AppKit
import Combine
import Foundation
import SwiftLMDB

public protocol StoreItem: Codable & Identifiable & Comparable {}

open class Store<Value: StoreItem>: ObservableObject {
    public enum State {
        case idle, saving
    }

    @Published public var items: [Value]
    @Published public var error: Error?
    @Published public var state = State.idle

    private let database: Database
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private var oldItems: [Value]
    private var sub: AnyCancellable?
    private let queue = DispatchQueue(label: "net.coupang.store")

    public init(database: Database) throws {
        self.database = database
        let items = Array(AnySequence(ValueSequence<Value>(database: database, decoder: decoder))).sorted()
        self.items = items
        oldItems = items
        sub = $items.sink { [weak self] newItems in
            guard let self = self else { return }
            self.state = .saving
            let oldItems = self.oldItems
            self.queue.async { [weak self] in
                guard let self = self else { return }
                let diff = newItems.difference(from: oldItems)
                var err: Error?
                for change in diff {
                    switch change {
                    case let .remove(_, element, _):
                        do {
                            try self.delete(key: "\(element.id)")
                        } catch {
                            err = error
                        }
                    case let .insert(_, element, _):
                        do {
                            try self.put(value: element, for: "\(element.id)")
                        } catch {
                            err = error
                        }
                    }
                }
                self.oldItems = newItems
                DispatchQueue.main.async { [weak self] in
                    self?.error = err
                    self?.state = .idle
                }
            }
        }
    }

    private func put(value: Value, for key: String) throws {
        let data = try encoder.encode(value)
        try database.put(value: data, forKey: key)
    }

    private func delete(key: String) throws {
        try database.deleteValue(forKey: key)
    }
}

private struct ValueSequence<P: Decodable>: Sequence, IteratorProtocol {
    private let database: Database
    private let iterator: Database.Iterator
    private let decoder: PropertyListDecoder

    init(database: Database, decoder: PropertyListDecoder) {
        self.database = database
        iterator = database.makeIterator()
        self.decoder = decoder
    }

    mutating func next() -> P? {
        guard let data = iterator.next() else { return nil }
        return try? decoder.decode(P.self, from: data.value)
    }

    public var underestimatedCount: Int {
        database.count
    }
}
