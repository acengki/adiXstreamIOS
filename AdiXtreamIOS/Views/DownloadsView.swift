import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var downloads: DownloadManager
    var body: some View {
        NavigationStack {
            Group {
                if downloads.tasks.isEmpty {
                    ContentUnavailableView("Tidak ada unduhan", systemImage: "arrow.down.circle",
                                           description: Text("Unduhan dari halaman detail akan muncul di sini. Coba dari item Demo Stream HLS di Home untuk mengetes."))
                } else {
                    List {
                        ForEach(downloads.tasks) { task in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title).bold()
                                Text(task.status).font(.caption).foregroundStyle(.secondary)
                                if !task.isFinished {
                                    ProgressView(value: task.progress)
                                } else if let local = task.localFileURL {
                                    NavigationLink("Putar offline") {
                                        PlayerView(title: task.title, streamURL: local.absoluteString, contentID: task.id)
                                    }
                                }
                            }
                        }
                        .onDelete { idx in idx.map { downloads.tasks[$0] }.forEach(downloads.remove) }
                    }
                }
            }.navigationTitle("Downloads")
        }
    }
}
