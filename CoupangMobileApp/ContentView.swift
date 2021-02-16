//
//  ContentView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 10/9/20.
//

import AndroidEmulator
import iOSSimulator
import SwiftUI

struct ContentView: View {
    enum Page: Int {
        case aos, ios
    }

    @EnvironmentObject var emulator: AndroidEmulator
    @EnvironmentObject var simulator: iOSSimulator
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
        .onAppear {
            simulator.check()
            emulator.check()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
