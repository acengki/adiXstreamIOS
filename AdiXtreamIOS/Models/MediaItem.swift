import Foundation

enum MediaType: String, Codable, CaseIterable {
    case movie, series, anime
    var label: String { rawValue.capitalized }
}

struct Episode: Identifiable, Codable, Hashable {
    var id: String
    var number: Int
    var title: String
    var durationMinutes: Int?
    var streamURL: String? // Isi dari provider/API pengguna sendiri
    var subtitleURL: String? = nil // WebVTT eksternal (untuk file progresif, bukan HLS)
}

struct MediaItem: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var type: MediaType
    var year: Int?
    var rating: Double?
    var overview: String
    var posterURL: String?
    var backdropURL: String?
    var episodes: [Episode] = []
    var streamURL: String? = nil // Untuk film / konten satu video
    var subtitleURL: String? = nil
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool { lhs.id == rhs.id }
}
