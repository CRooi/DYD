//
//  ParseDetailView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import SwiftUI
import Kingfisher

struct ParseDetailView: View {
    var parseItem: ParseItem
    
    var body: some View {
        content
            .navigationTitle("Detail")
    }
    
    var content: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    KFImage(URL(string: parseItem.video.coverUrl))
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 128, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                    
                    Text("\(parseItem.caption)")
                }
            } header: {
                Text("Meta Data")
            }
            
            Section {
                HStack {
                    Text("Nickname")
                    
                    Spacer()
                    
                    VStack {
                        Text("\(parseItem.author.name)")
                            .foregroundColor(.gray)
                        
                        if !parseItem.author.customVerify.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark")
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
                                Image(systemName: "checkmark")
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
                
                Button("Download") {
                    
                }
            } header: {
                Text("Music")
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
                
                Button("Download") {
                    
                }
            } header: {
                Text("Video")
            }
        }
    }
}
