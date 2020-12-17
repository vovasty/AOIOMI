//
//  RunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import SwiftUI

struct RunView: View {
    @EnvironmentObject var emulator: AndroidEmulator

    var body: some View {
        VStack {
            switch emulator.state {
            case .started:
                AppStateView()
            case let .stopped(error):
                Button("start") {
                    emulator.start()
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
            Button("configure") {
                emulator.configure()
            }
        }

        .frame(width: 200, height: 200)
    }
}

struct RunView_Previews: PreviewProvider {
    static var previews: some View {
        RunView().environmentObject(try! AndroidEmulator())
    }
}
