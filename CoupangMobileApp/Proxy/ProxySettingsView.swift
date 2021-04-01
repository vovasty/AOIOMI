//
//  ProxySettingsView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import SwiftUI

struct ProxySettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @State private var isShowingPortChange: Bool = false
    @State private var proxyPort: String = ""
    
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
                    isShowingPortChange.toggle()
                }), secondaryButton: .cancel("Cancel", action: {
                    proxyPort = String(userSettings.proxyPort)
                    isShowingPortChange.toggle()
                })) {
                    TextField("Proxy Port", text: $proxyPort)
                }
                .padding()
            }
        }
        .onAppear {
            proxyPort = String(userSettings.proxyPort)
        }
    }
}

struct ProxySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProxySettingsView()
            .environmentObject(UserSettings())
    }
}
