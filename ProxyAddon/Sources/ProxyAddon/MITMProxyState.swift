//
//  MITMProxyState.swift
//  AOIOMI
//
//  Created by vlsolome on 4/1/21.
//

import Combine
import CommonUI
import MITMProxy

extension MITMProxy.State {
    var activity: ActivityView.ActivityState {
        switch self {
        case .starting:
            return .busy("Starting...")
        case .started:
            return .text("Started")
        case .stopped:
            return .text("Stopped")
        case .stopping:
            return .busy("Stopping...")
        }
    }
}
