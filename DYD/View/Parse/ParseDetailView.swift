//
//  ParseDetailView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import AVKit
import Kingfisher
import SwiftUI

struct ParseDetailView: View {
    var parseItem: ParseItem
    var onDelete: () -> Void
    @State private var isShowingMusicPlayer = false
    @State private var isShowingVideoPlayer = false
    @State private var showingDeleteConfirmation = false

    var formattedDate: String {
        let date = Date(timeIntervalSince1970: parseItem.createdTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    var body: some View {
        content
            .navigationTitle("Detail")
            .sheet(isPresented: $isShowingMusicPlayer) {
                if let url = URL(string: parseItem.music.url) {
                    MusicPlayerView(url: url, title: parseItem.music.title)
                }
            }
            .sheet(isPresented: $isShowingVideoPlayer) {
                if let url = URL(string: parseItem.video.url) {
                    VideoPlayerView(url: url)
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this parse history?")
            }
    }

    var content: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        KFImage(URL(string: parseItem.video.coverUrl))
                            .antialiased(true)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 128, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .contextMenu {
                                Button(action: {
                                    print("1")
                                }) {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                }
                            }
                    }

                    Text("\(parseItem.caption)")
                }

                HStack {
                    Text("Create Time")

                    Spacer()

                    Text("\(formattedDate)")
                        .foregroundColor(.gray)
                }
            } header: {
                Text("Meta Data")
            }

            Section {
                HStack {
                    Text("Nickname")

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(parseItem.author.name)")
                            .foregroundColor(.gray)

                        if !parseItem.author.customVerify.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.orange)

                                Text("\(parseItem.author.customVerify)")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }

                        if !parseItem.author.enterpriseVerifyReason.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)

                                Text("\(parseItem.author.enterpriseVerifyReason)")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }

                HStack {
                    Text("Follower")

                    Spacer()

                    Text("\(parseItem.author.follower)")
                        .foregroundColor(.gray)
                }
            } header: {
                Text("Author")
            }
            
            Section {
                HStack {
                    Text("Duration")

                    Spacer()

                    Text("\(Int(parseItem.video.duration / 1000))s")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("FPS")

                    Spacer()

                    Text("\(Int(parseItem.video.fps))")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Bit Rate")

                    Spacer()

                    Text("\(Int(parseItem.video.bitRate))")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Format")

                    Spacer()

                    Text("\(parseItem.video.format)")
                        .foregroundColor(.gray)
                }

                Button {
                    isShowingVideoPlayer = true
                } label: {
                    Label("Watch", systemImage: "play.circle")
                }

                Button {
                    let downloadManager = DownloadManager.shared
                    downloadManager.addDownload(from: parseItem, type: .video)

                    // 跳转到下载页面
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SwitchToDownloadTab"), object: nil)
                } label: {
                    Label("Download", systemImage: "arrow.down.circle")
                }
            } header: {
                Text("Video")
            }
            
            Section {
                HStack {
                    Text("Author")

                    Spacer()

                    Text("\(parseItem.music.author)")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Title")

                    Spacer()

                    Text("\(parseItem.music.title)")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Duration")

                    Spacer()

                    Text("\(Int(parseItem.music.duration))s")
                        .foregroundColor(.gray)
                }

                Button {
                    isShowingMusicPlayer = true
                } label: {
                    Label("Listen", systemImage: "play.circle")
                }

                Button {
                    let downloadManager = DownloadManager.shared
                    downloadManager.addDownload(from: parseItem, type: .music)

                    // 跳转到下载页面
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SwitchToDownloadTab"), object: nil)
                } label: {
                    Label("Download", systemImage: "arrow.down.circle")
                }
            } header: {
                Text("Music")
            }
            
            Section {
                Text("\(parseItem.originLink)")
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = parseItem.originLink
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
            } header: {
                Text("Original Link")
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct MusicPlayerView: View {
    let url: URL
    let title: String

    @Environment(\.dismiss) var dismiss

    private var player: AVPlayer {
        AVPlayer(url: url)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()

            Text("Now Playing\n\(title)")
                .font(.headline)

            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
                .frame(maxHeight: .infinity)
        }
    }
}

struct VideoPlayerView: View {
    let url: URL

    @Environment(\.dismiss) var dismiss

    private var player: AVPlayer {
        AVPlayer(url: url)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()

            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
        }
    }
}
