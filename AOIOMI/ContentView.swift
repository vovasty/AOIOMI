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
        case aos, ios, permzone, translator, settings
    }

    @State private var selection: Page?
    @EnvironmentObject private var emulator: AOSEmulator
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var userSettings: UserSettings

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    NavigationLink(
                        destination: AOSView().frame(maxWidth: .infinity, alignment: .topLeading),
                        tag: .aos,
                        selection: $selection
                    ) {
                        if case AOSEmulator.State.stopped = emulator.state {
                            Label(text: "Android", image: "aos")
                        } else {
                            Label(text: "Android", image: "aos", highlighted: true)
                        }
                    }
                    NavigationLink(
                        destination: IOSView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .ios,
                        selection: $selection
                    ) {
                        if case IOSSimulator.State.stopped = simulator.state {
                            Label(text: "iOS", image: "ios")
                        } else {
                            Label(text: "iOS", image: "ios", highlighted: true)
                        }
                    }
                    Section(header: Label(text: "Proxy", image: "proxy")) {
                        NavigationLink(
                            destination: PermZoneView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .permzone,
                            selection: $selection
                        ) {
                            if userSettings.activePermZone == nil {
                                Label(text: "Permzone")
                            } else {
                                Label(text: "Permzone", highlighted: true)
                            }
                        }
                        NavigationLink(
                            destination: TranslateView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .translator,
                            selection: $selection
                        ) {
                            if userSettings.isTranslating {
                                Label(text: "Translator", highlighted: true)
                            } else {
                                Label(text: "Translator")
                            }
                        }
                        NavigationLink(
                            destination: ProxySettingsView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .settings,
                            selection: $selection
                        ) {
                            Label(text: "Settings")
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(height: geometry.size.height, alignment: .topLeading)
                .onAppear {
                    self.selection = .aos
                }
            }
        }
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .frame(width: 400, height: 300, alignment: .leading)
                .environmentObject(AOSEmulator.preview(state: .configuring))
                .environmentObject(IOSSimulator.preview(state: .started))
                .environmentObject(IOSAppManager.preview())
                .environmentObject(AOSAppManager.preview())
                .environmentObject(UserSettings())
        }
    }
#endif