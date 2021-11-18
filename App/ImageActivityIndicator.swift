//
//  ImageActivityIndicator.swift
//  AOIOMI
//
//  Created by vlsolome on 2/14/21.
//

import SwiftUI

struct ImageActivityIndicator: View {
    enum Style {
        case ios, aos, proxy, zone, translator, payload

        var color: Color {
            switch self {
            case .aos:
                return Color("aos")
            case .ios:
                return Color("ios")
            case .proxy:
                return Color("proxy")
            case .translator:
                return Color("translator")
            case .zone:
                return Color("zone")
            case .payload:
                return Color("payload")
            }
        }

        var image: Image {
            switch self {
            case .aos:
                return Image("aos")
            case .ios:
                return Image("ios")
            case .proxy:
                return Image("proxy")
            case .translator:
                return Image("translator")
            case .zone:
                return Image("zone")
            case .payload:
                return Image("payload")
            }
        }
    }

    let style: Style
    var isAnimating: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                style.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(style.color)
                    .frame(width: geometry.size.width - 8, height: geometry.size.height - 8)
                if isAnimating {
                    ActivityIndicator(count: 2, width: 1, spacing: 1)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(style.color)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ImageActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ImageActivityIndicator(style: .ios)
            .frame(width: 40, height: 40)
        ImageActivityIndicator(style: .aos)
            .frame(width: 30, height: 30)
        ImageActivityIndicator(style: .aos, isAnimating: true)
            .frame(width: 20, height: 20)
        ImageActivityIndicator(style: .aos, isAnimating: false)
            .frame(width: 20, height: 20)
        ImageActivityIndicator(style: .proxy, isAnimating: true)
            .frame(width: 40, height: 40)
    }
}
