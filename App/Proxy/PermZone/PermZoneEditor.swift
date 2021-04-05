//
//  PermzoneEditor.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import SwiftUI

struct PermZoneEditor: View {
    @Binding var permZone: PermZone

    var body: some View {
        VStack {
            TextField("Name", text: $permZone.id)
            HStack(alignment: .top) {
                TextArea(text: $permZone.body)
                Button("Paste") {
                    let pasteboard = NSPasteboard.general
                    if permZone.body.isEmpty, let text = pasteboard.string(forType: .string) {
                        permZone.body = text
                    }
                }
            }
        }
        .frame(width: 300, height: 150)
    }
}

struct PermzoneEditor_Previews: PreviewProvider {
    @State static var permZone = PermZone()

    static var previews: some View {
        PermZoneEditor(permZone: $permZone)
    }
}
