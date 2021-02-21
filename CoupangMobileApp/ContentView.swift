//
//  ContentView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import AOSEmulator
import IOSSimulator
import SwiftUI

struct ContentView: View {
    enum Page: Int {
        case aos, ios
    }

    @EnvironmentObject var emulator: AOSEmulator
    @EnvironmentObject var simulator: IOSSimulator
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
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity, alignment: .top)
            case .ios:
                IOSView()
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity, alignment: .top)
            }
        }
        .padding()
        .frame(width: 240, height: 240)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
