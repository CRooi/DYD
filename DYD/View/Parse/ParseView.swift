//
//  ParseView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import SwiftUI
import Alamofire

struct HistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    let parseItem: ParseItem
    
    init(parseItem: ParseItem) {
        self.id = UUID()
        self.parseItem = parseItem
    }

    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.id == rhs.id && lhs.parseItem == rhs.parseItem
    }
}

struct ParseView: View {
    @State private var share: String = ""
    @State private var history: [HistoryItem] = []
    @State private var isParsing: Bool = false
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Parse")
        }
        .onAppear(perform: loadHistory)
    }
    
    var content: some View {
        List {
            Section {
                TextField("Share link or text", text: $share)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .disabled(isParsing)
            } header: {
                Text("Parse")
            }
            
            Section {
                Button(action: {
                    parse()
                }) {
                    if isParsing {
                        Text("Parsing...").foregroundColor(.gray)
                    } else {
                        Text("Parse")
                    }
                }
                .disabled(isParsing)
            }
            
            Section {
                if history.isEmpty {
                    Text("No History")
                        .foregroundColor(.gray)
                } else {
                    ForEach(history) { item in
                        NavigationLink(destination: ParseDetailView(parseItem: item.parseItem, onDelete: {
                            withAnimation {
                                deleteHistoryItem(item)
                            }
                        })) {
                            ParsePreviewView(parseItem: item.parseItem)
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            deleteHistoryItems(at: indexSet)
                        }
                    }
                }
            } header: {
                Text("History")
            }
        }
        .animation(.default, value: history)
    }
    
    func parse() {
        isParsing = true
        
        let urlPattern = "https?://[^\\s]+"
        let regex = try? NSRegularExpression(pattern: urlPattern)
        let range = NSRange(location: 0, length: share.utf16.count)
        
        if let match = regex?.firstMatch(in: share, options: [], range: range) {
            let matchedURL = (share as NSString).substring(with: match.range)
            
            AF.request("https://douyin.shindo.icu/api/hybrid/video_data?url=" + matchedURL).responseJSON { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let value):
                        // 打印整个响应数据
                        // debugPrint("Full JSON Response: \(value)")
                        
                        // 尝试解析 data
                        guard let json = value as? [String: Any],
                              let data = json["data"] as? [String: Any] else {
                            debugPrint("Failed to parse 'data' from JSON")
                            return
                        }
                        
                        // 解析 author 数据
                        guard let authorData = data["author"] as? [String: Any] else {
                            debugPrint("Missing 'author' data")
                            return
                        }
                        let authorName = authorData["nickname"] as? String ?? "Unknown Author"
                        let customVerify = authorData["custom_verify"] as? String ?? ""
                        let enterpriseVerifyReason = authorData["enterprise_verify_reason"] as? String ?? ""
                        let following = authorData["following_count"] as? Int ?? 0
                        let follower = authorData["follower_count"] as? Int ?? 0
                        debugPrint("Author Name: \(authorName), Followers: \(follower), Following: \(following)")
                        
                        // 解析 video 数据
                        guard let videoData = data["video"] as? [String: Any] else {
                            debugPrint("Missing 'video' data")
                            return
                        }

                        // 修改 big_thumbs 和 bit_rate 的解包方式
                        let videoDuration: Double = data["duration"] as? Double ?? 0.0

                        var fps: Double = 0.0
                        var bitRate: Double = 0.0
                        if let bitRates = videoData["bit_rate"] as? [[String: Any]],
                           let firstBitRate = bitRates.first {
                            fps = firstBitRate["FPS"] as? Double ?? 0.0
                            bitRate = firstBitRate["bit_rate"] as? Double ?? 0.0
                        }
                        
                        let format = videoData["format"] as? String ?? "Unknown Format"
                        
                        // 解包 video URL 和 cover URL
                        let videoUrl = ((videoData["play_addr"] as? [String: Any])?["url_list"] as? [String])?.first ?? ""
                        let coverUrl = ((videoData["cover"] as? [String: Any])?["url_list"] as? [String])?.first ?? ""
                        debugPrint("Video URL: \(videoUrl), Cover URL: \(coverUrl)")
                        
                        // 解析 music 数据
                        guard let musicData = data["music"] as? [String: Any] else {
                            debugPrint("Missing 'music' data")
                            return
                        }
                        let musicAuthor = musicData["author"] as? String ?? "Unknown Music Author"
                        
                        // 解包 avatar URL 和 music URL
                        let avatarUrl = ((musicData["avatar_large"] as? [String: Any])?["url_list"] as? [String])?.first ?? ""
                        let musicUrl = ((musicData["play_url"] as? [String: Any])?["url_list"] as? [String])?.first ?? ""
                        let musicTitle = musicData["title"] as? String ?? "Unknown Music Title"
                        let musicDuration = musicData["shoot_duration"] as? Double ?? 0.0
                        debugPrint("Music Title: \(musicTitle), Music URL: \(musicUrl)")
                        
                        // 解析其他数据
                        let caption = data["desc"] as? String ?? "No Caption"
                        let createdTime = data["create_time"] as? TimeInterval ?? 0.0
                        debugPrint("Caption: \(caption), Created Time: \(createdTime)")
                        
                        // 创建 ParseItem 对象
                        let author = Author(
                            name: authorName,
                            customVerify: customVerify,
                            enterpriseVerifyReason: enterpriseVerifyReason,
                            following: following,
                            follower: follower
                        )
                        
                        let music = Music(
                            author: musicAuthor,
                            avatarUrl: avatarUrl,
                            url: musicUrl,
                            title: musicTitle,
                            duration: musicDuration
                        )
                        
                        let video = Video(
                            duration: videoDuration,
                            fps: fps,
                            bitRate: bitRate,
                            format: format,
                            url: videoUrl,
                            coverUrl: coverUrl
                        )
                        
                        let newItem = HistoryItem(parseItem: ParseItem(
                            caption: caption,
                            createdTime: createdTime,
                            author: author,
                            music: music,
                            video: video,
                            originLink: share
                        ))
                        
                        self.history.insert(newItem, at: 0)
                        saveHistory()
                        debugPrint("Parsed successfully: \(caption), \(authorName), \(createdTime)")
                        
                    case .failure(let error):
                        debugPrint("Error: \(error)")
                    }
                    
                    self.isParsing = false
                }
            }
        } else {
            debugPrint("Invalid URL in share")
            self.isParsing = false
        }
    }



    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "parseHistory") {
            if let decodedHistory = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                self.history = decodedHistory
            }
        }
    }
    
    func saveHistory() {
        if let encodedHistory = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedHistory, forKey: "parseHistory")
        }
    }
    
    func deleteHistoryItems(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func deleteHistoryItem(_ item: HistoryItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: index)
            saveHistory()
        }
    }
}
