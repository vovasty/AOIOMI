//
//  AppView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/16/21.
//

import Combine
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
        VStack {
            InstallAppView(title: installTitle,
                           isInstalled: appManager.state.isInstalled,
                           fileExtensions: fileExtensions,
                           installAction: installAction)
                .disabled(appManager.state.isInstallDisabled)
            Button("Open App") {
                appManager.start()
            }
            .disabled(appManager.state.isNonOperational)
            Button("Show PCID") {
                wantToShowPCID = true
                appManager.check()
            }
            .disabled(appManager.state.isNonOperational)
            .sheet(isPresented: $isShowingPCID) {
                if let PCID = appManager.state.PCID {
                    DialogView(primaryButton: .default("OK", action: {
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
            Button("Check") {
                appManager.check()
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

// private extension AppManager.State {
//    var asActivity: ActivityView.ActivityState {
//        switch self {
//        case let .notInstalled(error):
//            if let error = error {
//                return .error("App is Not Installed", error)
//            } else {
//                return .text("App is Not Installed")
//            }
//        case .installed:
//            return .text("App is Installed")
//        case .installing:
//            return .busy("Installing App...")
//        case .checking:
//            return .busy("Checking App...")
//        }
//    }
//
//    var PCID: String? {
//        switch self {
//        case let .installed(_, xml):
//            do {
//                return try xml?["map"]["string"].withAttribute("name", "wl_pcid").element?.text
//            } catch {
//                return nil
//            }
//        default:
//            return nil
//        }
//    }
// }
//
// struct AOSAppStateView_Previews: PreviewProvider {
//    static var xml: XMLIndexer {
//        let xmlString = """
//        <map>
//          <string name="wl_pcid">1234567890</string>
//        </map>
//        """
//        return SWXMLHash.config {
//            config in
//            config.shouldProcessLazily = true
//        }.parse(xmlString.data(using: .utf8)!)
//    }
//
//    static var previews: some View {
//        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "something bad happened!"])
//        AOSAppStateView(activityState: .constant(.text("some")))
//            .environmentObject(AppManager.preview(state: .checking))
//        AOSAppStateView(activityState: .constant(.text("some")))
//            .environmentObject(AppManager.preview(state: .notInstalled(nil)))
//        AOSAppStateView(activityState: .constant(.text("some")))
//            .environmentObject(AppManager.preview(state: .notInstalled(error)))
//        AOSAppStateView(activityState: .constant(.text("some")))
//            .environmentObject(AppManager.preview(state: .installing))
//        AOSAppStateView(activityState: .constant(.text("some")))
//            .environmentObject(AppManager.preview(state: .installed(error: nil, defaults: xml)))
//    }
// }
