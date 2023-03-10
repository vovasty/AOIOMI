//
//  IOSAppViewManagerConformance.swift
//  AOIOMI
//
//  Created by vlsolome on 2/16/21.
//

import CommonUI
import Foundation
import HTTPProxyManager
import IOSSimulator

extension IOSAppManager.State: AppViewManagerState {
    var PCID: String? {
        switch self {
        case let .installed(_, defaults):
            return (defaults as? [String: Any])?["molly.logger.client.key"] as? String
        default:
            return nil
        }
    }

    var isInstallDisabled: Bool {
        switch self {
        case .starting, .installing, .checking:
            return true
        case .notInstalled, .installed:
            return false
        }
    }

    var isCheckDisabled: Bool {
        switch self {
        case .installed, .notInstalled:
            return false
        case .installing, .starting, .checking:
            return true
        }
    }

    var isNonOperational: Bool {
        switch self {
        case .installed:
            return false
        case .installing, .starting, .notInstalled, .checking:
            return true
        }
    }

    var isInstalled: Bool {
        switch self {
        case .installed:
            return true
        case .notInstalled, .installing, .starting, .checking:
            return false
        }
    }

    var activity: ActivityView.ActivityState {
        switch self {
        case let .notInstalled(error):
            if let error = error {
                return .error("App is Not Installed", error)
            } else {
                return .text("App is Not Installed")
            }
        case let .installed(error, _):
            if let error = error {
                return .error("App is Installed", error)
            } else {
                return .text("App is Installed")
            }
        case .installing:
            return .busy("Installing App...")
        case .starting:
            return .busy("Staring App...")
        case .checking:
            return .busy("Checking App...")
        }
    }
}

extension IOSAppManager: AppViewManager {}
