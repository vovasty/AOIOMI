//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

public struct SimctlList: Codable {
    public enum DeviceState {
        case shutdown
        case booted
        case unknown(String)
        case notCreated
    }

    public struct Device: Codable {
        public var name: String
        public var udid: String
        public var state: DeviceState
    }

    public struct DeviceType: Codable, Hashable {
        public var name: String
        public init(name: String) {
            self.name = name
        }
    }

    public var devices: [String: [Device]]
    public var devicetypes: [DeviceType]
}

public extension SimctlList.DeviceType {
    static let empty = SimctlList.DeviceType(name: "")
}

extension SimctlList.DeviceState: Decodable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        let decoded = try value.decode(String.self)
        switch decoded {
        case "Shutdown":
            self = .shutdown
        case "Booted":
            self = .booted
        default:
            self = .unknown(decoded)
        }
    }
}

extension SimctlList.DeviceState: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let string: String

        switch self {
        case .shutdown:
            string = "Shutdown"
        case .booted:
            string = "Booted"
        case let .unknown(decoded):
            string = decoded
        case .notCreated:
            string = ""
        }

        try container.encode(string)
    }
}

extension SimctlList.DeviceState: Equatable {}
