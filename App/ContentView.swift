//
//  ContentView.swift
//  AOIOMI
//
//  Created by vlsolome on 11/17/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var migration: MigrationManager

    var body: some View {
        switch migration.state {
        case .migrated:
            MainView()
                .frame(minWidth: 600, minHeight: 300)
        default:
            MigrationView()
                .frame(minWidth: 600, minHeight: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
