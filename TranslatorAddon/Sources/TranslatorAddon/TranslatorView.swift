//
//  TranslatorView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import Combine
import MITMProxy
import SwiftUI

public struct TranslatorView: View {
    @EnvironmentObject private var translatorStore: TranslatorStore

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            Toggle("Translate", isOn: $translatorStore.isActive)
                .toggleStyle(SwitchToggleStyle())
            ForEach($translatorStore.items) { $item in
                Toggle(item.name, isOn: $item.isActive)
            }
            .disabled(!translatorStore.isActive)
            Spacer()
        }
        .padding()
    }
}

// #if DEBUG
//    struct TranslateView_Previews: PreviewProvider {
//        static var previews: some View {
//            TranslateView()
//                .environmentObject(ProxyAddonManager.preview)
//        }
//    }
// #endif
