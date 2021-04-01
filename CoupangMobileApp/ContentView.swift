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

    @State var selection: Page?

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    NavigationLink(
                        destination: AOSView().frame(maxWidth: .infinity, alignment: .topLeading),
                        tag: .aos,
                        selection: $selection
                    ) {
                        Label(text: "Android", image: "aos")
                    }
                    NavigationLink(
                        destination: IOSView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .ios,
                        selection: $selection
                    ) {
                        Label(text: "iOS", image: "ios")
                    }
                    Section(header: Label(text: "Proxy", image: "proxy")) {
                        NavigationLink(
                            destination: PermZoneView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .permzone,
                            selection: $selection
                        ) {
                            Text("Permzone")
                        }
                        NavigationLink(
                            destination: TranslateView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .translator,
                            selection: $selection
                        ) {
                            Text("Translator")
                        }
                        NavigationLink(
                            destination: ProxySettingsView().frame(maxWidth: .infinity, alignment: .leading),
                            tag: .settings,
                            selection: $selection
                        ) {
                            Text("Settings")
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
