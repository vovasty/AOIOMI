//
//  RunView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/11/20.
//

import AndroidEmulator
import SwiftUI

struct RunView: View {
    @EnvironmentObject var emulator: AndroidEmulator
    // case started, starting, stopped, stopping, configuring, checking, notConfigured

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    emulator.start()
                }) {
                    Text("start")
                }
                .disabled(emulator.state == .notConfigured || emulator.state != .stopped)
            }
            HStack {
                Button(action: {
                    let dialog = NSOpenPanel()
                    dialog.title = "Choose an apk to install"
                    dialog.showsResizeIndicator = true
                    dialog.showsHiddenFiles = false
                    dialog.allowsMultipleSelection = false
                    dialog.canChooseDirectories = false
                    dialog.allowedFileTypes = ["apk"]

                    guard dialog.runModal() == .OK else { return }

                    guard let path = dialog.url?.path else { return }
                    emulator.install(apk: path)

                }) {
                    Text("install apk")
                }
                .disabled(emulator.state != .started)
            }
            HStack {
                Button(action: {
                    emulator.configure()
                }) {
                    Text("configure")
                }
                .disabled(emulator.state == .checking || emulator.state == .configuring)
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct RunView_Previews: PreviewProvider {
    static var previews: some View {
        RunView().environmentObject(try! AndroidEmulator())
    }
}
