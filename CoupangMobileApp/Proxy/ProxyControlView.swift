//
//  ProxyControlView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 4/1/21.
//

import Combine
import MITMProxy
import SwiftUI

struct ProxyControlView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var isProxyRunning: Bool = false
    @State private var isDisabled: Bool = false

    var body: some View {
        Toggle(isOn: $isProxyRunning, label: { EmptyView() })
            .toggleStyle(SwitchToggleStyle())
            .disabled(isDisabled)
            .onAppear {
                isProxyRunning = mitmProxy.state == .started
            }
            .onReceive(mitmProxy.$state) { state in
                switch state {
                case .started:
                    isDisabled = false
                    if !isProxyRunning {
                        isProxyRunning = true
                    }
                case .starting, .stopping:
                    isDisabled = true
                case .stopped:
                    isDisabled = false
                    if isProxyRunning {
                        isProxyRunning = false
                    }
                }
            }
            .onReceive(Just(isProxyRunning)) { flag in
                switch mitmProxy.state {
                case .started:
                    guard !flag else { return }
                    mitmProxy.stop()
                case .stopped:
                    guard flag else { return }
                    mitmProxy.start()
                case .starting, .stopping:
                    break
                }
            }
    }
}

struct ProxyControlView_Previews: PreviewProvider {
    static var previews: some View {
        ProxyControlView()
            .environmentObject(MITMProxy.preview)
    }
}
