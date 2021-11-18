//
//  MigrationView.swift
//  AOIOMI
//
//  Created by vlsolome on 11/17/21.
//

import SwiftUI

struct MigrationView: View {
    @EnvironmentObject private var migration: MigrationManager
    @State var activityState: ActivityView.ActivityState = .text("nothing")
    var body: some View {
        ActivityView(style: .aos, state: $activityState)
            .onReceive(migration.$state) { state in
                activityState = state.activity
            }
    }
}

struct MigrationView_Previews: PreviewProvider {
    static var previews: some View {
        MigrationView()
            .frame(width: 200, height: 200)
    }
}
