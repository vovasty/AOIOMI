//
//  AOSRuntimeView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import AOSEmulatorRuntime
import SwiftUI

struct AOSRuntimeView: View {
    @Binding var activityState: ActivityView.ActivityState

    @EnvironmentObject private var runtime: AOSEmulatorRuntime

    var body: some View {
        VStack {
            switch runtime.state {
            case .notInstalled:
                Button("Try Again") {
                    runtime.install()
                }
            default:
                Text("Please wait, it takes several minutes.")
            }
        }
        .onReceive(runtime.$state) { state in
            activityState = state.activity
        }
    }
}

#if DEBUG
    struct AOSRuntimeView_Previews: PreviewProvider {
        static var previews: some View {
            AOSRuntimeView(activityState: .constant(.busy("busy!")))
                .environmentObject(AOSEmulatorRuntime.preview(state: .installed))
        }
    }
#endif
