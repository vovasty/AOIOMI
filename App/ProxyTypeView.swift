//
//  ProxyTypeView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/2/21.
//

import Combine
import HTTPProxyManager
import SwiftUI

private extension HTTPProxyManager.ProxyType {
    var name: String {
        switch self {
        case .charles:
            return "Chales"
        case .mitm:
            return "Built in"
        }
    }
}

struct ProxyTypeView: View {
    let clientType: HTTPProxyManager.ClientType
    @Binding var proxy: HTTPProxyManager.Proxy?
    @EnvironmentObject private var httpProxyManager: HTTPProxyManager
    @State private var proxyType: HTTPProxyManager.ProxyType = .mitm

    var body: some View {
        Picker("Proxy", selection: $proxyType) {
            ForEach(httpProxyManager.proxyList, id: \.self) {
                Text($0.name)
            }
        }
        .onReceive(Just(proxyType)) { _ in
            proxy = httpProxyManager.proxy(client: clientType, proxy: proxyType)
        }
    }
}

#if DEBUG
    struct ProxyPickerView_Previews: PreviewProvider {
        @State static var proxy: HTTPProxyManager.Proxy? = nil

        static var previews: some View {
            ProxyTypeView(clientType: .ios, proxy: $proxy)
                .environmentObject(HTTPProxyManager.preview())
        }
    }
#endif
