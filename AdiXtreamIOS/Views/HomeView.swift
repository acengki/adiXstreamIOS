import SwiftUI

struct HomeView: View {
    private let items = MockData.items
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AdiXtream").font(.largeTitle).bold()
                    ForEach(MediaType.allCases, id: \.self) { type in
                        let filtered = items.filter { $0.type == type }
                        if !filtered.isEmpty {
                            Text(type.label).font(.title3).bold()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(filtered) { item in
                                        NavigationLink(value: item) { MediaCard(item: item) }
                                            .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }.padding()
            }
            .navigationDestination(for: MediaItem.self) { DetailView(item: $0) }
        }
    }
}

struct MediaCard: View {
    var item: MediaItem
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 170)
                .overlay { Image(systemName: "play.rectangle.fill").font(.largeTitle).foregroundStyle(.secondary) }
            Text(item.title).font(.subheadline).bold().frame(width: 120, alignment: .leading).lineLimit(2)
            if let year = item.year { Text(String(year)).font(.caption).foregroundStyle(.secondary) }
        }
    }
}
