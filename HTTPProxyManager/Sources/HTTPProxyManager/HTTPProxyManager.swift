import Combine
import Foundation
import SWXMLHash

public class HTTPProxyManager: ObservableObject {
    public enum Client {
        case aos, ios
    }

    public struct Proxy {
        public let host: String
        public let port: Int
    }

    private let _caURL: URL?
    private let settingsURL: URL?

    public convenience init() {
        self.init(caURL: FileManager.default.urls(for: .applicationSupportDirectory,
                                                  in: .userDomainMask)
                .first?
                .appendingPathComponent("Charles")
                .appendingPathComponent("ca")
                .appendingPathComponent("charles-proxy-ssl-proxying-certificate.pem"),
            settingsURL: FileManager.default.urls(for: .libraryDirectory,
                                                  in: .userDomainMask)
                .first?
                .appendingPathComponent("Preferences")
                .appendingPathComponent("com.xk72.charles.config"))
    }

    public init(caURL: URL?, settingsURL: URL?) {
        _caURL = caURL
        self.settingsURL = settingsURL
    }

    public var caURL: URL? {
        guard let url = _caURL else { return nil }

        guard (try? url.checkResourceIsReachable()) ?? false else { return nil }
        return url
    }

    public func proxy(type: Client) -> Proxy? {
        guard let settingsURL = settingsURL else { return nil }

        let proxyPort: Int
        do {
            let data = try Data(contentsOf: settingsURL)
            let xml = SWXMLHash.parse(data)
            guard let stringPort = xml["configuration"]["proxyConfiguration"]["port"].element?.text else { return nil }
            guard let port = Int(stringPort) else { return nil }
            proxyPort = port
        } catch {
            return nil
        }

        switch type {
        case .ios:
            return Proxy(host: "127.0.0.1", port: proxyPort)
        case .aos:
            return Proxy(host: "10.0.2.2", port: proxyPort)
        }
    }
}
