//
//  AppManager.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/12/21.
//

import AndroidEmulator
import Foundation

extension AppManager {
    var pcid: String? {
        switch state {
        case let .installed(xml):
            do {
                return try xml?["map"]["string"].withAttribute("name", "wl_pcid").element?.text
            } catch {
                return nil
            }
        default:
            return nil
        }
    }
}
