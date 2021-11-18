//
//  MigrationManager.swift
//  AOIOMI
//
//  Created by vlsolome on 11/17/21.
//

import Combine
import Foundation

protocol Migration {
    func migrate() throws
    var version: Int { get }
}

final class MigrationManager: ObservableObject {
    enum State {
        case migrating, migrated(Error?), unknown
    }

    @Published private(set) var state: State = .unknown

    private var bundleVersion: Int {
        guard let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return 0 }
        return Int(version) ?? 0
    }

    private var migrations: [Migration] = [Migration15()]

    private var recordedVersionKey: String {
        "\(Bundle.main.bundleIdentifier ?? "AOIOMI").appversion"
    }

    private var recordedVersion: Int {
        get {
            UserDefaults.standard.integer(forKey: recordedVersionKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: recordedVersionKey)
        }
    }

    init() {}

    func migrate() {
        let migrations = self.migrations
            .filter { $0.version > self.recordedVersion }
            .sorted(by: { $0.version < $1.version })
        guard (migrations.last?.version ?? 0) > recordedVersion else {
            if recordedVersion != bundleVersion {
                recordedVersion = bundleVersion
            }
            state = .migrated(nil)
            return
        }
        state = .migrating
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            var state: State = .migrated(nil)

            for migration in migrations {
                do {
                    try migration.migrate()
                    self.recordedVersion = migration.version
                } catch {
                    state = .migrated(error)
                    break
                }
                self.recordedVersion = self.bundleVersion
            }
            DispatchQueue.main.async {
                self.state = state
            }
        }
    }
}

extension MigrationManager.State {
    var activity: ActivityView.ActivityState {
        switch self {
        case .migrating:
            return .busy("Migrating...")
        case .migrated:
            return .busy("Migrated")
        case .unknown:
            assertionFailure("unreachable")
            return .busy("Unknown")
        }
    }
}
