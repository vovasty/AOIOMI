//
//  ContentView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import AndroidEmulator
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var emulator: AndroidEmulator

    var body: some View {
        ZStack {
            switch emulator.state {
            case .checking:
                StartupView()
            case .configuring, .notConfigured:
                ConfigureView()
            case .started, .stopped, .starting, .stopping:
                RunView()
            }
        }
        .onAppear {
            emulator.check()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
