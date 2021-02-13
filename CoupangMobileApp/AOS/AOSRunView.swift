//
//  RunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import HTTPProxyManager
import SwiftUI

struct AOSRunView: View {
    @EnvironmentObject var emulator: AndroidEmulator
    @EnvironmentObject var proxyManager: HTTPProxyManager

    var body: some View {
        VStack {
            switch emulator.state {
            case .started:
                AOSAppStateView()
            case let .stopped(error):
                ErrorView(error: error)
                Button("start") {
                    emulator.start()
                }
            case .stopping:
                Text("stopping")
            case .starting:
                Text("starting")
            case .configuring, .checking, .notConfigured:
                Text("not reachable")
            }
            Button("configure") {
                emulator.configure(proxy: proxyManager.proxy(type: .aos)?.asString, caPath: proxyManager.caURL)
            }
        }

        .frame(width: 200, height: 200)
    }
}

struct AOSRunView_Previews: PreviewProvider {
    static var previews: some View {
        AOSRunView().environmentObject(try! AndroidEmulator())
    }
}
