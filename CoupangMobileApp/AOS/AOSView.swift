//
//  AOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import AndroidEmulator
import HTTPProxyManager
import SwiftUI

struct AOSView: View {
    @EnvironmentObject var emulator: AndroidEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
            switch emulator.state {
            case .notConfigured:
                Button("Configure") {
                    emulator.configure(proxy: proxyManager.proxy(type: .aos)?.asString, caPath: proxyManager.caURL)
                }
            case .started:
                AOSAppStateView(activityState: $activityState)
            case .stopped, .starting, .stopping, .checking, .configuring:
                AOSEmulatorView(activityState: $activityState)
            }
        }
    }
}

struct AOSView_Previews: PreviewProvider {
    static var previews: some View {
        AOSView()
    }
}
