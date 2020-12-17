//
//  ConfigureView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import SwiftUI

struct ConfigureView: View {
    @EnvironmentObject var emulator: AndroidEmulator

    var body: some View {
        VStack {
            Text("Configuring emulator ...")
        }
        .onAppear {
//            if emulator.state == .notConfigured {
//                emulator.configure()
//            }
        }
        .frame(width: 200, height: 200)
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
    }
}
