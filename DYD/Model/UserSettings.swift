//
//  UserSettings.swift
//  DYD
//
//  Created by CRooi on 2024/9/27.
//

import SwiftUI

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var autoDownloadAfterParse: Bool {
        didSet {
            UserDefaults.standard.set(autoDownloadAfterParse, forKey: "autoDownloadAfterParse")
        }
    }
    
    @Published var autoSaveToPhotoLibrary: Bool {
        didSet {
            UserDefaults.standard.set(autoSaveToPhotoLibrary, forKey: "autoSaveToPhotoLibrary")
        }
    }
    
    private init() {
        self.autoDownloadAfterParse = UserDefaults.standard.bool(forKey: "autoDownloadAfterParse")
        self.autoSaveToPhotoLibrary = UserDefaults.standard.bool(forKey: "autoSaveToPhotoLibrary")
    }
}
