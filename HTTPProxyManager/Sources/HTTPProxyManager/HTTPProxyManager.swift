import Combine
import Foundation

public class HTTPProxyManager: ObservableObject {
    public enum Client {
        case aos, ios
    }

    public struct Proxy {
        public let host: String
        public let port: Int
    }

    public init() {}

    public let caPath = FileManager.default.urls(for: .applicationSupportDirectory,
                                                 in: .userDomainMask)
        .first!
        .appendingPathComponent("Charles")
        .appendingPathComponent("ca")
        .appendingPathComponent("charles-proxy-ssl-proxying-certificate.pem")

    public func proxy(type: Client) -> Proxy {
        switch type {
        case .ios:
            return Proxy(host: "127.0.0.1", port: 8888)
        case .aos:
            return Proxy(host: "10.0.2.2", port: 8888)
        }
    }
}
