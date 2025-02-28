//
//  SettingsView.swift
//  DYD
//
//  Created by CRooi on 2024/9/27.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Parse")) {
                    Toggle(isOn: $userSettings.autoDownloadAfterParse) {
                        VStack(alignment: .leading) {
                            Text("Auto Download Video")
                                .font(.headline)
                            Text("Automatically add video download task after successful parse.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Download")) {
                    Toggle(isOn: $userSettings.autoSaveToPhotoLibrary) {
                        VStack(alignment: .leading) {
                            Text("Auto Save to Photo Library")
                                .font(.headline)
                            Text("Automatically save videos to photo library when download completes.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
