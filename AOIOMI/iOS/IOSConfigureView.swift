//
//  IOSConfigureDialogView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/15/21.
//

import HTTPProxyManager
import IOSSimulator
import SwiftUI

struct IOSConfigureView: View {
    var isDisplayed: Binding<Bool>
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var httpProxyManager: HTTPProxyManager
    @State private var deviceType: SimctlList.DeviceType = .empty
    @State private var proxy: HTTPProxyManager.Proxy?
    private var cancelButton: DialogButton?

    init(isDisplayed: Binding<Bool>, isCancellable: Bool) {
        self.isDisplayed = isDisplayed
        if isCancellable {
            cancelButton = .cancel("Cancel") {
                isDisplayed.wrappedValue.toggle()
            }
        }
    }

    var body: some View {
        DialogView(primaryButton: .default("Configure", disabled: deviceType == .empty, action: {
            guard deviceType != .empty else { return } // WTF????
            userSettings.iosProxy = proxy
            simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caPaths)
            isDisplayed.wrappedValue.toggle()
        }), secondaryButton: cancelButton) {
            ProxyTypeView(clientType: .ios, proxy: $proxy)
            Picker("Device", selection: $deviceType) {
                ForEach(simulator.deviceTypes, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        }
    }
}

#if DEBUG
    struct IOSConfigureView_Previews: PreviewProvider {
        static var previews: some View {
            IOSConfigureView(isDisplayed: .constant(true), isCancellable: false)
                .environmentObject(IOSSimulator.preview(deviceTypes: [
                    SimctlList.DeviceType(name: "iPhone"),
                    SimctlList.DeviceType(name: "iPad"),
                ]))
        }
    }
#endif
