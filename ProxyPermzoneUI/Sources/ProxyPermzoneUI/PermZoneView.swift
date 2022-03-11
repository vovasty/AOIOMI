//
//  PermzoneView.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import CommonUI
import SwiftUI

public struct PermZoneView: View {
    @EnvironmentObject private var permzoneStore: PermzoneStore
    @State private var editPermzone = PermZone()
    @State private var isShowingEditor = false
    @State private var editIndex: Int?
    @State private var isShowingError = false
    @State private var error: Error?

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Picker("Permzone", selection: $permzoneStore.activePermZone) {
                    Text("Not Set")
                        .tag(nil as PermZone?)
                    ForEach(permzoneStore.items) {
                        Text($0.name).tag($0 as PermZone?)
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
                                permzoneStore.items[editIndex] = editPermzone
                            } else {
                                permzoneStore.items.append(editPermzone)
                            }
                            permzoneStore.activePermZone = editPermzone
                            isShowingEditor.toggle()
                        }), secondaryButton: .cancel("Cancel", action: {
                            isShowingEditor.toggle()
                        })) {
                            PermZoneEditor(permZone: $editPermzone, isShowingError: $isShowingError, error: $error)
                        }
                        .padding()
                    }
                    Button("Delete") {
                        permzoneStore.items.removeAll(where: { $0 == permzoneStore.activePermZone })
                        permzoneStore.activePermZone = nil
                    }
                    .disabled(permzoneStore.activePermZone == nil)
                    Button("Edit") {
                        guard let active = permzoneStore.activePermZone, let index = permzoneStore.items.firstIndex(of: active) else { return }
                        editIndex = index
                        editPermzone = active
                        isShowingEditor.toggle()
                    }
                    .disabled(permzoneStore.activePermZone == nil)
                }
            }
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
    struct PermzoneView_Previews: PreviewProvider {
        static var previews: some View {
            PermZoneView()
                .environmentObject(PermzoneStore.preview)
                .frame(width: 300, height: 100)
        }
    }
#endif
