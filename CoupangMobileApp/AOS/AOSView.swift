//
//  AOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import AOSEmulator
import AOSEmulatorRuntime
import HTTPProxyManager
import SwiftUI

struct AOSView: View {
    @EnvironmentObject var emulator: AOSEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @EnvironmentObject var appManager: AOSAppManager
    @EnvironmentObject var runtime: AOSEmulatorRuntime
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack(alignment: .leading) {
            ActivityView(style: .aos, state: $activityState)

            if case AOSEmulatorRuntime.State.installed = runtime.state {
                switch emulator.state {
                case .started:
                    AppView(appManager: appManager,
                            activityState: $activityState,
                            installTitle: "Choose an APK to Install",
                            fileExtensions: ["apk"]) { url in
                        appManager.install(apk: url)
                    }
                case .stopped, .starting, .stopping, .checking, .configuring, .notConfigured:
                    AOSEmulatorView(activityState: $activityState)
                }
            } else {
                AOSRuntimeView(activityState: $activityState)
            }
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
    struct AOSView_Previews: PreviewProvider {
        static var previews: some View {
            AOSView()
                .environmentObject(AOSEmulator.preview(state: .notConfigured(nil)))
                .environmentObject(AOSAppManager.preview(state: .notInstalled(nil)))
                .environmentObject(HTTPProxyManager.preview())
            AOSView()
                .environmentObject(AOSEmulator.preview(state: .started))
                .environmentObject(AOSAppManager.preview(state: .installed(error: nil, defaults: nil)))
                .environmentObject(HTTPProxyManager.preview())
        }
    }
#endif
