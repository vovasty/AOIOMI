import Combine
import Foundation

extension UserDefaults {
    func get<Type: Decodable>(_ key: String) throws -> Type? {
        guard let data = object(forKey: key) as? Data else { return nil }
        let decoder = JSONDecoder()
        return try decoder.decode(Type.self, from: data)
    }

    func set<Type: Encodable>(_ key: String, value: Type) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(value)
        set(encoded, forKey: key)
    }
}

@propertyWrapper
public struct UserDefault<T: Codable> {
    public let key: String
    public let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            (try? UserDefaults.standard.get(key)) ?? defaultValue
        }
        set {
            try? UserDefaults.standard.set(key, value: newValue)
        }
    }
}
