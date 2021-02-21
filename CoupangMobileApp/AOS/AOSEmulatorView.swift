//
//  RunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AOSEmulator
import Combine
import HTTPProxyManager
import SwiftUI

struct AOSEmulatorView: View {
    @EnvironmentObject var emulator: AOSEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @Binding var activityState: ActivityView.ActivityState
    @State private var startDisabled = false

    var body: some View {
        VStack {
            Button("Start") {
                emulator.start()
            }
            .disabled(startDisabled)
            Button("Reconfigure") {
                emulator.configure(proxy: proxyManager.proxy(type: .aos)?.asString, caPath: proxyManager.caURL)
            }
        }
        .onReceive(Just(emulator.state)) { state in
            switch state {
            case .stopped:
                startDisabled = false
            case .configuring, .checking, .notConfigured, .started, .stopping, .starting:
                startDisabled = true
            }
            activityState = state.activity
        }
    }
}

struct AOSEmulatorView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])

        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .configuring))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .checking))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .stopped(nil)))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .stopped(error)))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .stopping))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .notConfigured(nil)))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .notConfigured(error)))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .starting))
        AOSEmulatorView(activityState: .constant(.text("some")))
            .environmentObject(AOSEmulator.preview(state: .started))
    }
}
