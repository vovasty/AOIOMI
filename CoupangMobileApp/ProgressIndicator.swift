//
//  ActivityIndicator.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/13/21.
//

import AppKit
import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
    var controlSize: NSControl.ControlSize = .small
    var isDisplayedWhenStopped: Bool = true

    @Binding var style: NSProgressIndicator.Style
    @Binding var isAnimating: Bool

    func makeNSView(context _: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let result = NSProgressIndicator()
        result.isIndeterminate = true
        result.startAnimation(nil)
        result.controlSize = controlSize
        result.isDisplayedWhenStopped = isDisplayedWhenStopped
        return result
    }

    func updateNSView(_ nsView: NSProgressIndicator, context _: NSViewRepresentableContext<ProgressIndicator>) {
        nsView.style = style
        if isAnimating {
            nsView.startAnimation(nil)
        } else {
            nsView.stopAnimation(nil)
        }
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator(controlSize: .small, isDisplayedWhenStopped: false, style: .constant(NSProgressIndicator.Style.spinning), isAnimating: .constant(true))
        ProgressIndicator(controlSize: .small, style: .constant(NSProgressIndicator.Style.spinning), isAnimating: .constant(false))
        ProgressIndicator(controlSize: .small, isDisplayedWhenStopped: false, style: .constant(NSProgressIndicator.Style.spinning), isAnimating: .constant(false))
        ProgressIndicator(controlSize: .small, isDisplayedWhenStopped: false, style: .constant(NSProgressIndicator.Style.bar), isAnimating: .constant(true))
            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
    }
}
