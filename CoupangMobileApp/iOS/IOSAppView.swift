//
//  IOSAppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import Combine
import HTTPProxyManager
import iOSSimulator
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
    @State private var dragOver = false
    @State private var activityState = ActivityView.ActivityState.text("")
    @State private var openAppDisabled = false
    @State private var installAppDisabled = false

    var body: some View {
        VStack {
            ActivityView(state: $activityState)
            InstallAppView()
                .disabled(installAppDisabled)
            Button("Open App") {
                appManager.start()
            }
            .disabled(openAppDisabled)
        }
        .onReceive(Just(appManager.state)) { state in
            switch state {
            case .installed:
                openAppDisabled = false
                installAppDisabled = false
            case .installing:
                openAppDisabled = true
                installAppDisabled = true
            case .starting, .notInstalled:
                openAppDisabled = true
                installAppDisabled = false
            }

            activityState = state.asActivity
        }
        .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, _ in
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
        case let .installed(error):
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
}

struct IOSAppStateView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])
        IOSAppView()
            .environmentObject(AppManager.preview(state: .installed(nil)))
            .environmentObject(HTTPProxyManager.preview())
        IOSAppView()
            .environmentObject(AppManager.preview(state: .notInstalled(error)))
            .environmentObject(HTTPProxyManager.preview())
        IOSAppView()
            .environmentObject(AppManager.preview(state: .installed(error)))
            .environmentObject(HTTPProxyManager.preview())
        InstallAppView()
            .environmentObject(AppManager.preview(state: .installed(nil)))
            .environmentObject(HTTPProxyManager.preview())
        InstallAppView()
            .environmentObject(AppManager.preview(state: .notInstalled(nil)))
            .environmentObject(HTTPProxyManager.preview())
    }
}