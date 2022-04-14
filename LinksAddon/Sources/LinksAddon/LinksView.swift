//
//  LinksView.swift
//
//
//  Created by vlsolome on 4/12/22.
//

import AOSEmulator
import CommonUI
import IOSSimulator
import SwiftUI

public struct LinksView: View {
    @EnvironmentObject private var store: LinkStore
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var emulator: AOSEmulator
    @State private var isShowingEditor = false
    @State private var editingItem = Link(id: UUID().uuidString, name: "", template: "", parameters: [])

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            Form {
                HStack {
                    Picker("Link", selection: $store.activeLink) {
                        ForEach(store.items) {
                            Text($0.name).tag($0 as Link?)
                        }
                    }
                    Button("Edit") {
                        editingItem = store.activeLink
                        isShowingEditor.toggle()
                    }
                    .disabled(store.activeLink == nil)
                    Button("New") {
                        editingItem = Link(id: UUID().uuidString, name: "", template: "", parameters: [])
                        isShowingEditor.toggle()
                    }
                    Button("Del") {
                        store.deleteActiveLink()
                    }
                    .disabled(store.activeLink == nil)
                }

                if store.activeLink != nil {
                    ForEach($store.activeLink.parameters) { $parameter in
                        TextField(parameter.id, text: $parameter.value)
                    }
                }

                Button("Open") {
                    guard let url = try? store.activeLink.url() else { return }
                    if simulator.state == .started {
                        simulator.start()
                        simulator.open(link: url)
                    }

                    if emulator.state == .started {
                        emulator.open(link: url)
                    }
                }
                .disabled(!(simulator.state == .started || emulator.state == .started))
            }
            .sheet(isPresented: $isShowingEditor) {
                DialogView(primaryButton: .default("OK", action: {
                    store.activeLink = editingItem
                    isShowingEditor.toggle()
                }), secondaryButton: .cancel("Cancel", action: {
                    isShowingEditor.toggle()
                })) {
                    LinkEditorView(link: $editingItem)
                }
                .padding()
            }
            Spacer()
        }
        .padding()
    }
}

struct LinksView_Previews: PreviewProvider {
    static var previews: some View {
        LinksView()
            .environmentObject(LinkStore.preview)
            .frame(width: 300, height: 100)
    }
}
