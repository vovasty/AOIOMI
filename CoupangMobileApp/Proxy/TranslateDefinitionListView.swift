//
//  TranslateDefinitionListView.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import MITMProxy
import SwiftUI

struct TranslateDefinitionListView: View {
    @Binding var definitions: [TranslateDefinition]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(definitions.indices, id: \.self) {
                Toggle(self.definitions[$0].name, isOn: self.$definitions[$0].isChecked)
            }
        }
    }
}

struct TranslateDefinitionListView_Previews: PreviewProvider {
    @State static var definitions: [TranslateDefinition] = [
        TranslateDefinition(name: "one", definition: TranslateAddon.Definition(url: "", paths: [""])),
        TranslateDefinition(name: "two", definition: TranslateAddon.Definition(url: "", paths: [""])),
    ]

    static var previews: some View {
        TranslateDefinitionListView(definitions: $definitions)
    }
}
