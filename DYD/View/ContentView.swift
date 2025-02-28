//
//  ContentView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            ParseView()
                .tabItem {
                    Label("Parse", systemImage: "doc.text.magnifyingglass")
                }
                .tag(0)
            
            DownloadView()
                .tabItem {
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
                .tag(1)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToDownloadTab"))) { _ in
                    // Always switch to downloads tab when notification is received
                    selection = 1
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}
