//
//  ParseItem.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import Foundation

struct ParseItem: Codable, Equatable {
    var caption: String
    var createdTime: TimeInterval
    var author: Author
    var music: Music
    var video: Video
    var originLink: String
}

struct Author: Codable, Equatable {
    var name: String
    var customVerify: String
    var enterpriseVerifyReason: String
    var following: Int
    var follower: Int
}

struct Music: Codable, Equatable {
    var author: String
    var avatarUrl: String
    var url: String
    var title: String
    var duration: Double
}

struct Video: Codable, Equatable {
    var duration: Double
    var fps: Double
    var bitRate: Double
    var format: String
    var url: String
    var coverUrl: String
}
