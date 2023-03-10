//
//  iOSView.swift
//  AOIOMI
//
//  Created by vlsolome on 2/11/21.
//

import CommonUI
import IOSSimulator
import SwiftUI

struct IOSView: View {
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var appManager: IOSAppManager
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack(alignment: .leading) {
            ActivityView(style: .ios, state: $activityState)
            switch simulator.state {
            case .notConfigured:
                IOSConfigureView(isDisplayed: .constant(true), isCancellable: false)
                    .environmentObject(simulator)
                    .onAppear {
                        activityState = simulator.state.activity
                    }
            case .started:
                AppView(appManager: appManager,
                        activityState: $activityState,
                        installTitle: "Choose an App to Install",
                        fileExtensions: ["app"]) { url in
                    appManager.install(app: url, defaults: appManager.iosDefaults)
                }
            case .stopped, .starting, .stopping, .configuring, .checking:
                IOSSimulatorView(activityState: $activityState)
            }
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
    import HTTPProxyManager

    struct IOSView_Previews: PreviewProvider {
        static let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "terrible error terrible error terrible error terrible error terrible error terrible error"])
        static var previews: some View {
            IOSView()
                .environmentObject(IOSSimulator.preview(state: .notConfigured(nil)))
                .environmentObject(IOSAppManager.preview(state: .notInstalled(nil)))
                .environmentObject(HTTPProxyManager.preview())
            IOSView()
                .frame(width: 300, alignment: .leading)
                .environmentObject(IOSSimulator.preview(state: .checking, deviceTypes: [
                    SimctlList.DeviceType(name: "iPhone"),
                    SimctlList.DeviceType(name: "iPad"),
                ]))
                .environmentObject(IOSAppManager.preview(state: .notInstalled(nil)))
                .environmentObject(HTTPProxyManager.preview())
            IOSView()
                .environmentObject(IOSSimulator.preview(state: .started))
                .environmentObject(IOSAppManager.preview(state: .installed(error: error, defaults: nil)))
                .environmentObject(HTTPProxyManager.preview())
        }
    }
#endif
