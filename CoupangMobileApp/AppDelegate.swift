//
//  AppDelegate.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import AOSEmulator
import Cocoa
import Combine
import HTTPProxyManager
import IOSSimulator
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    private var simulator: IOSSimulator!
    private let emulator = AOSEmulator()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_: Notification) {
        let simulatorId = "CoupangMobileApp"
        simulator = IOSSimulator(simulatorName: simulatorId)
        let iosAppManager = AppManager(simulatorId: simulatorId, bundleId: "com.coupang.Coupang")
        let aosAppManager = AppManager(activityId: "com.coupang.mobile/com.coupang.mobile.domain.home.main.activity.MainActivity", packageId: "com.coupang.mobile", preferencesPath: "/data/data/com.coupang.mobile/shared_prefs/com.coupang.mobile_preferences.xml")
        let httpProxyManager = HTTPProxyManager()
        let contentView = ContentView()
            .environmentObject(emulator)
            .environmentObject(simulator)
            .environmentObject(iosAppManager)
            .environmentObject(aosAppManager)
            .environmentObject(httpProxyManager)

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
        simulator.stop()
        emulator.stop()
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
}
