import Foundation
import KVStore
import mustache

public struct Link: StoreItem, Hashable {
    public enum LinkError: Error {
        case wrongTemplate
    }

    public struct Pair: StoreItem, Hashable {
        public static func < (lhs: Link.Pair, rhs: Link.Pair) -> Bool {
            lhs.id == rhs.id &&
                lhs.value == lhs.value
        }

        public var id: String
        public var value: String
    }

    public let id: String

    public var name: String

    public var template: String {
        didSet {
            try? rebuild()
        }
    }

    public var parameters: [Pair]

    public func url() throws -> URL? {
        let parser = MustacheParser()
        let tree = parser.parse(string: template)
        var params = [String: String]()
        for (k, v) in parametersDict {
            params[k] = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        let result = tree.render(object: params)
        return URL(string: result)
    }

    public var parametersDict: [String: String] {
        parameters.reduce([String: String]()) {
            var d = $0
            d[$1.id] = $1.value
            return d
        }
    }

    public var isActive: Bool = false

    public init(id: String, name: String, template: String, parameters: [Link.Pair]) {
        self.id = id
        self.name = name
        self.template = template
        self.parameters = parameters
        try? rebuild()
    }

    private mutating func rebuild() throws {
        let parser = MustacheParser()
        let tree = parser.parse(string: template)
        switch tree {
        case let .Global(nodes):
            var result = nodes.compactMap { tag -> String? in
                if case let .Tag(tag) = tag {
                    return tag
                } else {
                    return nil
                }
            }
            .reduce([String: String]()) {
                var d = $0
                d[$1] = ""
                return d
            }

            for (k, v) in parametersDict {
                guard result[k] != nil else { continue }
                result[k] = v
            }

            parameters = result.map {
                Pair(id: $0.key, value: $0.value)
            }
        default:
            throw LinkError.wrongTemplate
        }
    }

    public static func < (lhs: Link, rhs: Link) -> Bool {
        lhs.id == rhs.id &&
            lhs.parameters == rhs.parameters &&
            lhs.template == rhs.template &&
            lhs.name == rhs.name
    }
}
