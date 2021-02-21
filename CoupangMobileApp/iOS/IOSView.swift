//
//  iOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSView: View {
    @EnvironmentObject var simulator: IOSSimulator
    @EnvironmentObject var appManager: IOSAppManager
    @EnvironmentObject var proxyManager: HTTPProxyManager
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack {
            ActivityView(style: .ios, state: $activityState)
            switch simulator.state {
            case .notConfigured:
                IOSConfigureView(activityState: $activityState)
            case .started:
                AppView(appManager: appManager,
                        activityState: $activityState,
                        installTitle: "Choose an App to Install",
                        fileExtensions: ["app"]) { url in
                    appManager.install(app: url, defaults: proxyManager.iosDefaults)
                }
            case .stopped, .starting, .stopping, .configuring, .checking:
                IOSSimulatorView(activityState: $activityState)
            }
        }
    }
}

struct IOSView_Previews: PreviewProvider {
    static var previews: some View {
        IOSView()
            .environmentObject(IOSSimulator.preview(state: .notConfigured(nil)))
            .environmentObject(IOSAppManager.preview(state: .notInstalled(nil)))
            .environmentObject(HTTPProxyManager.preview())
    }
}
