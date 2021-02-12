//
//  ErrorView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI

struct ErrorView: View {
    let error: Error?

    var body: some View {
        VStack {
            if let error = error {
                Text(error.localizedDescription)
                    .lineLimit(2)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "boom!"])
        ErrorView(error: error)
    }
}
