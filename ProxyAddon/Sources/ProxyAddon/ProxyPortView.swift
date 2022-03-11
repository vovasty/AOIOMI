//
//  ProxyPortView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import CommonUI
import MITMProxy
import SwiftUI
import SwiftyUserDefaults

struct ProxyPortView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var isShowingPortChange = false
    @State private var proxyPort = String(Defaults.proxyPort)
    @State private var proxyExternalPort = String(Defaults.proxyExternalPort ?? 0)
    @State private var proxyExternalHost = Defaults.proxyExternalHost ?? ""
    @State private var proxyExternalEnabled = Defaults.proxyExternalEnabled

    var body: some View {
        HStack {
            Text("Proxy Port:")
            Button(action: {
                isShowingPortChange.toggle()
            }) {
                Text(String(Defaults.proxyPort))
            }.sheet(isPresented: $isShowingPortChange) {
                DialogView(primaryButton: .default("OK", action: {
                    guard let proxyPort = Int(proxyPort) else { return }
                    Defaults.proxyPort = proxyPort
                    Defaults.proxyExternalPort = Int(proxyExternalPort)
                    Defaults.proxyExternalHost = proxyExternalHost
                    Defaults.proxyExternalEnabled = proxyExternalEnabled
                    mitmProxy.port = Defaults.proxyPort
                    if Defaults.proxyExternalEnabled {
                        mitmProxy.upstreamProxyPort = Defaults.proxyExternalPort
                        mitmProxy.upstreamProxyHost = Defaults.proxyExternalHost
                    } else {
                        mitmProxy.upstreamProxyPort = nil
                        mitmProxy.upstreamProxyHost = nil
                    }
                    mitmProxy.restart()
                    isShowingPortChange.toggle()
                }), secondaryButton: .cancel("Cancel", action: {
                    proxyPort = String(Defaults.proxyPort)
                    isShowingPortChange.toggle()
                })) {
                    VStack(alignment: .leading) {
                        Text("Proxy")
                        TextField("Proxy Port", text: $proxyPort)
                        Text("External Proxy")
                        Toggle("Enabled", isOn: $proxyExternalEnabled)
                        HStack {
                            TextField("Host", text: $proxyExternalHost).frame(minWidth: 120)
                            TextField("Port", text: $proxyExternalPort)
                        }
                        .disabled(!proxyExternalEnabled)
                    }
                }
                .padding()
            }
        }
    }
}

#if DEBUG
    struct ProxyPortView_Previews: PreviewProvider {
        static var previews: some View {
            ProxyPortView()
                .environmentObject(MITMProxy.preview)
        }
    }
#endif
