//
//  AndriodEmulator.swift
//
//
//  Created by vlsolome on 10/9/20.
//

import Combine
import SwiftUI
import SWXMLHash

public class AndroidEmulator: ObservableObject {
    public enum State {
        case started, starting, stopped(Swift.Error?), stopping, configuring, checking, notConfigured
    }

    public enum AppState {
        case notInstalled(Swift.Error?), installed(pcid: String?), installing, checking
    }

    @Published public private(set) var state: State = .checking {
        didSet {
            switch state {
            case .started:
                checkApp()
            default:
                break
            }
        }
    }

    @Published public private(set) var appState: AppState = .checking
    private var runner: AndroidEmulatorRunner
    private var startCancellable: AnyCancellable?
    private var updatePropertiesCancellable: AnyCancellable?
    private var checkCancellable: AnyCancellable?
    private var checkAppCancellable: AnyCancellable?
    private var installCancellable: AnyCancellable?
    private var configureCancellable: AnyCancellable?
    private var runAppCancellable: AnyCancellable?

    public init() throws {
        runner = try AndroidEmulatorRunner(rootPath: Bundle.module.url(forResource: "emulator", withExtension: "")!)
    }

    public func start() {
        state = .starting
        startCancellable = runner.start()
            .map { State.started }
            .catch { Just(State.stopped($0)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.state, on: self)
    }

    public func stop() {
        state = .stopping
        runner.stop()
    }

    public func check() {
        checkCancellable = checkEmulatorState()
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.state, on: self)
    }

    public func install(apk: String) {
        appState = .installing
        installCancellable = runner.install(apk: apk)
            .map { AppState.installing }
            .catch { Just(AppState.notInstalled($0)) }
            .flatMap { state -> AnyPublisher<AppState, Never> in
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.checkAppState()
                }
            }
            .collect()
            .map { $0.last ?? .notInstalled(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.appState, on: self)
    }

    public func checkApp() {
        appState = .checking
        checkAppCancellable = checkAppState()
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.appState, on: self)
    }

    public func configure(caPath: String, proxy: String) {
        state = .configuring
        configureCancellable = runner.configure(caPath: caPath, proxy: proxy)
            .map { _ in State.started }
            .catch { error in Just(State.stopped(error)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.state, on: self)
    }

    public func runApp() {
        // runAppCancellable
        appState = .checking
        runAppCancellable = runner.runApp(appActivityId: "com.coupang.mobile/com.coupang.mobile.domain.home.main.activity.MainActivity")
            .map { AppState.checking }
            .catch { error in Just(AppState.notInstalled(error)) }
            .flatMap { state -> AnyPublisher<AppState, Never> in
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.checkAppState()
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \AndroidEmulator.appState, on: self)
    }

    public func configure() {
        let caPath = FileManager.default.urls(for: .applicationSupportDirectory,
                                              in: .userDomainMask)
            .first!
            .appendingPathComponent("Charles")
            .appendingPathComponent("ca")
            .appendingPathComponent("charles-proxy-ssl-proxying-certificate.pem").path

        let proxy = "10.0.2.2:8888"
        configure(caPath: caPath, proxy: proxy)
    }

    private func checkAppState() -> AnyPublisher<AppState, Never> {
        runner.isAppInstalled(appPackageId: "com.coupang.mobile")
            .map { _ in AppState.checking }
            .catch { _ in Just(AppState.notInstalled(nil)) }
            .flatMap { state -> AnyPublisher<AppState, Never> in
                switch state {
                case .notInstalled:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.runner.get(file: "/data/data/com.coupang.mobile/shared_prefs/com.coupang.mobile_preferences.xml")
                        .map { data -> AppState in
                            let xml = SWXMLHash.parse(data)
                            let pcid: String?
                            do {
                                pcid = try xml["map"]["string"].withAttribute("name", "wl_pcid").element?.text
                            } catch {
                                pcid = nil
                            }
                            return AppState.installed(pcid: pcid)
                        }
                        .catch { _ in Just(AppState.installed(pcid: nil)) }
                        .eraseToAnyPublisher()
                }
            }
            .collect()
            .map { $0.last ?? .notInstalled(nil) }
            .eraseToAnyPublisher()
    }

    private func checkEmulatorState() -> AnyPublisher<State, Never> {
        runner.isCreated()
            .map { _ in State.started }
            .catch { _ in Just(State.notConfigured) }
            .flatMap { state -> AnyPublisher<State, Never> in
                switch state {
                case .notConfigured:
                    return Just(state)
                        .eraseToAnyPublisher()
                default:
                    return self.runner.isRunning()
                        .map { State.started }
                        .catch { _ in Just(State.stopped(nil)) }
                        .eraseToAnyPublisher()
                }
            }
            .collect()
            .map { $0.last ?? .stopped(nil) }
            .eraseToAnyPublisher()
    }
}
