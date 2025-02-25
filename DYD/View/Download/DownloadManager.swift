import Foundation
import SwiftUI

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloads: [DownloadItem] = []
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private var session: URLSession!

    // 单例实例
    static let shared = DownloadManager()

    override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "io.crooi.dyd.download")
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadDownloads()
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
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0]
        return documentsPath.appendingPathComponent("downloads.json")
    }
}
