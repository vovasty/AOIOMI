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
    @State private var proxyExternalPort: String = ""
    @State private var proxyExternalHost: String = ""

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
                    userSettings.proxyExternalPort = Int(proxyExternalPort)
                    userSettings.proxyExternalHost = proxyExternalHost
                    mitmProxy.port = userSettings.proxyPort
                    if userSettings.proxyExternalEnabled {
                        mitmProxy.upstreamProxyPort = userSettings.proxyExternalPort
                        mitmProxy.upstreamProxyHost = userSettings.proxyExternalHost
                    } else {
                        mitmProxy.upstreamProxyPort = nil
                        mitmProxy.upstreamProxyHost = nil
                    }
                    mitmProxy.restart()
                    isShowingPortChange.toggle()
                }), secondaryButton: .cancel("Cancel", action: {
                    proxyPort = String(userSettings.proxyPort)
                    isShowingPortChange.toggle()
                })) {
                    VStack(alignment: .leading) {
                        Text("Proxy")
                        TextField("Proxy Port", text: $proxyPort)
                        Text("External Proxy")
                        Toggle("Enabled", isOn: $userSettings.proxyExternalEnabled)
                        HStack {
                            TextField("Host", text: $proxyExternalHost).frame(minWidth: 120)
                            TextField("Port", text: $proxyExternalPort)
                        }
                        .disabled(!userSettings.proxyExternalEnabled)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            proxyPort = String(userSettings.proxyPort)
            if let proxyExternalPort = userSettings.proxyExternalPort {
                self.proxyExternalPort = String(proxyExternalPort)
            }
            if let proxyExternalHost = userSettings.proxyExternalHost {
                self.proxyExternalHost = proxyExternalHost
            }
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
