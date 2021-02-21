//
//  AppDelegate.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    private let bigBrother = BigBrother()

    func applicationDidFinishLaunching(_: Notification) {
        let contentView = ContentView()
            .environmentObject(bigBrother.emulator)
            .environmentObject(bigBrother.simulator)
            .environmentObject(bigBrother.iosAppManager)
            .environmentObject(bigBrother.aosAppManager)
            .environmentObject(bigBrother.httpProxyManager)

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

        bigBrother.check()
    }

    func applicationWillTerminate(_: Notification) {
        bigBrother.stop()
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
