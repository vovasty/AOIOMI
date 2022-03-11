//
//  ProxyView.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import CommonUI
import MITMProxy
import SwiftUI

public struct ProxyView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @State private var activityState: ActivityView.ActivityState = MITMProxy.State.stopped.activity

    public init() {}

    public var body: some View {
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
                .environmentObject(MITMProxy.preview)
        }
    }
#endif
