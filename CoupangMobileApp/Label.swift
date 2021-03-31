//
//  Label.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/26/21.
//

import SwiftUI

struct Label: View {
    let text: String
    let image: String

    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 14, height: 14)
            Text(text)
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label(text: "hi", image: "aos")
    }
}
