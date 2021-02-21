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

    init(style: ImageActivityIndicator.Style, state: Binding<ActivityState>) {
        self.state = state
        self.style = style
    }

    var body: some View {
        VStack {
            ZStack {
                ImageActivityIndicator(style: style, isAnimating: isAnimating)
                switch state.wrappedValue {
                case .busy:
                    EmptyView()
                case .text:
                    EmptyView()
                case let .error(_, error):
                    ErrorView(error: error)
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
                isAnimating = true
            case .error:
                isAnimating = false
            case .text:
                isAnimating = false
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "terrible error terrible error terrible error terrible error terrible error terrible error"])

    static var previews: some View {
        ActivityView(style: .ios, state: .constant(.busy("busy...")))
        ActivityView(style: .ios, state: .constant(.error("error", error)))
            .frame(width: 100)
        ActivityView(style: .aos, state: .constant(.error("error", error)))
            .frame(width: 100)
        ActivityView(style: .ios, state: .constant(.text("text")))
        ActivityView(style: .aos, state: .constant(.text("text")))
    }
}
