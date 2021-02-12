//
//  iOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import iOSSimulator
import SwiftUI

struct IOSView: View {
    @EnvironmentObject var simulator: iOSSimulator

    var body: some View {
        ZStack {
            switch simulator.state {
            case .checking:
                ProgressView(title: "Checking...")
            case .configuring:
                ProgressView(title: "Configuring...")
            case .notConfigured:
                IOSConfigureView()
            case .started, .stopped, .starting, .stopping:
                IOSRunView()
            }
        }
    }
}

struct IOSView_Previews: PreviewProvider {
    static var previews: some View {
        IOSView()
    }
}
