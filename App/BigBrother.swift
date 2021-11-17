//
//  BigBrother.swift
//  AOIOMI
//
//  Created by vlsolome on 2/21/21.
//

import AOSEmulator
import AOSEmulatorRuntime
import CharlesProxy
import Cocoa
import Combine
import HTTPProxyManager
import IOSSimulator
import MITMProxy

final class BigBrother {
    let simulatorId = "AOIOMI"
    let iosAppBundleId = "com.coupang.Coupang"
    let aosAppMainActivity = "com.coupang.mobile/com.coupang.mobile.domain.home.main.activity.MainActivity"
    let aosPackageId = "com.coupang.mobile"
    let aosAppPreferencesPath = "/data/data/com.coupang.mobile/shared_prefs/com.coupang.mobile_preferences.xml"
    let simulator: IOSSimulator
    let emulator: AOSEmulator
    let iosAppManager: IOSAppManager
    let aosAppManager: AOSAppManager
    let mitmProxy: MITMProxy
    let userSettings = UserSettings()
    let aosRuntime: AOSEmulatorRuntime
    let httpProxyManager: HTTPProxyManager
    let migrationManager = MigrationManager()

    private var cancellables = Set<AnyCancellable>()

    init() {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory,
                                                     in: .userDomainMask).first!
            .appendingPathComponent(Bundle.main.bundleIdentifier!)
        try? FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: false, attributes: nil)

        simulator = IOSSimulator(simulatorName: simulatorId)
        iosAppManager = IOSAppManager(simulatorId: simulatorId, bundleId: iosAppBundleId)

        aosRuntime = AOSEmulatorRuntime(home: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".aoiomi"))
        emulator = AOSEmulator(env: aosRuntime.env)
        aosAppManager = AOSAppManager(activityId: aosAppMainActivity,
                                      packageId: aosPackageId,
                                      preferencesPath: aosAppPreferencesPath,
                                      env: aosRuntime.env)

        mitmProxy = MITMProxy(port: userSettings.proxyPort,
                              guiPort: userSettings.proxyGUIPort,
                              home: appSupportURL.appendingPathComponent("mitmproxy"))
        if userSettings.proxyExternalEnabled {
            mitmProxy.upstreamProxyPort = userSettings.proxyExternalPort
            mitmProxy.upstreamProxyHost = userSettings.proxyExternalHost
        } else {
            mitmProxy.upstreamProxyPort = nil
            mitmProxy.upstreamProxyHost = nil
        }
        mitmProxy.allowedHosts = userSettings.proxyAllowedHosts
        try? mitmProxy.addonManager.set(addons: userSettings.addons)

        httpProxyManager = HTTPProxyManager(charlesProxy: CharlesProxy(), mitmProxy: mitmProxy)

        aosRuntime.$state
            .sink { [weak self] state in
                switch state {
                case .installed:
                    self?.emulator.check()
                case let .notInstalled(error):
                    guard error == nil else { return }
                    // TODO: why???
                    DispatchQueue.main.async {
                        self?.aosRuntime.install()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

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

        migrationManager.$state.sink { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .migrated:
                self.mitmProxy.start()
                self.aosRuntime.check()
                self.simulator.check()
            default:
                break
            }
        }
        .store(in: &cancellables)
    }

    func start() {
        mitmProxy.stopOrphan()
        migrationManager.migrate()
    }

    func stop() {
        emulator.stop()
        mitmProxy.stop()
    }
}
