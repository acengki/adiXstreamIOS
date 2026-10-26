import SwiftUI

struct ExtensionsView: View {
    @State private var providers = MockData.providers
    var body: some View {
        List {
            Section {
                ForEach($providers) { $p in
                    Toggle(p.name, isOn: $p.isEnabled)
                    Text("Bahasa: \(p.language) • \(p.supportedTypes.map(\.label).joined(separator: ", "))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            } header: { Text("Provider / Ekstensi") }
            Section {
                Text("Di Android, CloudStream memasang plugin dari repository. Di iOS hal itu tidak diizinkan App Store dan tidak bisa meniru cara APK. Di sini provider ditulis sebagai kode Swift di dalam aplikasi, atau katalog diambil dari API milikmu sendiri.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Extensions")
    }
}
