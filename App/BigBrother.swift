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
import KVStore
import MITMProxy
import ProxyPayloadUI

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
    let kvManager: Manager
    let proxyAddonManager: ProxyAddonManager
    let payloadStore: PayloadStore
    let permzoneStore: PermzoneStore
    let translateStore: TranslateStore

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

        httpProxyManager = HTTPProxyManager(charlesProxy: CharlesProxy(), mitmProxy: mitmProxy)

        kvManager = try! Manager(data: appSupportURL.appendingPathComponent("db"))
        payloadStore = try! PayloadStore(manager: kvManager)
        permzoneStore = try! PermzoneStore(manager: kvManager)
        translateStore = try! TranslateStore(manager: kvManager, userSettings: userSettings)

        proxyAddonManager = ProxyAddonManager(mitmProxy: mitmProxy,
                                              userSettings: userSettings,
                                              payloads: payloadStore,
                                              permzones: permzoneStore,
                                              translator: translateStore)

        migrationManager.migrations = [Migration15(), Migration18(transtatorStore: translateStore, payloadStore: payloadStore, permzoneStore: permzoneStore)]

        try? proxyAddonManager.update()

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
