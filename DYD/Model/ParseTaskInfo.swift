//
//  ParseTaskInfo.swift
//  DYD
//
//  Created by CRooi on 2024/9/30.
//

import Foundation

struct ParseTaskInfo: Codable, Identifiable {
    let id: UUID
    let parseTime: Date
    let parseItem: ParseItem
    
    init(parseItem: ParseItem) {
        self.id = UUID()
        self.parseTime = Date()
        self.parseItem = parseItem
    }
}
