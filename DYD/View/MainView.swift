//
//  MainView.swift
//  DYD
//
//  Created by CRooi on 2024/9/23.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WelcomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            ParseView()
                .tabItem { Label("Parse", systemImage: "link") }
                .tag(1)

            DownloadView()
                .tabItem { Label("Download", systemImage: "square.and.arrow.down") }
                .tag(2)
        }
        .onAppear {
            setupNotifications()
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SwitchToDownloadTab"),
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = 2
        }
    }
}
