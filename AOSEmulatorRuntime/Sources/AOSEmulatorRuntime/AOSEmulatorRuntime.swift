import Combine
import Foundation
import SwiftShell

public class AOSEmulatorRuntime: ObservableObject {
    public enum State {
        case installed, checking, installing, notInstalled(Swift.Error?), unknown
    }

    public enum Error: Swift.Error {
        case failed
    }

    @Published public private(set) var state: State = .unknown

    private let home: URL
    private let helper: String
    private var process: AsyncCommand?

    public private(set) lazy var context: Context & CommandRunning = {
        var context = CustomContext(main)
        context.env["ANDROID_HOME"] = home.path
        context.env["JAVA_HOME"] = Bundle.module.url(forResource: "jdk", withExtension: nil)!.path
        context.env["AOS_EMULATOR_RUNTIME_VERSION"] = "28"
        context.env["AOS_EMULATOR_RUNTIME_TAG"] = "google_apis"
        context.env["AOS_EMULATOR_RUNTIME_PLATFORM"] = "x86_64"
        return context
    }()

    public init(home: URL) {
        self.home = home
        try? FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        helper = Bundle.module.url(forResource: "helper", withExtension: "sh")!.path
    }

    public func install() {
        guard process == nil else { return }
        state = .installing
        process = context.runAsync(helper, "install")
            .onCompletion { process in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.state = process.exitcode() == 0 ? .installed : .notInstalled(Error.failed)
                    self.process = nil
                }
            }
//        process?.stderror.onStringOutput { line in
//            print("[err]", line)
//        }
//        process?.stdout.onStringOutput { line in
//            print("[out]", line)
//        }
    }

    public func check() {
        guard process == nil else { return }
        state = .checking
        process = context.runAsync(helper, "check")
            .onCompletion { process in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.state = process.exitcode() == 0 ? .installed : .notInstalled(nil)
                    self.process = nil
                }
            }
    }
}
