//
//  IOSAppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import HTTPProxyManager
import iOSSimulator
import SwiftUI

private struct InstallAppView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var httpProxyManager: HTTPProxyManager

    var body: some View {
        switch appManager.state {
        case .installed, .installing, .starting:
            Button("reinstall app", action: install)
        case .notInstalled:
            Button("install app", action: install)
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

struct IOSAppStateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var httpProxyManager: HTTPProxyManager
    @State private var dragOver = false

    var body: some View {
        VStack {
            switch appManager.state {
            case let .notInstalled(error):
                ErrorView(error: error)
                InstallAppView()
            case .starting:
                ProgressView(title: "Starting...")
            case let .installed(error):
                ErrorView(error: error)
                InstallAppView()
                Button("open app") {
                    appManager.start()
                }
            case .installing:
                ProgressView(title: "Installing...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct IOSAppStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IOSAppStateView()
                .environmentObject(AppManager.preview(state: .installed(nil)))
                .environmentObject(HTTPProxyManager.preview())
            Divider()
            IOSAppStateView()
                .environmentObject(AppManager.preview(state: .installed(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"]))))
                .environmentObject(HTTPProxyManager.preview())
            Divider()
            IOSAppStateView()
                .environmentObject(AppManager.preview(state: .notInstalled(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"]))))
                .environmentObject(HTTPProxyManager.preview())
            Divider()
            InstallAppView()
                .environmentObject(AppManager.preview(state: .installed(nil)))
                .environmentObject(HTTPProxyManager.preview())
            Divider()
            InstallAppView()
                .environmentObject(AppManager.preview(state: .notInstalled(nil)))
                .environmentObject(HTTPProxyManager.preview())
        }
    }
}
