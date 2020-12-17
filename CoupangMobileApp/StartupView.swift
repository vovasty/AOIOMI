//
//  StartupView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import SwiftUI

struct StartupView: View {
    @EnvironmentObject var emulator: AndroidEmulator

    var body: some View {
        VStack {
            Text("Checking...")
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}
