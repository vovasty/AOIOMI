//
//  ActivityView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/14/21.
//

import Combine
import SwiftUI

struct ActivityView: View {
    enum ActivityState {
        case busy(String), error(String, Error), text(String)
    }

    private let style: ImageActivityIndicator.Style
    private var state: Binding<ActivityState>
    @State private var isAnimating: Bool = true
    @State private var isLogoVisible: Bool = true

    init(style: ImageActivityIndicator.Style, state: Binding<ActivityState>) {
        self.state = state
        self.style = style
    }

    var body: some View {
        VStack {
            ZStack {
                if isLogoVisible {
                    ImageActivityIndicator(style: style, isAnimating: isAnimating)
                }
                VStack {
                    switch state.wrappedValue {
                    case .busy:
                        ErrorView(error: nil)
                    case .text:
                        ErrorView(error: nil)
                    case let .error(_, error):
                        ErrorView(error: error)
                    }
                }
            }
            switch state.wrappedValue {
            case let .busy(text):
                Text(text)
            case let .text(text):
                Text(text)
            case let .error(text, _):
                Text(text)
            }
        }
        .frame(minHeight: 80, maxHeight: 80)
        .onReceive(Just(state)) { _ in
            switch state.wrappedValue {
            case .busy:
                isLogoVisible = true
                isAnimating = true
            case .error:
                isLogoVisible = false
                isAnimating = false
            case .text:
                isLogoVisible = true
                isAnimating = false
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(style: .ios, state: .constant(.busy("busy...")))
        ActivityView(style: .ios, state: .constant(.error("error", NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "terrible error terrible error terrible error terrible error terrible error terrible error"]))))
            .frame(width: 100)
        ActivityView(style: .ios, state: .constant(.text("text")))
        ActivityView(style: .aos, state: .constant(.text("text")))
    }
}
