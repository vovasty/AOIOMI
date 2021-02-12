//
//  IOSRunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI
import iOSSimulator

struct IOSRunView: View {
    @EnvironmentObject var simulator: iOSSimulator
    
    var body: some View {
        switch simulator.simulatorState {
        case .started:
            IOSAppStateView()
        case let .stopped(error):
            Button("start") {
                simulator.start()
            }
            if let error = error {
                Text("Error: \(error.localizedDescription)")
            }
        case .stopping:
            Text("stopping")
        case .starting:
            Text("starting")
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
