//
//  IOSConfigureView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSConfigureView: View {
    @EnvironmentObject var simulator: IOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @State private var deviceType: SimctlList.DeviceType = .empty
    @Binding var activityState: ActivityView.ActivityState

    var body: some View {
        VStack(alignment: .trailing) {
            Picker("Device", selection: $deviceType) {
                ForEach(simulator.deviceTypes, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            SwiftUI.Button(action: {
                simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caURL)
            }) {
                Text("Configure")
            }
            .disabled(deviceType == .empty)
        }
        .onReceive(Just(simulator.state)) { state in
            activityState = state.activity
        }
    }
}

#if DEBUG
    struct IOSConfigureView_Previews: PreviewProvider {
        static var previews: some View {
            IOSConfigureView(activityState: .constant(.text("wee")))
                .environmentObject(IOSSimulator.preview(deviceTypes: [
                    SimctlList.DeviceType(name: "iPhone"),
                    SimctlList.DeviceType(name: "iPad"),
                ]))
        }
    }
#endif
