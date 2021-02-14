//
//  IOSRunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import HTTPProxyManager
import iOSSimulator
import SwiftUI

struct IOSSimulatorView: View {
    @EnvironmentObject var simulator: iOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @State private var isConfigureDisplayed = false
    @State private var activityState = ActivityView.ActivityState.text("")
    @State private var startDisabled = false

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
            Button("start") {
                simulator.start()
            }
            .disabled(startDisabled)
            Button("configure") {
                isConfigureDisplayed.toggle()
            }
            .sheet(isPresented: $isConfigureDisplayed) {
                IOSConfigureView(isDisplayed: $isConfigureDisplayed)
                    .environmentObject(simulator)
                    .environmentObject(httpProxyManager)
            }
        }
        .onReceive(Just(simulator.state)) { state in
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

struct IOSSimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "super mega error"])
        IOSSimulatorView()
            .environmentObject(iOSSimulator.preview(state: .stopped(nil)))
        IOSSimulatorView()
            .environmentObject(iOSSimulator.preview(state: .stopped(error)))
        IOSSimulatorView()
            .environmentObject(iOSSimulator.preview(state: .starting))
    }
}
