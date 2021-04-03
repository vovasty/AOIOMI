import Combine
import Foundation
import SWXMLHash

public class CharlesProxy: ObservableObject {
    private let _caURL: URL?
    private let settingsURL: URL?

    public var port: Int? {
        guard let settingsURL = settingsURL else { return nil }

        do {
            let data = try Data(contentsOf: settingsURL)
            let xml = SWXMLHash.parse(data)
            guard let stringPort = xml["configuration"]["proxyConfiguration"]["port"].element?.text else { return nil }
            return Int(stringPort)
        } catch {
            return nil
        }
    }

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

    public var isInstalled: Bool {
        port != nil && caURL != nil
    }
}

#if DEBUG
    public extension CharlesProxy {
        static func preview() -> CharlesProxy {
            CharlesProxy()
        }
    }
#endif
