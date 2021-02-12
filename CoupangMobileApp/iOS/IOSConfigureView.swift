//
//  IOSConfigureView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI
import iOSSimulator

struct IOSConfigureView: View {
    @EnvironmentObject var simulator: iOSSimulator
    @State var deviceType:  SimctlList.DeviceType = .empty
    
    var body: some View {
        VStack {
            Picker("device", selection: $deviceType) {
                ForEach(simulator.deviceTypes, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            Button("configure") {
                simulator.configure(deviceType: deviceType)
            }
            .disabled(deviceType == .empty)
        }
    }
}

struct IOSConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        IOSConfigureView()
    }
}
