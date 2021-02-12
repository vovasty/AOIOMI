//
//  IOSRunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import iOSSimulator
import SwiftUI

struct IOSRunView: View {
    @EnvironmentObject var simulator: iOSSimulator

    var body: some View {
        switch simulator.state {
        case .started:
            IOSAppStateView()
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
//        Button("configure") {
//            simulator.configure()
//        }
    }
}

struct IOSRunView_Previews: PreviewProvider {
    static var previews: some View {
        IOSRunView()
    }
}
