//
//  IOSRunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import HTTPProxyManager
import iOSSimulator
import SwiftUI

struct IOSRunView: View {
    @EnvironmentObject var simulator: iOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @State private var isConfigureDisplayed = false

    var body: some View {
        VStack {
            switch simulator.state {
            case .started:
                IOSAppView()
            case let .stopped(error):
                Button("start") {
                    simulator.start()
                }
                ErrorView(error: error)
            case .stopping:
                ProgressView(title: "Stopping...")
            case .starting:
                ProgressView(title: "Starting...")
            case .configuring, .checking, .notConfigured:
                Text("not reachable")
            }
            Button("configure") {
                isConfigureDisplayed.toggle()
            }
            .sheet(isPresented: $isConfigureDisplayed) {
                IOSConfigureView(isDisplayed: $isConfigureDisplayed)
                    .environmentObject(simulator)
                    .environmentObject(httpProxyManager)
            }
        }
    }
}

struct IOSRunView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IOSRunView()
                .environmentObject(iOSSimulator.preview(state: .stopped(nil)))
            Divider()
            IOSRunView()
                .environmentObject(iOSSimulator.preview(state: .stopped(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "oops!"]))))
            Divider()
            IOSRunView()
                .environmentObject(iOSSimulator.preview(state: .starting))
        }
    }
}
