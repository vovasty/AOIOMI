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
    // case started, starting, stopped, stopping, configuring, checking, notConfigured

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    emulator.start()
                }) {
                    Text("start")
                }
                .disabled(emulator.state == .notConfigured || emulator.state != .stopped)
            }
            HStack {
                Button(action: {
                    emulator.stop()
                }) {
                    Text("stop")
                }
                .disabled(emulator.state == .notConfigured || emulator.state != .started)
            }
            HStack {
                Button(action: {
                    emulator.configure()
                }) {
                    Text("configure")
                }
                .disabled(emulator.state == .checking || emulator.state == .configuring)
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct RunView_Previews: PreviewProvider {
    static var previews: some View {
        RunView()
    }
}
