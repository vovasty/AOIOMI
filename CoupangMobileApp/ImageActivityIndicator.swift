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
        GeometryReader { geometry in
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width - 8, height: geometry.size.height - 8)
                if isAnimating {
                    ActivityIndicator(count: 2, width: 1, spacing: 1)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(color)
                }
            }
        }
    }
}

struct ImageActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ImageActivityIndicator(style: .ios)
            .frame(width: 40, height: 40)
        ImageActivityIndicator(style: .aos)
            .frame(width: 30, height: 30)
        ImageActivityIndicator(style: .aos, isAnimating: false)
            .frame(width: 20, height: 20)
    }
}
