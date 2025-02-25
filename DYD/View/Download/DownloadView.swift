//
//  DownloadView.swift
//  DYD
//
//  Created by CRooi on 2024/9/26.
//

import SwiftUI

struct DownloadView: View {
    @ObservedObject var downloadManager = DownloadManager.shared
    @State private var itemToDelete: DownloadItem?

    var body: some View {
        NavigationView {
            Group {
                if downloadManager.downloads.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No Download History")
                            .font(.title2)
                            .fontWeight(.medium)

                        Text("Download history will appear here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        Section(header: Text("History")) {
                            ForEach(
                                downloadManager.downloads.sorted(by: {
                                    $0.createdTime > $1.createdTime
                                })
                            ) { item in
                                NavigationLink {
                                    DownloadDetailView(downloadItem: item)
                                } label: {
                                    DownloadPreviewView(downloadItem: item)
                                }
                                .swipeActions(edge: .trailing) {
                                    if case .downloading = item.status {
                                        Button(role: .destructive) {
                                            downloadManager.cancelDownload(item)
                                        } label: {
                                            Label("Cancel", systemImage: "xmark.circle")
                                        }
                                    } else {
                                        Button(role: .destructive) {
                                            downloadManager.deleteDownload(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Downloads")
        }
    }
}
