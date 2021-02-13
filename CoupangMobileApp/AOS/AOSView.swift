//
//  AOSView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import AndroidEmulator
import HTTPProxyManager
import SwiftUI

struct AOSView: View {
    @EnvironmentObject var emulator: AndroidEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager

    var body: some View {
        VStack {
            switch emulator.state {
            case .checking:
                ProgressView(title: "Checking...")
            case .configuring:
                ProgressView(title: "Configuring...")
            case let .notConfigured(error):
                ErrorView(error: error)
                Button("configure") {
                    emulator.configure(proxy: proxyManager.proxy(type: .aos)?.asString, caPath: proxyManager.caURL)
                }
            case .started, .stopped, .starting, .stopping:
                AOSRunView()
            }
        }
    }
}

struct AOSView_Previews: PreviewProvider {
    static var previews: some View {
        AOSView()
    }
}
