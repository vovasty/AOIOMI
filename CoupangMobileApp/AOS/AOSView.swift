//
//  AOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import AndroidEmulator
import SwiftUI

struct AOSView: View {
    @EnvironmentObject var emulator: AndroidEmulator

    var body: some View {
        ZStack {
            switch emulator.state {
            case .checking:
                ProgressView(title: "Checking...")
            case .configuring:
                ProgressView(title: "Configuring...")
            case .notConfigured:
                Button("configure") {
                    emulator.configure()
                }
            case .started, .stopped, .starting, .stopping:
                AOSRunView()
            }
        }
        .onAppear {
            emulator.check()
        }
    }
}

struct AOSView_Previews: PreviewProvider {
    static var previews: some View {
        AOSView()
    }
}
