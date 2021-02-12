//
//  ProgressView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI

struct ProgressView: View {
    var title: String

    var body: some View {
        Text(title)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(title: "Working...")
    }
}
