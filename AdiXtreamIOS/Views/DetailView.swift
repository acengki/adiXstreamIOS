import SwiftUI

struct DetailView: View {
    var item: MediaItem
    @EnvironmentObject var downloads: DownloadManager
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.3)).frame(height: 200)
                    .overlay { Image(systemName: "play.rectangle.fill").font(.system(size: 44)).foregroundStyle(.secondary) }
                Text(item.title).font(.title).bold()
                Text("\(item.type.label) • \(item.year.map(String.init) ?? "-") • ★ \(item.rating.map { String(format: "%.1f", $0) } ?? "-")")
                    .foregroundStyle(.secondary)
                Text(item.overview)
                if item.episodes.isEmpty {
                    NavigationLink { PlayerView(title: item.title, streamURL: item.streamURL, subtitleURL: item.subtitleURL, contentID: item.id) } label: {
                        Label("Putar", systemImage: "play.fill").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    Button { downloads.enqueue(item: item, episode: nil) } label: {
                        Label("Unduh", systemImage: "arrow.down.circle").frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                } else {
                    Text("Episodes").font(.headline)
                    ForEach(item.episodes) { ep in
                        HStack {
                            NavigationLink("Ep \(ep.number) — \(ep.title)") { PlayerView(title: "\(item.title) Ep \(ep.number)", streamURL: ep.streamURL, subtitleURL: ep.subtitleURL, contentID: ep.id) }
                            Spacer()
                            Button { downloads.enqueue(item: item, episode: ep) } label: { Image(systemName: "arrow.down.circle") }
                        }
                    }
                }
            }.padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
