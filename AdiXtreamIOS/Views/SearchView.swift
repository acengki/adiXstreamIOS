import SwiftUI

struct SearchView: View {
    @State private var query = ""
    private var results: [MediaItem] {
        query.isEmpty ? MockData.items : MockData.items.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        NavigationStack {
            List(results) { item in
                NavigationLink(value: item) {
                    VStack(alignment: .leading) {
                        Text(item.title).bold()
                        Text("\(item.type.label) • \(item.year.map(String.init) ?? "-")").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $query, prompt: "Cari film, series, anime…")
            .navigationTitle("Search")
            .navigationDestination(for: MediaItem.self) { DetailView(item: $0) }
        }
    }
}
