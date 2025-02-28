import Foundation
import SwiftUI
import Photos

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloads: [DownloadItem] = []
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private var session: URLSession!
    @ObservedObject private var userSettings = UserSettings.shared

    // 单例实例
    static let shared = DownloadManager()

    override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "io.crooi.dyd.download")
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadDownloads()
        
        // 添加自动下载通知观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAddDownloadTaskNotification),
            name: Notification.Name("AddDownloadTask"),
            object: nil
        )
    }

    func addDownload(from parseItem: ParseItem, type: DownloadType) {
        let url: String
        let title: String

        switch type {
        case .video:
            url = parseItem.video.url
            title = parseItem.caption.isEmpty ? "Video" : parseItem.caption
        case .music:
            url = parseItem.music.url
            title = parseItem.music.title
        }

        let downloadItem = DownloadItem(
            type: type,
            url: url,
            title: title,
            author: parseItem.author.name,
            coverUrl: parseItem.video.coverUrl
        )

        downloads.append(downloadItem)
        saveDownloads()
        startDownload(downloadItem)
    }
    
    // 处理自动下载通知的方法
    @objc private func handleAddDownloadTaskNotification(notification: Notification) {
        if let parseItem = notification.userInfo?["parseItem"] as? ParseItem {
            addDownload(from: parseItem, type: .video)
            
            // 可选：发送通知切换到下载标签页
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToDownloadTab"), 
                object: nil,
                userInfo: ["fromAutoDownload": true]
            )
        }
    }

    private func startDownload(_ item: DownloadItem) {
        guard let url = URL(string: item.url) else { return }

        let task = session.downloadTask(with: url)
        task.taskDescription = item.id.uuidString
        task.resume()

        downloadTasks[item.id] = task
        item.status = .downloading(progress: 0)
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let taskDescription = downloadTask.taskDescription,
            let itemId = UUID(uuidString: taskDescription),
            let item = downloads.first(where: { $0.id == itemId })
        else {
            return
        }

        do {
            let documentsPath = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "\(item.id.uuidString).\(item.type == .video ? "mp4" : "mp3")"
            let destinationURL = documentsPath.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.moveItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                item.status = .completed
                item.localPath = destinationURL.absoluteString
                self.saveDownloads()
                
                // 如果启用了自动保存到照片图库且是视频，则自动保存
                if self.userSettings.autoSaveToPhotoLibrary && item.type == .video {
                    self.saveToPhotoLibrary(at: destinationURL)
                }
            }
        } catch {
            DispatchQueue.main.async {
                item.status = .failed(error: error.localizedDescription)
                self.saveDownloads()
            }
        }
    }

    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64
    ) {
        guard let taskDescription = downloadTask.taskDescription,
            let itemId = UUID(uuidString: taskDescription),
            let item = downloads.first(where: { $0.id == itemId })
        else {
            return
        }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            item.status = .downloading(progress: progress)
            self.saveDownloads()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        guard let downloadTask = task as? URLSessionDownloadTask,
            let taskDescription = downloadTask.taskDescription,
            let itemId = UUID(uuidString: taskDescription),
            let item = downloads.first(where: { $0.id == itemId })
        else {
            return
        }

        if let error = error {
            DispatchQueue.main.async {
                item.status = .failed(error: error.localizedDescription)
                self.saveDownloads()
            }
        }
    }

    func cancelDownload(_ item: DownloadItem) {
        if let task = downloadTasks[item.id] {
            task.cancel()
            downloadTasks.removeValue(forKey: item.id)
        }
        item.status = .cancelled
        saveDownloads()
    }

    func deleteDownload(_ item: DownloadItem) {
        if let localPath = item.localPath,
            let url = URL(string: localPath)
        {
            try? FileManager.default.removeItem(at: url)
        }

        if let index = downloads.firstIndex(where: { $0.id == item.id }) {
            downloads.remove(at: index)
        }

        saveDownloads()
    }

    // MARK: - Persistence

    private func saveDownloads() {
        do {
            let data = try JSONEncoder().encode(downloads)
            let url = getDownloadsURL()
            try data.write(to: url)
        } catch {
            print("Failed to save downloads: \(error)")
        }
    }

    private func loadDownloads() {
        do {
            let url = getDownloadsURL()
            let data = try Data(contentsOf: url)
            downloads = try JSONDecoder().decode([DownloadItem].self, from: data)
        } catch {
            downloads = []
        }
    }

    private func getDownloadsURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("downloads.json")
    }
    
    // 保存视频到照片图库
    private func saveToPhotoLibrary(at fileURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            NotificationCenter.default.post(name: NSNotification.Name("ShowToast"), 
                                                           object: nil, 
                                                           userInfo: ["message": "视频已自动保存到照片图库"])
                        } else {
                            let errorMessage = error?.localizedDescription ?? "未知错误"
                            print("自动保存视频失败: \(errorMessage)")
                        }
                    }
                }
            }
        }
    }
}
