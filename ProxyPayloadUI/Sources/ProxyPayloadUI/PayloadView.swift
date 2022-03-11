//
//  PayloadView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import Combine
import SwiftUI

public struct PayloadView: View {
    @EnvironmentObject private var payloadStore: PayloadStore
    @State private var selection: UUID?
    @State private var isShowingError = false

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                List($payloadStore.items) { $item in
                    NavigationLink(destination: PayloadEditorView(payload: $item).padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0)),
                                   tag: item.id,
                                   selection: $selection) {
                        Toggle("", isOn: $item.isActive)
                        Text(item.name)
                    }
                }
                HStack {
                    Button("+") {
                        let payload = ProxyPayload()
                        payloadStore.items.append(payload)
                        DispatchQueue.main.async {
                            selection = payload.id
                        }
                    }
                    .font(Font.system(size: 16))
                    .foregroundColor(.gray)
                    .buttonStyle(.plain)
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))

                    Button("-") {
                        let selection = selection
                        payloadStore.items.removeAll { $0.id == selection }
                        self.selection = payloadStore.items.first?.id
                    }
                    .padding(1)
                    .font(Font.system(size: 16))
                    .foregroundColor(.gray)
                    .buttonStyle(.plain)
                    .disabled(selection == nil)
                    Spacer()
                }
                .background(Color.white)
            }
            Text("Select a Payload")
        }
        .listStyle(DefaultListStyle())
        .padding()
        .alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Error"),
                message: Text(payloadStore.error?.localizedDescription ?? "Unknown error")
            )
        }
        .onReceive(payloadStore.$error) { error in
            isShowingError = error != nil
        }
    }
}

#if DEBUG
    struct PayloadView_Previews: PreviewProvider {
        static var previews: some View {
            PayloadView()
                .environmentObject(PayloadStore.preview)
        }
    }
#endif
