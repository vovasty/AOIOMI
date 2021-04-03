//
//  Label.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/26/21.
//

import SwiftUI

struct Label: View {
    let text: String
    var image: String?
    var highlighted: Bool = false

    var body: some View {
        HStack {
            if let image = image {
                Image(image)
                    .resizable()
                    .frame(width: 14, height: 14)
            }
            Text(text)
                .font(!highlighted ? .footnote : Font.footnote.weight(.bold))
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label(text: "hi", image: "aos")
        Label(text: "hi", image: "aos", highlighted: true)
    }
}
