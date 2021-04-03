//
//  AOSEmulatorState.swift
//  AOIOMI
//
//  Created by vlsolome on 2/21/21.
//

import AOSEmulator

extension AOSEmulator.State {
    var activity: ActivityView.ActivityState {
        switch self {
        case .started:
            return .text("Emulator is Started")
        case .starting:
            return .busy("Starting Emulator...")
        case let .stopped(error):
            if let error = error {
                return .error("Emulator is Stopped", error)
            } else {
                return .text("Emulator is Stopped")
            }
        case .stopping:
            return .busy("Stopping Emulator...")
        case .configuring:
            return .busy("Configuring Emulator...")
        case .checking:
            return .busy("Checking Emulator...")
        case let .notConfigured(error):
            if let error = error {
                return .error("Emulator is Not Configured", error)
            } else {
                return .text("Emulator is Not Configured")
            }
        }
    }
}
