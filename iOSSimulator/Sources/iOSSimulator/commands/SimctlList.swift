//
//  File.swift
//
//
//  Created by vlsolome on 2/11/21.
//

import Foundation

public struct SimctlList: Decodable {
    public enum DeviceState: String, Decodable {
        case shutdown = "Shutdown"
        case booted = "Booted"
        case notCreated
    }

    public struct Device: Decodable {
        public let name: String
        public let udid: String
        public let state: DeviceState
    }

    public struct DeviceType: Decodable, Hashable {
        public let name: String
    }

    public let devices: [String: [Device]]
    public let devicetypes: [DeviceType]
}


public extension SimctlList.DeviceType {
    static let empty = SimctlList.DeviceType(name: "")
}
