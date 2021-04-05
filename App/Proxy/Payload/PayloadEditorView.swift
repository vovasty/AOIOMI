//
//  PayloadEditorView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import SwiftUI

struct PayloadEditorView: View {
    @Binding var payload: ProxyPayload

    var body: some View {
        VStack {
            TextField("Name", text: $payload.id)
            TextField("URL Regex", text: $payload.regex)
            HStack(alignment: .top) {
                TextArea(text: $payload.payload)
                Button("Paste") {
                    let pasteboard = NSPasteboard.general
                    if payload.payload.isEmpty, let text = pasteboard.string(forType: .string) {
                        payload.payload = text
                    }
                }
            }
        }
        .frame(width: 300, height: 150)
    }
}

#if DEBUG
    struct PayloadEditorView_Previews: PreviewProvider {
        @State static var payload = ProxyPayload()

        static var previews: some View {
            PayloadEditorView(payload: $payload)
        }
    }
#endif
