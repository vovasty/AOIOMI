//
//  AOSEmulatorRuntimeState.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import AOSEmulatorRuntime
import CommonUI
import Foundation

extension AOSEmulatorRuntime.State {
    var activity: ActivityView.ActivityState {
        switch self {
        case .unknown:
            return .busy("Unknown...")
        case .checking:
            return .busy("Checking AOS Runtime...")
        case .installed:
            return .busy("AOS Runtime Is Installed")
        case .installing:
            return .busy("Installing AOS Runtime...")
        case .updating:
            return .busy("Updating AOS Runtime...")
        case let .notInstalled(error):
            if let error = error {
                return .error("AOS Runtime is Not Installed", error)
            } else {
                return .text("AOS Runtime is Not Installed")
            }
        }
    }
}
