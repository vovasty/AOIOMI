//
//  PayloadEditorView.swift
//  AOIOMI
//
//  Created by vlsolome on 4/5/21.
//

import CommonUI
import SwiftUI

struct PayloadEditorView: View {
    @Binding var payload: Payload

    var body: some View {
        VStack(spacing: 3) {
            TextField("Name", text: $payload.name)
            TextField("URL Regex", text: $payload.regex)
            TextArea(text: $payload.payload)
        }
    }
}

#if DEBUG
    struct PayloadEditorView_Previews: PreviewProvider {
        @State static var payload = Payload()

        static var previews: some View {
            PayloadEditorView(payload: $payload)
        }
    }
#endif
