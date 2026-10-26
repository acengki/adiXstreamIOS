import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Library kosong", systemImage: "bookmark", description: Text("Judul yang kamu bookmark / lanjutkan tonton akan muncul di sini. Fitur ini meniru Library & riwayat di versi Android."))
                .navigationTitle("Library")
        }
    }
}
