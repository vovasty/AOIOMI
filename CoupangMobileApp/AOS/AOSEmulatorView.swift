//
//  RunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import Combine
import HTTPProxyManager
import SwiftUI

struct AOSEmulatorView: View {
    @EnvironmentObject var emulator: AndroidEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @State private var activityState = ActivityView.ActivityState.text("")
    @State private var startDisabled = false

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
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
            activityState = state.asActivity
        }
    }
}

private extension AndroidEmulator.State {
    var asActivity: ActivityView.ActivityState {
        switch self {
        case .started:
            return .text("Emulator is Started")
        case .starting:
            return .busy("Starting Emulator...")
        case let .stopped(error):
            if let error = error {
                return .error("Emulator is Stopped", error)
            } else {
                return .text("Emulator is Stopped")
            }
        case .stopping:
            return .busy("Stopping Emulator...")
        case .configuring:
            return .busy("Configuring Emulator...")
        case .checking:
            return .busy("Checking Emulator...")
        case let .notConfigured(error):
            if let error = error {
                return .error("Emulator is Not Configured", error)
            } else {
                return .text("Emulator is Not Configured")
            }
        }
    }
}

struct AOSEmulatorView_Previews: PreviewProvider {
    static var previews: some View {
        AOSEmulatorView().environmentObject(try! AndroidEmulator())
    }
}
