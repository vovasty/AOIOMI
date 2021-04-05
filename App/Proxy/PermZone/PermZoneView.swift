//
//  PermzoneView.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import MITMProxy
import SwiftUI

struct PermZoneView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var mitmProxy: MITMProxy
    @State private var newPermzone = PermZone()
    @State private var isShowingAddNew = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Picker("Permzone", selection: $userSettings.activePermZone) {
                    Text("Not Set")
                        .tag(nil as PermZone?)
                    ForEach(userSettings.permZones) {
                        Text($0.id).tag($0 as PermZone?)
                    }
                }
                HStack {
                    Spacer()
                    Button("Add New") {
                        isShowingAddNew.toggle()
                    }
                    .sheet(isPresented: $isShowingAddNew) {
                        DialogView(primaryButton: .default("OK", action: {
                            guard newPermzone.isValid else { return }
                            userSettings.permZones.append(newPermzone)
                            userSettings.activePermZone = newPermzone
                            newPermzone = PermZone()
                            isShowingAddNew.toggle()
                        }), secondaryButton: .cancel("Cancel", action: {
                            newPermzone = PermZone()
                            isShowingAddNew.toggle()
                        })) {
                            PermZoneEditor(permZone: $newPermzone)
                        }
                        .padding()
                    }
                    Button("Delete") {
                        userSettings.permZones.removeAll(where: { $0 == userSettings.activePermZone })
                        userSettings.activePermZone = nil
                    }
                    .disabled(userSettings.activePermZone == nil)
                }
            }
            Spacer()
        }
        .padding()
        .onReceive(Just(userSettings.activePermZone)) { _ in
            try? mitmProxy.addonManager.set(addons: userSettings.addons)
        }
    }
}

#if DEBUG
    struct PermzoneView_Previews: PreviewProvider {
        static var previews: some View {
            PermZoneView()
                .environmentObject(UserSettings())
                .environmentObject(MITMProxy.preview)
                .frame(width: 300, height: 100)
        }
    }
#endif
