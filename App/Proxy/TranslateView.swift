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
            TranslateDefinitionListView(definitions: $userSettings.translateDefinitions)
                .disabled(!userSettings.isTranslating)
            Spacer()
        }
        .padding()
        .onReceive(Just(userSettings.isTranslating)) { _ in
            mitmProxy.addons = userSettings.addons
        }
        .onReceive(Just(userSettings.translateDefinitions)) { _ in
            mitmProxy.addons = userSettings.addons
        }
    }
}

struct TranslateView_Previews: PreviewProvider {
    static var previews: some View {
        TranslateView()
    }
}
