//
//  LinkEditorView.swift
//
//
//  Created by vlsolome on 4/13/22.
//

import SwiftUI

struct LinkEditorView: View {
    @Binding var link: Link

    var body: some View {
        VStack {
            TextField("name", text: $link.name)
            TextField("url", text: $link.template)
        }
        .frame(minWidth: 300)
    }
}

struct LinkEditorView_Previews: PreviewProvider {
    @State static var link = Link(id: UUID().uuidString, name: "", template: "", parameters: [])

    static var previews: some View {
        LinkEditorView(link: $link)
            .frame(width: 300)
    }
}
