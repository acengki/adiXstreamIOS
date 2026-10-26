import SwiftUI

@main
struct AdiXtreamIOSApp: App {
    @StateObject private var downloads = DownloadManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(downloads)
                .preferredColorScheme(.dark)
        }
    }
}
