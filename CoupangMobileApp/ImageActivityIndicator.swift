//
//  ImageActivityIndicator.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/14/21.
//

import SwiftUI

struct ImageActivityIndicator: View {
    enum Style {
        case ios, aos
    }

    private let isAnimating: Bool
    private var imageName: String
    private var color: Color

    init(style: Style, isAnimating: Bool = true) {
        switch style {
        case .aos:
            imageName = "aos"
            color = Color("aos")
        case .ios:
            imageName = "ios"
            color = Color("ios")
        }
        self.isAnimating = isAnimating
    }

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            if isAnimating {
                ActivityIndicator()
                    .frame(width: 60, height: 60)
                    .foregroundColor(color)
            }
        }
        .frame(minWidth: 60, minHeight: 60)
    }
}

struct ImageActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ImageActivityIndicator(style: .ios)
        ImageActivityIndicator(style: .aos)
        ImageActivityIndicator(style: .aos, isAnimating: false)
    }
}
