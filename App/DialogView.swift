//
//  DialogView.swift
//  AOIOMI
//
//  Created by vlsolome on 2/21/21.
//

import SwiftUI

struct DialogButton: View {
    let title: String
    let keyEquivalent: NativeButton.KeyEquivalent
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        NativeButton(title, keyEquivalent: .escape) {
            action()
        }
        .disabled(disabled)
    }

    public static func `default`(_ title: String, disabled: Bool = false, action: @escaping (() -> Void) = {}) -> Self {
        Self(title: title, keyEquivalent: .return, disabled: disabled, action: action)
    }

    public static func cancel(_ title: String, disabled: Bool = false, action: @escaping (() -> Void) = {}) -> Self {
        Self(title: title, keyEquivalent: .escape, disabled: disabled, action: action)
    }
}

struct DialogView<Content: View>: View {
    let content: Content
    private let buttons: [DialogButton]

    init(primaryButton: DialogButton = .default("OK", action: {}), secondaryButton: DialogButton? = nil, @ViewBuilder content: () -> Content) {
        buttons = [primaryButton, secondaryButton].compactMap { $0 }
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .center) {
            content
                .frame(maxWidth: .infinity)
            HStack(alignment: .center) {
                Spacer()
                ForEach(0 ..< buttons.count, id: \.self) {
                    buttons[$0]
                }
            }
        }
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(primaryButton: .default("YUP", action: {}), secondaryButton: .cancel("NOPE", action: {})) {
            VStack {
                Text("HERE WEGO")
            }
        }
        .frame(width: 300)
        DialogView(primaryButton: .default("YUP", action: {}), secondaryButton: .cancel("NOPE", action: {})) {
            VStack {
                Text("HERE WEGO HERE WEGO HERE WEGO")
            }
        }
        .frame(width: 300)
    }
}
