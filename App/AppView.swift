//
//  AppView.swift
//  AOIOMI
//
//  Created by vlsolome on 2/16/21.
//

import Combine
import CommonUI
import SwiftUI

private struct InstallAppView: View {
    let title: String
    let isInstalled: Bool
    let fileExtensions: [String]
    let installAction: (URL) -> Void

    var body: some View {
        if isInstalled {
            Button("Reinstall App", action: install)
        } else {
            Button("Install App", action: install)
        }
    }

    private func install() {
        let dialog = NSOpenPanel()
        dialog.title = title
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = fileExtensions

        guard dialog.runModal() == .OK else { return }

        guard let url = dialog.url else { return }
        installAction(url)
    }
}

protocol AppViewManagerState {
    var PCID: String? { get }
    var isInstallDisabled: Bool { get }
    var isCheckDisabled: Bool { get }
    var isNonOperational: Bool { get }
    var isInstalled: Bool { get }
    var activity: ActivityView.ActivityState { get }
}

protocol AppViewManager: ObservableObject {
    associatedtype AppViewManagerStateType: AppViewManagerState
    var state: AppViewManagerStateType { get }
    func check()
    func start()
}

struct AppView<AppViewManagerType: AppViewManager>: View {
    let appManager: AppViewManagerType
    @Binding var activityState: ActivityView.ActivityState
    let installTitle: String
    let fileExtensions: [String]
    let installAction: (URL) -> Void

    @State private var isShowingPCID = false
    @State private var wantToShowPCID = false

    var body: some View {
        VStack(alignment: .leading) {
            InstallAppView(title: installTitle,
                           isInstalled: appManager.state.isInstalled,
                           fileExtensions: fileExtensions,
                           installAction: installAction)
                .disabled(appManager.state.isInstallDisabled)
            HStack {
                Button("Open App") {
                    appManager.start()
                }
                .disabled(appManager.state.isNonOperational)
                SwiftUI.Button(action: { appManager.check() }) {
                    Image("arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(appManager.state.isCheckDisabled)
            }
            Button("Show PCID") {
                wantToShowPCID = true
                appManager.check()
            }
            .disabled(appManager.state.isNonOperational)
            .sheet(isPresented: $isShowingPCID) {
                if let PCID = appManager.state.PCID {
                    DialogView(primaryButton: .default("Copy", action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.declareTypes([.string], owner: nil)
                        pasteboard.setString(PCID, forType: .string)
                        wantToShowPCID = false
                        isShowingPCID = false
                    }), secondaryButton: .cancel("Cancel", action: {
                        wantToShowPCID = false
                        isShowingPCID = false
                    })) {
                        Text(PCID)
                    }
                    .padding()
                } else {
                    DialogView(primaryButton: .default("OK", action: {
                        wantToShowPCID = false
                        isShowingPCID = false
                    }), content: {
                        Text("PCID is Not Available")
                    })
                    .padding()
                }
            }
            .disabled(appManager.state.isCheckDisabled)
        }
        .onReceive(Just(appManager.state)) { state in
            if state.isInstalled {
                isShowingPCID = wantToShowPCID
            }
            activityState = state.activity
        }
    }
}

#if DEBUG
    private struct MockedAppViewManagerState: AppViewManagerState {
        var PCID: String?
        var isInstallDisabled: Bool
        var isCheckDisabled: Bool
        var isNonOperational: Bool
        var isInstalled: Bool
        var activity: ActivityView.ActivityState
    }

    private class MockedAppManager: AppViewManager {
        var state: MockedAppViewManagerState

        init() {
            state = MockedAppViewManagerState(PCID: "PCID",
                                              isInstallDisabled: false,
                                              isCheckDisabled: false,
                                              isNonOperational: false,
                                              isInstalled: false,
                                              activity: .busy("busy"))
        }

        func check() {}

        func start() {}
    }

    struct AppView_Previews: PreviewProvider {
        private static let appManager = MockedAppManager()

        static var previews: some View {
            AppView(appManager: appManager,
                    activityState: .constant(.busy("busy")),
                    installTitle: "Install App",
                    fileExtensions: ["app"],
                    installAction: { _ in })
        }
    }
#endif
