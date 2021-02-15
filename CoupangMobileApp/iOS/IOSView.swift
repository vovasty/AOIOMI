//
//  iOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import HTTPProxyManager
import iOSSimulator
import SwiftUI

struct IOSView: View {
    @EnvironmentObject var simulator: iOSSimulator
    @State private var activityState = ActivityView.ActivityState.text("")

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
            switch simulator.state {
            case .notConfigured:
                IOSConfigureView()
            case .started:
                IOSAppView(activityState: $activityState)
            case .stopped, .starting, .stopping, .configuring, .checking:
                IOSSimulatorView(activityState: $activityState)
            }
        }
    }
}

struct IOSView_Previews: PreviewProvider {
    static var previews: some View {
        IOSView()
            .environmentObject(AppManager.preview(state: .notInstalled(nil)))
            .environmentObject(HTTPProxyManager.preview())
    }
}
