//
//  AppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 12/18/20.
//

import AndroidEmulator
import SwiftUI

private struct InstallAppView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("install apk") {
            let dialog = NSOpenPanel()
            dialog.title = "Choose an apk to install"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.allowsMultipleSelection = false
            dialog.canChooseDirectories = false
            dialog.allowedFileTypes = ["apk"]

            guard dialog.runModal() == .OK else { return }

            guard let path = dialog.url else { return }
            appManager.install(apk: path)
        }
    }
}

private struct RunAppView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("run app") {
            appManager.start()
        }
    }
}

private struct PCIDView: View {
    @EnvironmentObject var appManager: AppManager
    let pcid: String?

    var body: some View {
        if let pcid = pcid {
            HStack(spacing: 8) {
                Text("PCID")
                    .font(Font.caption.weight(.bold))
                Text(pcid)
                    .font(.caption)
                    .frame(maxWidth: 50)
                    .lineLimit(1)
                    .truncationMode(.middle)
                SwiftUI.Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(pcid, forType: .string)
                }) {
                    Text("copy")
                        .font(.caption)
                }
                .buttonStyle(DefaultButtonStyle())
            }
        } else {
            HStack(spacing: 8) {
                Text("Can't get pcid.\nTry to run the app.")
                SwiftUI.Button("check") {
                    self.appManager.check()
                }
                .buttonStyle(DefaultButtonStyle())
                .font(.caption)
            }
        }
    }
}

struct AOSAppStateView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        switch appManager.state {
        case .installing:
            InstallAppView()
                .disabled(true)
            RunAppView()
                .disabled(true)
            Text("installing app")
                .frame(height: 50)
        case .checking:
            InstallAppView()
                .disabled(true)
            RunAppView()
                .disabled(true)
            Text("checking app")
                .frame(height: 50)
        case let .notInstalled(error):
            InstallAppView()
            RunAppView()
                .disabled(true)
            HStack(spacing: 8) {
                if let error = error {
                    Text("failed to install apk: \(error.localizedDescription)")
                } else {
                    Text("app is not installed")
                }
                SwiftUI.Button("check") {
                    self.appManager.check()
                }
                .buttonStyle(DefaultButtonStyle())
                .font(.caption)
            }
            .frame(height: 50)
        case .installed:
            InstallAppView()
            RunAppView()
            PCIDView(pcid: appManager.pcid)
                .frame(height: 50)
        }
    }
}

struct AOSAppStateView_Previews: PreviewProvider {
    static var previews: some View {
        AOSAppStateView()
    }
}