//
//  AndriodEmulator.swift
//
//
//  Created by vlsolome on 10/9/20.
//

import SwiftUI

public class AndroidEmulator: ObservableObject {
    public enum State {
        case started, starting, stopped, stopping, configuring, checking, notConfigured
    }

    @Published public var currentCommand: (name: String, running: Bool)?
    @Published public private(set) var state: State = .checking
    private var runner: AndroidEmulatorRunner

    public init() throws {
        runner = try AndroidEmulatorRunner(rootPath: Bundle.module.url(forResource: "emulator", withExtension: "")!)
        runner.delegate = self
    }

    public func start() {
        state = .starting
        runner.start()
    }

    public func stop() {
        state = .stopping
        runner.stop()
    }

    public func check() {
        runner.isCreated()
    }

    public func install(apk: String) {
        runner.install(apk: apk)
    }

    public func configure(caPath: String, proxy: String) {
        state = .configuring
        runner.configure(caPath: caPath, proxy: proxy)
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
}

extension AndroidEmulator: AndroidEmulatorRunnerDelegate {
    func isCreated(runner _: AndroidEmulatorRunner, isCreated: Bool) {
        DispatchQueue.main.async {
            self.state = isCreated ? .stopped : .notConfigured
        }
    }

    func created(runner _: AndroidEmulatorRunner, success _: Bool) {
        DispatchQueue.main.async {
            self.state = .stopped
        }
    }

    func started(runner _: AndroidEmulatorRunner) {
        DispatchQueue.main.async {
            self.state = .started
        }
    }

    func stopped(runner _: AndroidEmulatorRunner) {
        DispatchQueue.main.async {
            self.state = .stopped
        }
    }

    public func started(command _: AndroidEmulatorConfig.Command) {
//        currentCommand = (command.name, true)
    }

    public func finished(command _: AndroidEmulatorConfig.Command) {
//        currentCommand = (command.name, false)
    }
}
