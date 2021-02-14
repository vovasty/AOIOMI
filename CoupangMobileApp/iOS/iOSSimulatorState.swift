//
//  iOSSimulatorState.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/14/21.
//

import iOSSimulator

extension iOSSimulator.State {
    var asActivity: ActivityView.ActivityState {
        switch self {
        case let .stopped(error):
            if let error = error {
                return .error("Stopped", error)
            } else {
                return .text("Stopped")
            }
        case .stopping:
            return .busy("Stopping...")
        case .starting:
            return .busy("Starting...")
        case .configuring:
            return .busy("Configuring...")
        case .checking:
            return .busy("Checking...")
        case .notConfigured:
            return .text("Not Configured")
        case .started:
            return .text("Started")
        }
    }
}
