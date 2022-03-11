//
//  IOSRunView.swift
//  AOIOMI
//
//  Created by vlsolome on 2/11/21.
//

import CommonUI
import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSSimulatorView: View {
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var httpProxyManager: HTTPProxyManager
    @EnvironmentObject private var userSettings: UserSettings
    @Binding var activityState: ActivityView.ActivityState

    @State private var isConfigureDisplayed = false
    @State private var startDisabled = false

    var body: some View {
        VStack(alignment: .leading) {
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
                    .environmentObject(userSettings)
                    .frame(width: 200)
                    .padding()
            }
        }
        .onReceive(simulator.$state) { state in
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
