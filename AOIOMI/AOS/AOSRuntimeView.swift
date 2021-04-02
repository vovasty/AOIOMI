//
//  AOSRuntimeView.swift
//  CoupangMobileApp
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
                EmptyView()
            }
        }
        .onReceive(runtime.$state) { state in
            activityState = state.activity
        }
    }
}

//
// struct AOSRuntimeViewView_Previews: PreviewProvider {
//    static var previews: some View {
//        AOSRuntimeViewView()
//    }
// }
