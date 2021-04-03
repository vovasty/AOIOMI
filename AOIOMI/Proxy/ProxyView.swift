//
//  ProxyView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import MITMProxy
import SwiftUI

struct ProxyView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var activityState: ActivityView.ActivityState = MITMProxy.State.stopped.activity

    var body: some View {
        VStack(alignment: .leading) {
            ActivityView(style: .proxy, state: $activityState)
            ProxyPortView()
            Spacer()
        }
        .padding()
        .onAppear {
            activityState = mitmProxy.state.activity
        }
        .onReceive(mitmProxy.$state) { state in
            activityState = state.activity
        }
    }
}

#if DEBUG
    struct ProxySettingsView_Previews: PreviewProvider {
        static var previews: some View {
            ProxyView()
                .environmentObject(UserSettings())
                .environmentObject(MITMProxy.preview)
        }
    }
#endif
