import Foundation
import AVFoundation

struct DownloadEntry: Identifiable {
    var id: String
    var title: String
    var progress: Double = 0
    var status: String = "Siap"
    var localFileURL: URL? = nil
    var isFinished: Bool { localFileURL != nil }
}

/// Unduhan nyata (upgrade dari kerangka awal yang hanya mencatat):
/// - HLS (.m3u8): AVAssetDownloadURLSession + AVAssetDownloadTask (bisa diputar offline lewat AVPlayer).
/// - File progresif (mp4, dll.): URLSession background, file dipindah ke Documents/Downloads.
/// Catatan iOS: unduhan hanya dari URL stream yang sah milik pengguna; data contoh tanpa streamURL
/// akan tercatat sebagai gagal dengan penjelasan, bukan unduhan pura-pura.
final class DownloadManager: NSObject, ObservableObject {
    @Published var tasks: [DownloadEntry] = []
    private var fileTaskIDs: [Int: String] = [:]
    private var assetTaskIDs: [Int: String] = [:]

    private lazy var fileSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.adixtream.app.ios.downloads.file")
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    private lazy var hlsSession: AVAssetDownloadURLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.adixtream.app.ios.downloads.hls")
        return AVAssetDownloadURLSession(configuration: config, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }()

    func enqueue(item: MediaItem, episode: Episode?) {
        let title = episode.map { "\(item.title) - Ep \($0.number)" } ?? item.title
        let urlString = episode?.streamURL ?? item.streamURL
        let id = UUID().uuidString
        guard let urlString, let url = URL(string: urlString) else {
            append(DownloadEntry(id: id, title: title, status: "Tidak ada URL stream — data contoh tidak bisa diunduh"))
            return
        }
        append(DownloadEntry(id: id, title: title, status: "Mengunduh…"))
        if url.pathExtension.lowercased() == "m3u8" {
            let asset = AVURLAsset(url: url)
            if let task = hlsSession.makeAssetDownloadTask(asset: asset, assetTitle: title, assetArtworkData: nil, options: nil) {
                assetTaskIDs[task.taskIdentifier] = id
                task.resume()
            } else {
                update(id: id) { $0.status = "Gagal memulai unduhan HLS" }
            }
        } else {
            let task = fileSession.downloadTask(with: url)
            fileTaskIDs[task.taskIdentifier] = id
            task.resume()
        }
    }

    func remove(_ entry: DownloadEntry) {
        if let url = entry.localFileURL { try? FileManager.default.removeItem(at: url) }
        if Thread.isMainThread { tasks.removeAll { $0.id == entry.id } }
        else { DispatchQueue.main.async { [weak self] in self?.tasks.removeAll { $0.id == entry.id } } }
    }

    private func append(_ entry: DownloadEntry) {
        if Thread.isMainThread { tasks.append(entry) }
        else { DispatchQueue.main.async { [weak self] in self?.tasks.append(entry) } }
    }

    private func update(id: String, _ mutate: @escaping (inout DownloadEntry) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let idx = self.tasks.firstIndex(where: { $0.id == id }) else { return }
            mutate(&self.tasks[idx])
        }
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let id = fileTaskIDs[downloadTask.taskIdentifier], totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        update(id: id) { $0.progress = progress; $0.status = "Mengunduh…" }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let id = fileTaskIDs[downloadTask.taskIdentifier] else { return }
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folder = docs.appendingPathComponent("Downloads", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let suggestedExt = downloadTask.response?.url?.pathExtension ?? ""
            let ext = suggestedExt.isEmpty ? "mp4" : suggestedExt
            let destination = folder.appendingPathComponent(id).appendingPathExtension(ext)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)
            update(id: id) { $0.progress = 1; $0.status = "Selesai — bisa diputar offline"; $0.localFileURL = destination }
        } catch {
            update(id: id) { $0.status = "Gagal menyimpan file: \(error.localizedDescription)" }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        if let id = fileTaskIDs[task.taskIdentifier] ?? assetTaskIDs[task.taskIdentifier] {
            update(id: id) { $0.status = "Gagal: \(error.localizedDescription)" }
        }
    }
}

extension DownloadManager: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let id = assetTaskIDs[assetDownloadTask.taskIdentifier] else { return }
        update(id: id) { $0.progress = 1; $0.status = "Selesai — bisa diputar offline"; $0.localFileURL = location }
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask,
                    didLoad loadedTimeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        guard let id = assetTaskIDs[assetDownloadTask.taskIdentifier] else { return }
        let loadedSeconds = loadedTimeRanges.reduce(0.0) { $0 + CMTimeGetSeconds($1.timeRangeValue.duration) }
        let expectedSeconds = CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        if expectedSeconds > 0 {
            let progress = min(loadedSeconds / expectedSeconds, 1.0)
            update(id: id) { $0.progress = progress; $0.status = "Mengunduh…" }
        }
    }
}
