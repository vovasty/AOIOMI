//
//  File.swift
//
//
//  Created by vlsolome on 2/13/21.
//

import AppKit

class SimulatorApp {
    let appURL = URL(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app", isDirectory: true)
    var isRunning: Bool {
        !(app?.isTerminated ?? true)
    }

    private var app: NSRunningApplication?

    func open() {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.createsNewApplicationInstance = false
        NSWorkspace.shared.open(appURL, configuration: configuration) { [weak self] app, _ in
            self?.app = app
        }
    }

    static let shared = SimulatorApp()
}
