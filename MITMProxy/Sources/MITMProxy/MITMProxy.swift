import Combine
import Foundation
import SwiftShell

public class MITMProxy: ObservableObject {
    public enum State {
        case started, starting, stopped, stopping
    }

    @Published public private(set) var state: State = .stopped
    public var uiUrl: URL {
        URL(string: "http://127.0.0.1:\(guiPort)")!
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
         "-s", addonManager.scriptURL.path,
         "--set",
         "confdir=\(mitmProxyConfigDir.path)"] +
            allowedHosts.map { ["--allow-hosts", $0] }.flatMap { $0 }
    }

    private var process: AsyncCommand?
    private var needStart: Bool = false
    private var checkStartedTimer: Timer?

    public var port: Int
    public var guiPort: Int
    public var allowedHosts: [String]
    public var addonManager: AddonManager

    public init(port: Int, guiPort: Int, appSupportPath: URL, allowedHosts: [String]) {
        context = CustomContext(main)
        self.port = port
        self.guiPort = guiPort
        self.allowedHosts = allowedHosts
        killOrphanCommand = Bundle.module.url(forResource: "kill-orphan.sh", withExtension: "")!.path
        proxyCommand = Bundle.module.url(forResource: "mitmweb", withExtension: "")!.path
        mitmProxyConfigDir = appSupportPath.appendingPathComponent("mitmproxy")
        caCert = mitmProxyConfigDir.appendingPathComponent("mitmproxy-ca-cert.pem")
        addonManager = AddonManager(scriptURL: appSupportPath.appendingPathComponent("addons.py"))
    }

    public func start() {
        state = .starting

        queue.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.addonManager.writeScript()
            } catch {
                print("failed tow write addon script", error)
            }

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
        guard checkStartedTimer == nil else { return }

        checkStartedTimer = Timer(timeInterval: 1)
        checkStartedTimer?.eventHandler = { [weak self] in
            guard let self = self else { return }

            let request = URLRequest(url: self.uiUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 0.1)
            let task = URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
                guard let self = self else { return }
                guard error == nil else { return }
                self.checkStartedTimer = nil
                DispatchQueue.main.async { [weak self] in
                    self?.state = .started
                }
            }
            task.resume()
        }
        checkStartedTimer?.resume()
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
