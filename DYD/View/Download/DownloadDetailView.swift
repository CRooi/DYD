import AVKit
import Kingfisher
import Photos
import SwiftUI

struct DownloadDetailView: View {
    @ObservedObject var downloadItem: DownloadItem
    @Environment(\.dismiss) var dismiss
    @State private var isShowingPlayer = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteConfirmation = false
    @ObservedObject private var downloadManager = DownloadManager.shared

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: downloadItem.createdTime)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        KFImage(URL(string: downloadItem.coverUrl))
                            .antialiased(true)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 128, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }

                    Text(downloadItem.title)
                }

                HStack {
                    Text("Created Time")
                    Spacer()
                    Text(formattedDate)
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Author")
                    Spacer()
                    Text(downloadItem.author)
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Type")
                    Spacer()
                    Text(downloadItem.type == .video ? "Video" : "Music")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Status")
                    Spacer()
                    statusText
                        .foregroundColor(.gray)
                }
            } header: {
                Text("Information")
            }

            if case .downloading(let progress) = downloadItem.status {
                Section {
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 8)

                        HStack {
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button("Cancel") {
                                downloadManager.cancelDownload(downloadItem)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Download Progress")
                }
            }

            if case .completed = downloadItem.status {
                Section {
                    Button {
                        isShowingPlayer = true
                    } label: {
                        Label("Preview", systemImage: "play.circle")
                    }

                    if downloadItem.type == .video {
                        Button {
                            saveToPhotos()
                        } label: {
                            Label("Save to Photo Library", systemImage: "photo")
                        }
                    }

                    Button {
                        shareFile()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text("Actions")
                }
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
        .navigationTitle("Detail")
        .alert("Message", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                downloadManager.deleteDownload(downloadItem)
                dismiss()
            }
        } message: {
            Text("Are you sure to delete this download history?")
        }
        .sheet(isPresented: $isShowingPlayer) {
            if let localPath = downloadItem.localPath,
                let url = URL(string: localPath)
            {
                if downloadItem.type == .video {
                    VideoPlayerView(url: url)
                } else {
                    MusicPlayerView(url: url, title: downloadItem.title)
                }
            }
        }
    }

    var statusText: some View {
        switch downloadItem.status {
        case .pending:
            return Text("Pending")
        case .downloading(let progress):
            return Text("Downloading (\(Int(progress * 100))%)")
        case .completed:
            return Text("Completed")
        case .failed(let error):
            return Text("Failed: \(error)")
        case .cancelled:
            return Text("Cancelled")
        }
    }

    private func saveToPhotos() {
        guard let localPath = downloadItem.localPath,
            let url = URL(string: localPath)
        else {
            alertMessage = String(localized: "File not found")
            showingAlert = true
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            alertMessage = String(localized: "Video saved successfully")
                        } else {
                            let errorMessage =
                                error?.localizedDescription ?? String(localized: "Unknown error")
                            alertMessage = String(
                                localized: "Failed to save video: \(errorMessage)")
                        }
                        showingAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = String(
                        localized: "Please allow access to Photo Library in Settings")
                    showingAlert = true
                }
            }
        }
    }

    private func shareFile() {
        guard let localPath = downloadItem.localPath,
            let url = URL(string: localPath)
        else {
            alertMessage = String(localized: "File not found")
            showingAlert = true
            return
        }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController
        {
            rootViewController.present(activityVC, animated: true)
        }
    }
}
