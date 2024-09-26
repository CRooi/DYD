//
//  MainView.swift
//  DYD
//
//  Created by CRooi on 2024/9/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            WelcomeView()
                .tabItem { Label("Home", systemImage: "house") }
            
            ParseView()
                .tabItem { Label("Parse", systemImage: "link") }
        }
    }
}

#Preview {
    MainView()
}
