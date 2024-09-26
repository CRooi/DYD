//
//  ParsePreviewView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import SwiftUI
import Kingfisher

struct ParsePreviewView: View {
    var parseItem: ParseItem
    
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: parseItem.createdTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            KFImage(URL(string: parseItem.video.coverUrl))
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(parseItem.caption == "" ? "No Caption" : parseItem.caption)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .bold()
                Group {
                    Text("\(parseItem.author.name)\n\(formattedDate)")
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
