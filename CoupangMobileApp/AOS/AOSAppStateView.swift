//
//  AppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 12/18/20.
//

import AOSEmulator
import Combine
import SwiftUI
import SWXMLHash

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

struct AOSAppStateView: View {
    @EnvironmentObject var appManager: AppManager
    @Binding var activityState: ActivityView.ActivityState

    @State private var installAppDisabled = false
    @State private var isAppNonOperational = false
    @State private var isShowingPCID = false
    @State private var wantToShowPCID = false

    var body: some View {
        VStack {
            InstallAppView()
                .disabled(installAppDisabled)
            Button("Open App") {
                appManager.start()
            }
            .disabled(isAppNonOperational)
            Button("Show PCID") {
                wantToShowPCID = true
                appManager.check()
            }
            .disabled(isAppNonOperational)
            .alert(isPresented: $isShowingPCID) {
                Alert(
                    title: Text("PCID"),
                    message: Text(appManager.state.PCID ?? "not available"),
                    primaryButton: .default(Text("Copy")) {
                        let pasteboard = NSPasteboard.general
                        pasteboard.declareTypes([.string], owner: nil)
                        pasteboard.setString(appManager.state.PCID ?? "not available", forType: .string)
                        wantToShowPCID = false
                    },
                    secondaryButton: .cancel {
                        wantToShowPCID = false
                    }
                )
            }
        }
        .onReceive(Just(appManager.state)) { state in
            switch state {
            case .notInstalled:
                installAppDisabled = false
                isAppNonOperational = true
            case .installed:
                installAppDisabled = false
                isAppNonOperational = false
                isShowingPCID = wantToShowPCID
            case .installing, .checking:
                installAppDisabled = true
                isAppNonOperational = true
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

    var PCID: String? {
        switch self {
        case let .installed(xml):
            do {
                return try xml?["map"]["string"].withAttribute("name", "wl_pcid").element?.text
            } catch {
                return nil
            }
        default:
            return nil
        }
    }
}

struct AOSAppStateView_Previews: PreviewProvider {
    static var xml: XMLIndexer {
        let xmlString = """
        <map>
          <string name="wl_pcid">1234567890</string>
        </map>
        """
        return SWXMLHash.config {
            config in
            config.shouldProcessLazily = true
        }.parse(xmlString.data(using: .utf8)!)
    }

    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])
        AOSAppStateView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .checking))
        AOSAppStateView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .notInstalled(nil)))
        AOSAppStateView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .notInstalled(error)))
        AOSAppStateView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .installing))
        AOSAppStateView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .installed(xml)))
    }
}
