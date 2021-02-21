//
//  AOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import AOSEmulator
import HTTPProxyManager
import SwiftUI

struct AOSView: View {
    @EnvironmentObject var emulator: AOSEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @EnvironmentObject var appManager: AOSAppManager
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack {
            ActivityView(style: .aos, state: $activityState)
            switch emulator.state {
            case .notConfigured:
                Button("Configure") {
                    emulator.configure(proxy: proxyManager.proxy(type: .aos)?.asString, caPath: proxyManager.caURL)
                }
                .onAppear {
                    activityState = emulator.state.activity
                }
            case .started:
                AppView(appManager: appManager,
                        activityState: $activityState,
                        installTitle: "Choose an APK to Install",
                        fileExtensions: ["apk"]) { url in
                    appManager.install(apk: url)
                }
            case .stopped, .starting, .stopping, .checking, .configuring:
                AOSEmulatorView(activityState: $activityState)
            }
        }
    }
}

struct AOSView_Previews: PreviewProvider {
    static var previews: some View {
        AOSView()
            .environmentObject(AOSEmulator.preview(state: .notConfigured(nil)))
            .environmentObject(AOSAppManager.preview(state: .notInstalled(nil)))
            .environmentObject(HTTPProxyManager.preview())
    }
}
