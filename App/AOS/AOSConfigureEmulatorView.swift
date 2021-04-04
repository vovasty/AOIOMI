//
//  AOSConfigureEmulatorView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/3/21.
//

import AOSEmulator
import HTTPProxyManager
import SwiftUI

struct AOSConfigureEmulatorView: View {
    var isDisplayed: Binding<Bool>
    @EnvironmentObject private var emulator: AOSEmulator
    @EnvironmentObject private var proxyManager: HTTPProxyManager
    @State private var proxy: HTTPProxyManager.Proxy?
    private var cancelButton: DialogButton?

    init(isDisplayed: Binding<Bool>, isCancellable: Bool) {
        self.isDisplayed = isDisplayed
        if isCancellable {
            cancelButton = .cancel("Cancel") {
                isDisplayed.wrappedValue.toggle()
            }
        }
    }

    var body: some View {
        DialogView(primaryButton: .default("Configure", action: {
            isDisplayed.wrappedValue.toggle()
            guard let proxy = proxy else { return }
            emulator.configure(proxy: proxy.string,
                               caPath: proxyManager.caPaths)
        }), secondaryButton: cancelButton) {
            ProxyTypeView(clientType: .aos, proxy: $proxy)
        }
    }
}

#if DEBUG
    struct AOSConfigureEmulatorView_Previews: PreviewProvider {
        static var previews: some View {
            AOSConfigureEmulatorView(isDisplayed: .constant(true), isCancellable: false)
                .environmentObject(HTTPProxyManager.preview())
                .environmentObject(AOSEmulator.preview())
        }
    }
#endif
