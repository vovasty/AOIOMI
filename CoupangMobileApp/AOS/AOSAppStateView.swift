//
//  AppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 12/18/20.
//

import AndroidEmulator
import Combine
import SwiftUI

private struct InstallAppView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        switch appManager.state {
        case .installed, .installing, .checking:
            Button("Reinstall App", action: install)
        case .notInstalled:
            Button("Install App", action: install)
        }
    }

    private func install() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose an Apk to Install"
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

private struct PCIDView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        HStack(spacing: 8) {
            Text("PCID")
                .font(Font.caption.weight(.bold))
            if let pcid = appManager.pcid {
                Text(pcid)
                    .font(.caption)
                    .frame(maxWidth: 50)
                    .lineLimit(1)
                    .truncationMode(.middle)
                SwiftUI.Button("copy") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(pcid, forType: .string)
                }
                .buttonStyle(DefaultButtonStyle())
                .font(.caption)
            } else {
                Text("No PCID. Try to Open App.")
                    .font(.caption)
                    .frame(maxWidth: 50)
                    .lineLimit(1)
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
    @State private var activityState = ActivityView.ActivityState.text("")
    @State private var installAppDisabled = false
    @State private var openAppDisabled = false

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
            PCIDView()
            InstallAppView()
                .disabled(installAppDisabled)
            Button("Open App") {
                appManager.start()
            }
            .disabled(openAppDisabled)
        }
        .onReceive(Just(appManager.state)) { state in
            switch state {
            case .notInstalled:
                installAppDisabled = false
                openAppDisabled = true
            case .installed:
                installAppDisabled = false
                openAppDisabled = false
            case .installing, .checking:
                installAppDisabled = true
                openAppDisabled = true
            }

            activityState = state.asActivity
        }
    }
}

private extension AppManager.State {
    var asActivity: ActivityView.ActivityState {
        switch self {
        case let .notInstalled(error):
            if let error = error {
                return .error("App is Not Installed", error)
            } else {
                return .text("App is Not Installed")
            }
        case .installed:
            return .text("App is Installed")
        case .installing:
            return .busy("Installing App...")
        case .checking:
            return .busy("Checking App...")
        }
    }
}

struct AOSAppStateView_Previews: PreviewProvider {
    static var previews: some View {
        AOSAppStateView()
    }
}
