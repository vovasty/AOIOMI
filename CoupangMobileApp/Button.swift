//
//  Button.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 12/18/20.
//

import SwiftUI

struct Button: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(action: action) {
            Text(title)
                .frame(width: 100)
        }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        Button("hi", action: {})
    }
}
