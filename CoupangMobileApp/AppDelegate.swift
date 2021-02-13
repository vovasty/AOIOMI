//
//  AppDelegate.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import AndroidEmulator
import Cocoa
import Combine
import iOSSimulator
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    private var simulator: iOSSimulator!
    private var emulator: AndroidEmulator!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_: Notification) {
        // Create the SwiftUI view that provides the window contents.
        emulator = try! AndroidEmulator()
        let simulatorId = (Bundle.main.bundleIdentifier ?? "com.coupang.CoupangMobile") + ".Simulator"
        simulator = try! iOSSimulator(simulatorName: simulatorId)
        let iosDefaults = AppManager.Defaults(path: ["PROXY_INFO"], data: ["ip": "127.0.0.1", "port": 8888])
        let iosAppManager = AppManager(simulatorId: simulatorId, bundleId: "com.coupang.Coupang", defaults: iosDefaults)
        let aosAppManager = AppManager(activityId: "com.coupang.mobile/com.coupang.mobile.domain.home.main.activity.MainActivity", packageId: "com.coupang.mobile", preferencesPath: "/data/data/com.coupang.mobile/shared_prefs/com.coupang.mobile_preferences.xml")
        let proxyManager = ProxyManager()
        let contentView = ContentView()
            .environmentObject(emulator)
            .environmentObject(simulator)
            .environmentObject(iosAppManager)
            .environmentObject(aosAppManager)
            .environmentObject(proxyManager)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    // hide window instead of close
    // http://iswwwup.com/t/4904b499b7a1/osx-how-to-handle-applicationshouldhandlereopen-in-a-non-document-based-st.html
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard !flag else { return true }

        for window in sender.windows {
            window.makeKeyAndOrderFront(self)
        }

        return true
    }

    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        simulator.stop()

        switch emulator.state {
        case .checking, .starting, .configuring, .started:
            emulator.stop()
            emulator.$state.sink { state in
                switch state {
                case .stopped:
                    NSApplication.shared.terminate(self)
//                    sender.terminate(self)
                default:
                    break
                }
            }
            .store(in: &cancellables)
            return .terminateLater
        case .notConfigured, .stopped, .stopping:
            return .terminateNow
        }
    }
}
