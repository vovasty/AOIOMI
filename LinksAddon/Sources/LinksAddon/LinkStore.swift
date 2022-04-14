//
//  LinkStore.swift
//
//
//  Created by vlsolome on 4/12/22.
//

import Combine
import Foundation
import KVStore

public final class LinkStore: Store<Link> {
    @Published public var activeLink: Link!
    private var sub: AnyCancellable?

    public init(manager: Manager) throws {
        try super.init(database: try manager.database(name: "links"))
        if items.isEmpty {
            items = defaults
        }

        activeLink = items.first(where: \.isActive)

        sub = $activeLink.sink { [weak self] newValue in
            guard let self = self else { return }
            guard let newValue = newValue else { return }
            var newItems = self.items
            if let index = newItems.firstIndex(where: \.isActive) {
                newItems[index].isActive = false
            }

            if let index = newItems.firstIndex(where: { $0.id == newValue.id }) {
                newItems[index] = newValue
            } else {
                newItems.append(newValue)
            }
            self.items = newItems
            if newValue.isActive == false {
                DispatchQueue.main.async {
                    self.activeLink?.isActive = true
                }
            }
        }
    }

    func deleteActiveLink() {
        guard let activeLink = activeLink else { return }
        try? delete(item: activeLink)
        self.activeLink = nil
    }

    private var defaults: [Link] {
        [
            Link(id: UUID().uuidString, name: "search", template: "coupang://search?q={{query}}", parameters: []),
            Link(id: UUID().uuidString, name: "open product", template: "coupang://product?pId={{product id}}", parameters: []),
        ]
    }
}

#if DEBUG
    extension LinkStore {
        static var preview: LinkStore = try! LinkStore(manager: Manager.preview)
    }
#endif
