//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

public struct SimctlList: Decodable {
    public enum DeviceState {
        case shutdown
        case booted
        case unknown(String)
        case notCreated
    }

    public struct Device: Decodable {
        public let name: String
        public let udid: String
        public let state: DeviceState
    }

    public struct DeviceType: Decodable, Hashable {
        public let name: String
        public init(name: String) {
            self.name = name
        }
    }

    public let devices: [String: [Device]]
    public let devicetypes: [DeviceType]
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

extension SimctlList.DeviceState: Equatable {}
