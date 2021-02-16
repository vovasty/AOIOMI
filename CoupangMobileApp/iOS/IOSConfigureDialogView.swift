//
//  IOSConfigureDialogView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/15/21.
//

import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSConfigureDialogView: View {
    @EnvironmentObject var simulator: IOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @Binding var isDisplayed: Bool

    @State private var deviceType: SimctlList.DeviceType = .empty
    var body: some View {
        VStack(alignment: .trailing) {
            Picker("Device", selection: $deviceType) {
                ForEach(simulator.deviceTypes, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(DefaultPickerStyle())

            HStack {
                SwiftUI.Button("Configure") {
                    isDisplayed.toggle()
                    simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caURL)
                }
                SwiftUI.Button("Cancel") {
                    isDisplayed.toggle()
                }
            }
        }
        .padding()
    }
}

struct IOSConfigureDialogView_Previews: PreviewProvider {
    static var previews: some View {
        IOSConfigureDialogView(isDisplayed: .constant(true))
            .environmentObject(IOSSimulator.preview(deviceTypes: [
                SimctlList.DeviceType(name: "iPhone"),
                SimctlList.DeviceType(name: "iPad"),
            ]))
    }
}
