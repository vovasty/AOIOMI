//
//  IOSConfigureView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import HTTPProxyManager
import iOSSimulator
import SwiftUI

struct IOSConfigureView: View {
    @EnvironmentObject var simulator: iOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @State private var deviceType: SimctlList.DeviceType = .empty

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
    }
}

#if DEBUG
    struct IOSConfigureView_Previews: PreviewProvider {
        static var previews: some View {
            IOSConfigureView()
                .environmentObject(iOSSimulator.preview(deviceTypes: [
                    SimctlList.DeviceType(name: "iPhone"),
                    SimctlList.DeviceType(name: "iPad"),
                ]))
        }
    }
#endif
