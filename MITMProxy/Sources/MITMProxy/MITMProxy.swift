import Combine
import Foundation
import SwiftShell

public protocol Addon {
    var id: String { get }
    var importString: String { get }
    var constructor: String { get }
}

public class MITMProxy: ObservableObject {
    public enum State {
        case started, starting, stopped, stopping
    }

    @Published public private(set) var state: State = .stopped
    public var uiUrl: URL {
        URL(string: "http://127.0.0.1:\(guiPort)")!
    }

    public var addons: [Addon] = [] {
        didSet {
            generateAddonScript()
        }
    }

    public let caCert: URL

    private let context: Context & CommandRunning
    private let queue = DispatchQueue.global(qos: .background)
    private let proxyCommand: String
    private let killOrphanCommand: String
    private let mitmProxyConfigDir: URL
    private var proxyParameters: [String] {
        ["--no-web-open-browser",
         "--listen-port", String(port),
         "--listen-host", "127.0.0.1",
         "--web-port", "\(guiPort)",
         "--web-host", "127.0.0.1",
         "-s", addonURL.path,
         "--set",
         "confdir=\(mitmProxyConfigDir.path)"] +
            allowedHosts.map { ["--allow-hosts", $0] }.flatMap { $0 }
    }

    private var process: AsyncCommand?
    private let addonURL: URL
    private let addonsLibURL: URL
    private var needStart: Bool = false

    public var port: Int
    public var guiPort: Int
    public var allowedHosts: [String]

    public init(port: Int, guiPort: Int, appSupportPath: URL, allowedHosts: [String]) {
        context = CustomContext(main)
        self.port = port
        self.guiPort = guiPort
        self.allowedHosts = allowedHosts
        killOrphanCommand = Bundle.module.url(forResource: "kill-orphan.sh", withExtension: "")!.path
        addonsLibURL = Bundle.module.url(forResource: "addons", withExtension: "")!
        addonURL = appSupportPath.appendingPathComponent("addons.py")
        proxyCommand = Bundle.module.url(forResource: "mitmweb", withExtension: "")!.path
        mitmProxyConfigDir = appSupportPath.appendingPathComponent("mitmproxy")
        caCert = mitmProxyConfigDir.appendingPathComponent("mitmproxy-ca-cert.pem")
    }

    public func start() {
        state = .starting

        queue.async { [weak self] in
            guard let self = self else { return }
            self.generateAddonScript()
            self.process = self.context.runAsync(self.proxyCommand, self.proxyParameters)
                .onCompletion { _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.state = .stopped
                        self.process = nil
                        if self.needStart {
                            self.needStart = false
                            self.start()
                        }
                    }
                }
//            self.process?.stderror.onStringOutput { line in
//                print("[err]", line)
//            }
//            self.process?.stdout.onStringOutput { line in
//                print("[out]", line)
//            }
            self.checkStarted()
        }
    }

    public func stop() {
        state = .stopping
        process?.stop()
    }

    public func restart() {
        switch state {
        case .started, .starting:
            needStart = true
            stop()
        case .stopped:
            start()
        case .stopping:
            needStart = true
        }
    }

    public func stopOrphan() {
        context.run(killOrphanCommand, proxyCommand)
    }

    private func checkStarted() {
        guard state == .starting else { return }

        let request = URLRequest(url: uiUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0.1)
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            guard let self = self else { return }
            if error == nil {
                DispatchQueue.main.async { [weak self] in
                    self?.state = .started
                }
                return
            } else {
                self.checkStarted()
            }
        }
        task.resume()
    }

    private func createAddonScript() -> String {
        let importString = addons.map(\.importString).joined(separator: "\n")

        let initString = addons.map { "\($0.id) = \($0.constructor)" }.joined(separator: "\n")

        let addonString = addons.map(\.id).joined(separator: ",")

        let script = """
        import sys
        sys.path.append('\(addonsLibURL.path)')

        \(importString)

        \(initString)

        addons = [
            \(addonString)
        ]
        """
        return script
    }

    private func generateAddonScript() {
        let script = createAddonScript()
        do {
            try script.data(using: .utf8)?.write(to: addonURL, options: .atomicWrite)
        } catch {
            print("upable to create addon", error)
        }
    }
}

#if DEBUG
    public extension MITMProxy {
        static let preview: MITMProxy = {
            let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory,
                                                          in: .userDomainMask).first!
                .appendingPathComponent(Bundle.main.bundleIdentifier!)
            try? FileManager.default.createDirectory(at: appSupportPath, withIntermediateDirectories: false, attributes: nil)
            return MITMProxy(port: 9999, guiPort: 9998, appSupportPath: appSupportPath, allowedHosts: ["cmapi.coupang.com"])
        }()

        func set(state: State) {
            self.state = state
        }
    }
#endif
