//
//  Label.swift
//  AOIOMI
//
//  Created by vlsolome on 2/26/21.
//

import CommonUI
import SwiftUI

struct Label: View {
    let text: String
    var style: ImageActivityIndicator.Style?
    var highlighted: Bool = false

    var body: some View {
        HStack {
            if let image = style?.image {
                image
                    .resizable()
                    .foregroundColor(highlighted ? (style?.color ?? .primary) : .secondary)
                    .frame(width: 14, height: 14)
            }
            Text(text)
                .font(.footnote)
                .foregroundColor(highlighted ? .primary : .secondary)
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label(text: "hi", style: .aos)
        Label(text: "hi", style: .aos, highlighted: true)
    }
}
