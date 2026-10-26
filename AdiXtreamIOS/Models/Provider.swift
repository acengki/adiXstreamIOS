import Foundation

/// Model ekstensi/provider — padanan konsep "plugin/repository" di CloudStream Android.
/// Di iOS, ekstensi tidak bisa dipasang seperti APK/plugin Android.
/// Implementasikan provider sebagai kode Swift di dalam aplikasi,
/// atau ambil katalog dari server milik pengguna sendiri lewat API JSON.
struct ProviderInfo: Identifiable, Codable {
    var id: String
    var name: String
    var language: String
    var supportedTypes: [MediaType]
    var repositoryURL: String?
    var isEnabled: Bool = true
}
