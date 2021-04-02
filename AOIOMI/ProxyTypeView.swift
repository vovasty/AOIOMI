//
//  ProxyTypeView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/2/21.
//

import SwiftUI
import HTTPProxyManager
import Combine
import MITMProxy

struct ProxyTypeView: View {
    private enum ProxyType: CaseIterable {
        case mitm, charles
        
        var name: String {
            switch self {
            case .charles:
                return "Chales"
            case .mitm:
                return "Built in"
            }
        }
    }
    
    enum ClientType {
        case ios, aos
        
        fileprivate func proxy(port: Int) -> String {
            switch self {
            case .aos:
                return "10.0.2.2:\(port)"
            default:
                return "127.0.0.1:\(port)"
            }
        }
    }

    let clientType: ClientType
    @Binding var proxy: String
    @EnvironmentObject private var charlesProxy: HTTPProxyManager
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var proxyType: ProxyType = .charles
    
    var body: some View {
        Picker("Proxy", selection: $proxyType) {
            ForEach(ProxyType.allCases, id: \.self) {
                Text($0.name)
            }
        }
        .onReceive(Just(proxyType)) { type in
            switch type {
            case .charles:
                proxy = clientType.proxy(port: charlesProxy.port ?? 8888)
            case .mitm:
                proxy = clientType.proxy(port: mitmProxy.port)
            }
        }
    }
}

//struct ProxyPickerView_Previews: PreviewProvider {
//    @State static var proxyType: ProxyType = .charles
//
//    static var previews: some View {
//        ProxyTypeView(proxyType: $proxyType)
//    }
//}
