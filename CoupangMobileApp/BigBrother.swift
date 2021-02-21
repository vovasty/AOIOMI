//
//  BigBrother.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/21/21.
//

import AOSEmulator
import Cocoa
import Combine
import HTTPProxyManager
import IOSSimulator

final class BigBrother {
    let simulatorId = "CoupangMobileApp"
    let iosAppBundleId = "com.coupang.Coupang"
    let aosAppMainActivity = "com.coupang.mobile/com.coupang.mobile.domain.home.main.activity.MainActivity"
    let aosPackageId = "com.coupang.mobile"
    let aosAppPreferencesPath = "/data/data/com.coupang.mobile/shared_prefs/com.coupang.mobile_preferences.xml"
    let simulator: IOSSimulator
    let emulator: AOSEmulator
    let iosAppManager: IOSAppManager
    let aosAppManager: AOSAppManager
    let httpProxyManager: HTTPProxyManager

    private var cancellables = Set<AnyCancellable>()

    init() {
        simulator = IOSSimulator(simulatorName: simulatorId)
        emulator = AOSEmulator()
        iosAppManager = IOSAppManager(simulatorId: simulatorId, bundleId: iosAppBundleId)
        aosAppManager = AOSAppManager(activityId: aosAppMainActivity,
                                      packageId: aosPackageId,
                                      preferencesPath: aosAppPreferencesPath)
        httpProxyManager = HTTPProxyManager()

        emulator.$state.sink { [weak self] state in
            switch state {
            case .started:
                self?.aosAppManager.check()
            default:
                break
            }
        }
        .store(in: &cancellables)

        simulator.$state.sink { [weak self] state in
            switch state {
            case .started:
                self?.iosAppManager.check()
            default:
                break
            }
        }
        .store(in: &cancellables)
    }

    func check() {
        simulator.check()
        emulator.check()
    }

    func stop() {
        emulator.stop()
    }
}
