//
//  TranslateView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import Combine
import MITMProxy
import SwiftUI

struct TranslateView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @EnvironmentObject private var userSettings: UserSettings

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Translate", isOn: $userSettings.isTranslating)
                .toggleStyle(SwitchToggleStyle())
            ForEach(userSettings.translateDefinitions.indices, id: \.self) {
                Toggle(userSettings.translateDefinitions[$0].name, isOn: self.$userSettings.translateDefinitions[$0].isChecked)
            }
            .disabled(!userSettings.isTranslating)
            Spacer()
        }
        .padding()
        .onReceive(Just(userSettings.isTranslating)) { _ in
            try? mitmProxy.addonManager.set(addons: userSettings.addons)
        }
        .onReceive(Just(userSettings.translateDefinitions)) { _ in
            try? mitmProxy.addonManager.set(addons: userSettings.addons)
        }
    }
}

#if DEBUG
    struct TranslateView_Previews: PreviewProvider {
        static var previews: some View {
            TranslateView()
                .environmentObject(UserSettings())
                .environmentObject(MITMProxy.preview)
        }
    }
#endif
