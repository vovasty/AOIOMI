//
//  PermzoneStore.swift
//  AOIOMI
//
//  Created by vlsolome on 3/9/22.
//

import Combine
import Foundation
import KVStore
import MITMProxy

public final class PermzoneStore: Store<PermZone> {
    @Published public var activePermZone: PermZone?

    private var sub: AnyCancellable?

    public convenience init(manager: Manager) throws {
        try self.init(database: try manager.database(name: "permzones"))
        activePermZone = items.first(where: \.isActive)
        sub = $activePermZone.sink { [weak self] newValue in
            guard let self = self else { return }
            var newItems = self.items
            if let index = newItems.firstIndex(where: \.isActive) {
                newItems[index].isActive = false
            }

            if let index = newItems.firstIndex(where: { $0.id == newValue?.id }) {
                newItems[index].isActive = true
            }
            self.items = newItems
            if newValue?.isActive == false {
                DispatchQueue.main.async {
                    self.activePermZone?.isActive = true
                }
            }
        }
    }

    public var addon: Addon? {
        guard let activePermZone = activePermZone else { return nil }
        return PermzoneAddon(headers: activePermZone.headers)
    }

    public var isActive: Bool {
        activePermZone != nil
    }
}

#if DEBUG
    extension PermzoneStore {
        static var preview: PermzoneStore {
            let manager = try! Manager(data: URL(fileURLWithPath: "/tmp/test"))
            return try! PermzoneStore(manager: manager)
        }
    }
#endif
