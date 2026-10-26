import Foundation

/// Data contoh agar aplikasi bisa langsung dijalankan & dites TANPA backend.
/// Ganti dengan data dari API/provider milikmu sendiri.
enum MockData {
    static let items: [MediaItem] = [
        MediaItem(id: "demo-hls", title: "Demo Stream HLS (Tes Player)", type: .movie, year: 2024, rating: nil,
                  overview: "Stream tes publik dari Apple (BipBop, ada trek subtitle bawaan HLS) untuk mencoba player, pilihan subtitle, kecepatan, AirPlay, dan unduhan offline — sebelum katalog aslimu dihubungkan.",
                  posterURL: nil, backdropURL: nil, episodes: [],
                  streamURL: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"),
        MediaItem(id: "contoh-1", title: "Contoh Film 1", type: .movie, year: 2024, rating: 8.1,
                  overview: "Ini adalah data contoh. Hubungkan provider/API milikmu untuk menampilkan katalog asli.",
                  posterURL: nil, backdropURL: nil, episodes: []),
        MediaItem(id: "contoh-2", title: "Contoh Series 1", type: .series, year: 2023, rating: 8.7,
                  overview: "Contoh serial dengan beberapa episode contoh.",
                  posterURL: nil, backdropURL: nil,
                  episodes: [
                    Episode(id: "e1", number: 1, title: "Episode 1", durationMinutes: 45, streamURL: nil),
                    Episode(id: "e2", number: 2, title: "Episode 2", durationMinutes: 44, streamURL: nil)
                  ]),
        MediaItem(id: "contoh-3", title: "Contoh Anime 1", type: .anime, year: 2024, rating: 8.4,
                  overview: "Contoh anime. Subtitle dan sumber video diisi dari provider pengguna.",
                  posterURL: nil, backdropURL: nil,
                  episodes: [Episode(id: "a1", number: 1, title: "Episode 1", durationMinutes: 24, streamURL: nil)])
    ]
    static let providers: [ProviderInfo] = [
        ProviderInfo(id: "p1", name: "Provider Contoh", language: "id", supportedTypes: [.movie, .series, .anime], repositoryURL: nil, isEnabled: true)
    ]
}
