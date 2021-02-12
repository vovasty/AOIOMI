//
//  iOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI
import iOSSimulator

struct IOSView: View {
    @EnvironmentObject var simulator: iOSSimulator
    
    var body: some View {
        ZStack {
            switch simulator.simulatorState {
            case .checking:
                StartupView()
            case .configuring:
                ConfigureView()
            case .notConfigured:
                IOSConfigureView()
            case .started, .stopped, .starting, .stopping:
                IOSRunView()
            }
        }
        .onAppear {
            simulator.check()
        }
    }
}

struct IOSView_Previews: PreviewProvider {
    static var previews: some View {
        IOSView()
    }
}
