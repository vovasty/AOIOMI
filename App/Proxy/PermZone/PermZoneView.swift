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
    @State private var editPermzone = PermZone()
    @State private var isShowingEditor = false
    @State private var editIndex: Int?
    @State private var isShowingError = false
    @State private var error: Error?

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
                    Button("New") {
                        editIndex = nil
                        editPermzone = PermZone()
                        isShowingEditor.toggle()
                    }
                    .sheet(isPresented: $isShowingEditor) {
                        DialogView(primaryButton: .default("OK", action: {
                            do {
                                try editPermzone.validate()
                            } catch {
                                self.error = error
                                isShowingError.toggle()
                                return
                            }
                            if let editIndex = editIndex {
                                userSettings.permZones[editIndex] = editPermzone
                            } else {
                                userSettings.permZones.append(editPermzone)
                            }
                            userSettings.activePermZone = editPermzone
                            isShowingEditor.toggle()
                        }), secondaryButton: .cancel("Cancel", action: {
                            isShowingEditor.toggle()
                        })) {
                            PermZoneEditor(permZone: $editPermzone, isShowingError: $isShowingError, error: $error)
                        }
                        .padding()
                    }
                    Button("Delete") {
                        userSettings.permZones.removeAll(where: { $0 == userSettings.activePermZone })
                        userSettings.activePermZone = nil
                    }
                    .disabled(userSettings.activePermZone == nil)
                    Button("Edit") {
                        guard let active = userSettings.activePermZone, let index = userSettings.permZones.firstIndex(of: active) else { return }
                        editIndex = index
                        editPermzone = active
                        isShowingEditor.toggle()
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
