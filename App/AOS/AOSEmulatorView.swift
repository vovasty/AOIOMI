//
//  RunView.swift
//  AOIOMI
//
//  Created by vlsolome on 10/11/20.
//

import AOSEmulator
import Combine
import HTTPProxyManager
import SwiftUI

struct AOSEmulatorView: View {
    @Binding var activityState: ActivityView.ActivityState

    @EnvironmentObject private var emulator: AOSEmulator
    @EnvironmentObject private var proxyManager: HTTPProxyManager
    @State private var startDisabled = false
    @State private var configureDisabled = false
    @State private var isShowingConfigure = false
    @State private var proxy: HTTPProxyManager.Proxy?

    var body: some View {
        VStack(alignment: .leading) {
            Button("Start") {
                emulator.start()
            }
            .disabled(startDisabled)
            Button("Reconfigure") {
                isShowingConfigure.toggle()
            }
            .disabled(configureDisabled)
            .sheet(isPresented: $isShowingConfigure) {
                DialogView(primaryButton: .default("OK", action: {
                    guard let proxy = proxy else { return }
                    isShowingConfigure.toggle()
                    emulator.configure(proxy: proxy.string,
                                       caPath: proxyManager.caPaths)
                }), secondaryButton: .cancel("Cancel", action: {
                    proxy = nil
                    isShowingConfigure.toggle()
                })) {
                    ProxyTypeView(clientType: .aos, proxy: $proxy)
                        .environmentObject(proxyManager)
                }
                .padding()
            }
        }
        .onReceive(Just(emulator.state)) { state in
            switch state {
            case .stopped:
                startDisabled = false
                configureDisabled = false
            case .configuring, .checking, .started, .stopping, .starting:
                startDisabled = true
                configureDisabled = true
            case .notConfigured:
                startDisabled = true
                configureDisabled = false
            }
            activityState = state.activity
        }
    }
}

#if DEBUG
    struct AOSEmulatorView_Previews: PreviewProvider {
        static var previews: some View {
            let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])

            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .configuring))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .checking))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .stopped(nil)))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .stopped(error)))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .stopping))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .notConfigured(nil)))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .notConfigured(error)))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .starting))
            AOSEmulatorView(activityState: .constant(.text("some")))
                .environmentObject(AOSEmulator.preview(state: .started))
        }
    }
#endif
