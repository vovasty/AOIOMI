//
//  ContentView.swift
//  AOIOMI
//
//  Created by vlsolome on 10/9/20.
//

import AOSEmulator
import IOSSimulator
import MITMProxy
import SwiftUI

struct ContentView: View {
    enum Page: Int {
        case aos, ios, permzone, translator, settings
    }

    @State private var selection: Page?
    @EnvironmentObject private var emulator: AOSEmulator
    @EnvironmentObject private var simulator: IOSSimulator
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var mitmProxy: MITMProxy

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App").font(.footnote)) {
                    NavigationLink(
                        destination: AOSView().frame(maxWidth: .infinity, alignment: .topLeading),
                        tag: .aos,
                        selection: $selection
                    ) {
                        if case AOSEmulator.State.started = emulator.state {
                            Label(text: "Android", style: .aos, highlighted: true)
                        } else {
                            Label(text: "Android", style: .aos)
                        }
                    }
                    NavigationLink(
                        destination: IOSView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .ios,
                        selection: $selection
                    ) {
                        if case IOSSimulator.State.started = simulator.state {
                            Label(text: "iOS", style: .ios, highlighted: true)
                        } else {
                            Label(text: "iOS", style: .ios)
                        }
                    }
                }
                Section(header: Text("Addons").font(.footnote)) {
                    NavigationLink(
                        destination: PermZoneView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .permzone,
                        selection: $selection
                    ) {
                        if userSettings.activePermZone != nil, case MITMProxy.State.started = mitmProxy.state {
                            Label(text: "Permzone", style: .zone, highlighted: true)
                        } else {
                            Label(text: "Permzone", style: .zone)
                        }
                    }
                    NavigationLink(
                        destination: TranslateView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .translator,
                        selection: $selection
                    ) {
                        if userSettings.isTranslating, case MITMProxy.State.started = mitmProxy.state {
                            Label(text: "Translator", style: .translator, highlighted: true)
                        } else {
                            Label(text: "Translator", style: .translator)
                        }
                    }
                    NavigationLink(
                        destination: ProxyView().frame(maxWidth: .infinity, alignment: .leading),
                        tag: .settings,
                        selection: $selection
                    ) {
                        if case MITMProxy.State.started = mitmProxy.state {
                            Label(text: "Proxy", style: .proxy, highlighted: true)
                        } else {
                            Label(text: "Proxy", style: .proxy)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(alignment: .topLeading)
            .onAppear {
                self.selection = .aos
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