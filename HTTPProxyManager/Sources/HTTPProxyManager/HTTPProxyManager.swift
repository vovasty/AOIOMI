import CharlesProxy
import Foundation
import MITMProxy

public class HTTPProxyManager: ObservableObject {
    public enum ClientType {
        case ios, aos

        func proxy(port: Int) -> String {
            switch self {
            case .aos:
                return "10.0.2.2:\(port)"
            default:
                return "127.0.0.1:\(port)"
            }
        }
    }

    public struct Proxy: Codable {
        public let host: String
        public let port: Int

        public var string: String {
            "\(host):\(port)"
        }
    }

    public enum ProxyType {
        case mitm, charles
    }

    public let charlesProxy: CharlesProxy
    public let mitmProxy: MITMProxy
    public var caPaths: [URL] {
        [charlesProxy.caURL, mitmProxy.caCert].compactMap { $0 }
    }

    public var proxyList: [ProxyType] {
        if charlesProxy.isInstalled {
            return [.mitm, .charles]
        } else {
            return [.mitm]
        }
    }

    public init(charlesProxy: CharlesProxy, mitmProxy: MITMProxy) {
        self.charlesProxy = charlesProxy
        self.mitmProxy = mitmProxy
    }

    public func port(proxy: ProxyType) -> Int? {
        switch proxy {
        case .charles:
            return charlesProxy.port
        case .mitm:
            return mitmProxy.port
        }
    }

    public func host(client: ClientType) -> String {
        switch client {
        case .aos:
            return "10.0.2.2"
        case .ios:
            return "127.0.0.1"
        }
    }

    public func proxy(client: ClientType, proxy: ProxyType) -> Proxy? {
        guard let port = port(proxy: proxy) else { return nil }
        let host = self.host(client: client)

        return Proxy(host: host, port: port)
    }
}

#if DEBUG
    public extension HTTPProxyManager {
        static func preview() -> HTTPProxyManager {
            HTTPProxyManager(charlesProxy: CharlesProxy(), mitmProxy: MITMProxy(port: 9999, guiPort: 9998, home: URL(fileURLWithPath: "/nonexisting")))
        }
    }
#endif
