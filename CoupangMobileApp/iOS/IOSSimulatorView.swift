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
                IOSConfigureDialogView(isDisplayed: $isConfigureDisplayed)
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

private extension IOSSimulator.State {
    var asActivity: ActivityView.ActivityState {
        switch self {
        case let .stopped(error):
            if let error = error {
                return .error("Simulator is Stopped", error)
            } else {
                return .text("Simulator is Stopped")
            }
        case .stopping:
            return .busy("Stopping Simulator...")
        case .starting:
            return .busy("Starting Simulator...")
        case .configuring:
            return .busy("Configuring Simulator...")
        case .checking:
            return .busy("Checking Simulator...")
        case .notConfigured:
            return .text("Simulator is Not Configured")
        case .started:
            return .text("Simulator is Started")
        }
    }
}

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
