//
//  TranslateDefinitionListView.swift
//  CoupangProxy
//
//  Created by vlsolome on 2/5/21.
//

import MITMProxy
import SwiftUI
import TranslatorAddon

struct TranslateDefinitionListView: View {
    @Binding var definitions: [TranslatorDefinition]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(definitions.indices, id: \.self) {
                Toggle(self.definitions[$0].name, isOn: self.$definitions[$0].isChecked)
            }
        }
    }
}

struct TranslateDefinitionListView_Previews: PreviewProvider {
    @State static var definitions: [TranslatorDefinition] = [
        TranslatorDefinition(name: "one", definition: TranslatorAddon.Definition(url: "", paths: [""])),
        TranslatorDefinition(name: "two", definition: TranslatorAddon.Definition(url: "", paths: [""])),
    ]

    static var previews: some View {
        TranslateDefinitionListView(definitions: $definitions)
    }
}
