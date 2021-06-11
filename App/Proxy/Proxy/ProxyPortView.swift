//
//  ProxyPortView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import MITMProxy
import SwiftUI

struct ProxyPortView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var isShowingPortChange: Bool = false
    @State private var proxyPort: String = ""
    @State private var externalProxyPort: String = ""
    @State private var externalProxyHost: String = ""

    var body: some View {
        HStack {
            Text("Proxy Port:")
            Button(action: {
                isShowingPortChange.toggle()
            }) {
                Text(String(userSettings.proxyPort))
            }.sheet(isPresented: $isShowingPortChange) {
                DialogView(primaryButton: .default("OK", action: {
                    guard let proxyPort = Int(proxyPort) else { return }
                    userSettings.proxyPort = proxyPort
                    userSettings.proxyExternalPort = Int(externalProxyPort)
                    userSettings.proxyExternalHost = externalProxyHost
                    mitmProxy.port = userSettings.proxyPort
                    mitmProxy.upstreamProxyPort = userSettings.proxyExternalPort
                    mitmProxy.upstreamProxyHost = userSettings.proxyExternalHost
                    mitmProxy.restart()
                    isShowingPortChange.toggle()
                }), secondaryButton: .cancel("Cancel", action: {
                    proxyPort = String(userSettings.proxyPort)
                    isShowingPortChange.toggle()
                })) {
                    VStack {
                        TextField("Proxy Port", text: $proxyPort)
                        HStack {
                            TextField("External Proxy Host", text: $externalProxyPort)
                            TextField("Port", text: $externalProxyHost)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            proxyPort = String(userSettings.proxyPort)
        }
    }
}

#if DEBUG
    struct ProxyPortView_Previews: PreviewProvider {
        static var previews: some View {
            ProxyPortView()
                .environmentObject(MITMProxy.preview)
                .environmentObject(UserSettings())
        }
    }
#endif
