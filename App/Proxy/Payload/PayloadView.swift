//
//  PayloadView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import Combine
import MITMProxy
import SwiftUI

struct PayloadView: View {
    @EnvironmentObject private var mitmProxy: MITMProxy
    @EnvironmentObject private var userSettings: UserSettings
    @State private var isShowingAddNew = false
    @State private var isShowingEdit = false
    @State private var isEditing = false
    @State private var editPayload = ProxyPayload()
    @State private var editIndex = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditing {
                    Button("Done") {
                        isEditing.toggle()
                    }
                    Spacer()
                    Button("Add New") {
                        editPayload = ProxyPayload()
                        isShowingAddNew.toggle()
                    }
                    .sheet(isPresented: $isShowingAddNew) {
                        DialogView(primaryButton: .default("OK", action: {
                            editPayload.isChecked = true
                            userSettings.payloads.append(editPayload)
                            isShowingAddNew.toggle()
                        }), secondaryButton: .cancel("Cancel", action: {
                            isShowingAddNew.toggle()
                        })) {
                            PayloadEditorView(payload: $editPayload)
                        }
                        .padding()
                    }
                } else {
                    Button("Edit") {
                        isEditing.toggle()
                    }
                }
            }
            ForEach(userSettings.payloads.indices, id: \.self) { index in
                HStack {
                    if isEditing {
                        Button("Delete") {
                            userSettings.payloads.remove(at: index)
                        }
                        Button("Edit") {
                            isShowingEdit.toggle()
                            editPayload = userSettings.payloads[index]
                            editIndex = index
                        }
                        .sheet(isPresented: $isShowingEdit) {
                            DialogView(primaryButton: .default("OK", action: {
                                userSettings.payloads[editIndex] = editPayload
                                isShowingEdit.toggle()
                            }), secondaryButton: .cancel("Cancel", action: {
                                isShowingEdit.toggle()
                            })) {
                                PayloadEditorView(payload: $editPayload)
                            }
                            .padding()
                        }
                        Text(userSettings.payloads[index].id)
                    } else {
                        Toggle(userSettings.payloads[index].id, isOn: self.$userSettings.payloads[index].isChecked)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onReceive(Just(userSettings.payloads)) { _ in
            try? mitmProxy.addonManager.set(addons: userSettings.addons)
        }
    }
}

#if DEBUG
    struct PayloadView_Previews: PreviewProvider {
        static var previews: some View {
            PayloadView()
                .environmentObject(UserSettings())
                .environmentObject(MITMProxy.preview)
        }
    }
#endif
