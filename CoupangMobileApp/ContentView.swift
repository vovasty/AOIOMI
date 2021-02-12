//
//  ContentView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import SwiftUI

struct ContentView: View {
    enum Page: Int {
        case aos, ios
    }
    @State var segment: Page = .aos

    var body: some View {
        VStack {
            Picker("", selection: $segment) {
                Text("AOS").tag(Page.aos)
                Text("iOS").tag(Page.ios)
            }
            .pickerStyle(SegmentedPickerStyle())
            switch segment {
            case .aos:
                AOSView()
                    .frame(width: 200, height: 200)
            case .ios:
                IOSView()
                    .frame(width: 200, height: 200)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
