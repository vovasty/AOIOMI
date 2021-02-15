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
    @State var deviceType: SimctlList.DeviceType = .empty
    var isDisplayed: Binding<Bool>
    private var isDialog: Bool

    init() {
        self.init(isDisplayed: Binding<Bool>(get: { true }, set: { _ in }))
        isDialog = false
    }

    init(isDisplayed: Binding<Bool>) {
        self.isDisplayed = isDisplayed
        isDialog = true
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Picker("Device", selection: $deviceType) {
                ForEach(simulator.deviceTypes, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(DefaultPickerStyle())

            if isDialog {
                HStack {
                    SwiftUI.Button("Configure") {
                        isDisplayed.wrappedValue.toggle()
                        simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caURL)
                    }
                    SwiftUI.Button("Cancel") {
                        isDisplayed.wrappedValue.toggle()
                    }
                }
            } else {
                SwiftUI.Button(action: {
                    isDisplayed.wrappedValue.toggle()
                    simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caURL)
                }) {
                    Text("Configure")
                        .frame(width: 126)
                }
                .disabled(deviceType == .empty)
            }
        }
        .frame(maxWidth: 200)
        .padding()
    }
}

#if DEBUG
    struct IOSConfigureView_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                IOSConfigureView()
                    .environmentObject(iOSSimulator.preview(deviceTypes: [
                        SimctlList.DeviceType(name: "iPhone"),
                        SimctlList.DeviceType(name: "iPad"),
                    ]))
                IOSConfigureView(isDisplayed: .constant(false))
                    .environmentObject(iOSSimulator.preview(deviceTypes: [
                        SimctlList.DeviceType(name: "iPhone"),
                        SimctlList.DeviceType(name: "iPad"),
                    ]))
            }
        }
    }
#endif
