//
//  UserSettings.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import UserDefaults

final class UserSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("permZones", defaultValue: [])
    var permZones: [PermZone] {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault("activePermZone", defaultValue: nil)
    var activePermZone: PermZone? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("proxyPort", defaultValue: 9999)
    var proxyPort: Int {
        willSet {
            objectWillChange.send()
        }
    }
}
