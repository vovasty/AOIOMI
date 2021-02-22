//
//  IOSRunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSSimulatorView: View {
    @EnvironmentObject var simulator: IOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @Binding var activityState: ActivityView.ActivityState

    @State private var isConfigureDisplayed = false
    @State private var startDisabled = false

    var body: some View {
        VStack {
            Button("Start") {
                simulator.start()
            }
            .disabled(startDisabled)
            Button("Reconfigure") {
                isConfigureDisplayed.toggle()
            }
            .sheet(isPresented: $isConfigureDisplayed) {
                IOSConfigureView(isDisplayed: $isConfigureDisplayed, isCancellable: true)
                    .environmentObject(simulator)
                    .environmentObject(httpProxyManager)
                    .frame(width: 200)
                    .padding()
            }
        }
        .onReceive(Just(simulator.state)) { state in
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

#if DEBUG
struct IOSSimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "super mega error"])
        IOSSimulatorView(activityState: .constant(.text("some")))
            .environmentObject(IOSSimulator.preview(state: .stopped(nil)))
        IOSSimulatorView(activityState: .constant(.text("some")))
            .environmentObject(IOSSimulator.preview(state: .stopped(error)))
        IOSSimulatorView(activityState: .constant(.text("some")))
            .environmentObject(IOSSimulator.preview(state: .starting))
    }
}
#endif
