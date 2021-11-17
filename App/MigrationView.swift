//
//  MigrationView.swift
//  AOIOMI
//
//  Created by vlsolome on 11/17/21.
//

import SwiftUI

struct MigrationView: View {
    @EnvironmentObject private var migration: MigrationManager
    @State private var state = ActivityView.ActivityState.busy("Migrating...")
    var body: some View {
        ActivityView(style: .aos, state: $state)
    }
}

struct MigrationView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationView()
            .frame(width: 200, height: 200)
    }
}
