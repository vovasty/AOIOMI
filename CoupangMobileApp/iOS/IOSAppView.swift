//
//  IOSAppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import HTTPProxyManager
import IOSSimulator
import SwiftUI

private struct InstallAppView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var httpProxyManager: HTTPProxyManager

    var body: some View {
        switch appManager.state {
        case .installed, .installing, .starting:
            Button("Reinstall App", action: install)
        case .notInstalled:
            Button("Install App", action: install)
        }
    }

    private func install() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose an app to install"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["app"]

        guard dialog.runModal() == .OK else { return }

        guard let url = dialog.url else { return }
        appManager.install(app: url, defaults: httpProxyManager.iosDefaults)
    }
}

struct IOSAppView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @Binding var activityState: ActivityView.ActivityState

    @State private var dragOver = false
    @State private var isAppNonOperational = false
    @State private var installAppDisabled = false
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
            case .installed:
                isAppNonOperational = false
                installAppDisabled = false
                isShowingPCID = wantToShowPCID
            case .installing:
                isAppNonOperational = true
                installAppDisabled = true
            case .starting, .notInstalled:
                isAppNonOperational = true
                installAppDisabled = false
            }

            activityState = state.asActivity
        }
        .onDrop(of: [String(kUTTypeFileURL)], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: String(kUTTypeFileURL), completionHandler: { data, _ in
                guard let data = data, let path = String(data: data, encoding: .utf8), let url = URL(string: path) else { return }
                guard url.path.hasSuffix(".app") else { return }
                appManager.install(app: url, defaults: httpProxyManager.iosDefaults)
            })
            return true
        }
        .onAppear {
            appManager.check()
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
        case let .installed(error, _, _):
            if let error = error {
                return .error("App is Installed", error)
            } else {
                return .text("App is Installed")
            }
        case .installing:
            return .busy("Installing App...")
        case .starting:
            return .busy("Staring App...")
        }
    }

    var PCID: String? {
        switch self {
        case let .installed(_, _, defaults):
            return (defaults as? [String: Any])?["molly.logger.client.key"] as? String
        default:
            return nil
        }
    }
}

struct IOSAppStateView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])

        IOSAppView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .installed(error: nil, dataPath: nil, defaults: nil)))
            .environmentObject(HTTPProxyManager.preview())
        IOSAppView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .notInstalled(error)))
            .environmentObject(HTTPProxyManager.preview())
        IOSAppView(activityState: .constant(.text("some")))
            .environmentObject(AppManager.preview(state: .installed(error: error, dataPath: nil, defaults: nil)))
            .environmentObject(HTTPProxyManager.preview())
        InstallAppView()
            .environmentObject(AppManager.preview(state: .installed(error: nil, dataPath: nil, defaults: nil)))
            .environmentObject(HTTPProxyManager.preview())
        InstallAppView()
            .environmentObject(AppManager.preview(state: .notInstalled(nil)))
            .environmentObject(HTTPProxyManager.preview())
    }
}
