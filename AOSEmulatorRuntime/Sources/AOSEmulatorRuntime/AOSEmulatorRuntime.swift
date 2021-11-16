import Combine
import Foundation
import SwiftShell

public class AOSEmulatorRuntime: ObservableObject {
    public enum State {
        case installed, checking, installing, notInstalled(Swift.Error?), updating, unknown
    }

    public enum Error: Swift.Error {
        case failed
    }

    @Published public private(set) var state: State = .unknown

    private let home: URL
    private let helper: String
    private var process: AsyncCommand?

    public private(set) lazy var env: [String: String] = {
        ["ANDROID_HOME": home.path,
         "JAVA_HOME": Bundle.module.url(forResource: "jdk", withExtension: nil)!.path,
         "AOS_EMULATOR_RUNTIME_VERSION": "28",
         "AOS_EMULATOR_RUNTIME_TAG": "google_apis",
         "AOS_EMULATOR_RUNTIME_PLATFORM": "x86_64"]
    }()

    private lazy var context: Context & CommandRunning = {
        var context = CustomContext(main)
        context.env.merge(env) { _, new in new }
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

    public func update() {
        guard process == nil else { return }
        state = .updating
        process = context.runAsync(helper, "update")
            .onCompletion { process in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.state = process.exitcode() == 0 ? .installed : .notInstalled(nil)
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
}

#if DEBUG
    public extension AOSEmulatorRuntime {
        static func preview(state: State) -> AOSEmulatorRuntime {
            let runtime = AOSEmulatorRuntime(home: URL(fileURLWithPath: "/nonexisting"))
            runtime.state = state
            return runtime
        }
    }
#endif
