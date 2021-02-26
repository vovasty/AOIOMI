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
    @EnvironmentObject var simulator: IOSSimulator
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    var isDisplayed: Binding<Bool>
    private var cancelButton: DialogButton?

    init(isDisplayed: Binding<Bool>, isCancellable: Bool) {
        self.isDisplayed = isDisplayed
        if isCancellable {
            cancelButton = .cancel("Cancel") {
                isDisplayed.wrappedValue.toggle()
            }
        }
    }

    @State private var deviceType: SimctlList.DeviceType = .empty
    var body: some View {
        DialogView(primaryButton: .default("Configure", disabled: deviceType == .empty, action: {
            guard deviceType != .empty else { return } // WTF????
            simulator.configure(deviceType: deviceType, caURL: httpProxyManager.caURL)
            isDisplayed.wrappedValue.toggle()
        }), secondaryButton: cancelButton) {
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
