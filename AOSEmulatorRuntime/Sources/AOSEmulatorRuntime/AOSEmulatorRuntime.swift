import Combine
import Foundation
import SwiftShell

public class AOSEmulatorRuntime: ObservableObject {
    public enum State {
        case installed, checking, installing, notInstalled(Swift.Error?)
    }

    public enum Error: Swift.Error {
        case failed
    }

    @Published public private(set) var state: State = .notInstalled(nil)

    private let home: URL
    private let helper: String
    private let context: Context & CommandRunning
    private var process: AsyncCommand?

    public init(home: URL) {
        var context = CustomContext(main)
        context.env["ANDROID_SDK_ROOT"] = home.path
        context.env["JAVA_HOME"] = Bundle.module.url(forResource: "jdk", withExtension: nil)!.path
        context.env["AOS_EMULATOR_RUNTIME_VERSION"] = "28"
        context.env["AOS_EMULATOR_RUNTIME_TAG"] = "google_apis"
        context.env["AOS_EMULATOR_RUNTIME_PLATFORM"] = "x86_64"
        self.context = context
        self.home = home
        helper = Bundle.module.url(forResource: "helper", withExtension: "sh")!.path
    }

    public func install() {
        state = .installing

        process = context.runAsync(helper, "install")
            .onCompletion { process in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.state = process.exitcode() == 0 ? .installed : .notInstalled(Error.failed)
                    self.process = nil
                }
            }
        process?.stderror.onStringOutput { line in
            print("[err]", line)
        }
        process?.stdout.onStringOutput { line in
            print("[out]", line)
        }
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
