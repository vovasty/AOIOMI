//
//  IOSAppStateView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import iOSSimulator
import SwiftUI

private struct InstallAppView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        Button("install app") {
            let dialog = NSOpenPanel()
            dialog.title = "Choose an app to install"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.allowsMultipleSelection = false
            dialog.canChooseDirectories = false
            dialog.allowedFileTypes = ["app"]

            guard dialog.runModal() == .OK else { return }

            guard let url = dialog.url else { return }
            appManager.install(app: url)
        }
    }
}

struct IOSAppStateView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var dragOver = false

    var body: some View {
        VStack {
            switch appManager.state {
            case let .notInstalled(error):
                InstallAppView()
                ErrorView(error: error)
            case .starting:
                ProgressView(title: "Starting...")
            case .installed:
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
                appManager.install(app: url)
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
        IOSAppStateView()
    }
}
