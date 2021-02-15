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

    @Binding var state: ActivityState
    @State private var isAnimating: Bool = true

    var body: some View {
        VStack {
            ZStack {
                ProgressIndicator(controlSize: .regular,
                                  isDisplayedWhenStopped: false,
                                  style: .constant(.spinning),
                                  isAnimating: $isAnimating)
                VStack {
                    switch state {
                    case .busy:
                        ErrorView(error: nil)
                    case .text:
                        ErrorView(error: nil)
                    case let .error(_, error):
                        ErrorView(error: error)
                    }
                }
            }
            switch state {
            case let .busy(text):
                Text(text)
            case let .text(text):
                Text(text)
            case let .error(text, _):
                Text(text)
            }
        }
        .frame(minHeight: 50, maxHeight: 50)
        .onReceive(Just(state)) { _ in
            switch state {
            case .busy:
                isAnimating = true
            case .error, .text:
                isAnimating = false
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(state: .constant(.busy("busy...")))
        ActivityView(state: .constant(.error("error", NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "terrible error terrible error terrible error terrible error terrible error terrible error"]))))
            .frame(width: 100)
        ActivityView(state: .constant(.text("text")))
    }
}
