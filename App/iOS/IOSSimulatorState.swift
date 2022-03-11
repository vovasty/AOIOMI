//
//  IOSSimulatorState.swift
//  AOIOMI
//
//  Created by vlsolome on 2/21/21.
//

import CommonUI
import IOSSimulator

extension IOSSimulator.State {
    var activity: ActivityView.ActivityState {
        switch self {
        case let .stopped(error):
            if let error = error {
                return .error("Simulator is Stopped", error)
            } else {
                return .text("Simulator is Stopped")
            }
        case .stopping:
            return .busy("Stopping Simulator...")
        case .starting:
            return .busy("Starting Simulator...")
        case .configuring:
            return .busy("Configuring Simulator...")
        case .checking:
            return .busy("Checking Simulator...")
        case let .notConfigured(error):
            if let error = error {
                return .error("Simulator is Not Configured", error)
            } else {
                return .text("Simulator is Not Configured")
            }
        case .started:
            return .text("Simulator is Started")
        }
    }
}
