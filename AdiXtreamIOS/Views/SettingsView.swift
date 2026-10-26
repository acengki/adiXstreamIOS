import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @AppStorage("useBiometricLock") private var useBiometricLock = false
    @AppStorage("subtitleLanguage") private var subtitleLanguage = "id"
    var body: some View {
        NavigationStack {
            Form {
                Section("Akun & Keamanan") {
                    Toggle("Kunci dengan Face ID / Touch ID", isOn: $useBiometricLock)
                    Text("Padanan USE_BIOMETRIC di Android.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Player") {
                    TextField("Bahasa subtitle", text: $subtitleLanguage)
                    NavigationLink("Provider / Ekstensi") { ExtensionsView() }
                }
                Section("Tentang") {
                    LabeledContent("Aplikasi", value: "AdiXtream iOS (buat ulang)")
                    LabeledContent("Versi acuan Android", value: "4.8.5 (com.adixtream.app)")
                    LabeledContent("Basis Android", value: "CloudStream")
                }
            }.navigationTitle("Settings")
        }
    }
    /// Contoh autentikasi biometrik — panggil saat aplikasi dibuka bila toggle aktif.
    static func authenticate() async -> Bool {
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else { return false }
        return (try? await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Buka AdiXtream")) ?? false
    }
}
