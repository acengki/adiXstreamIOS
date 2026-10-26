import SwiftUI
import AVKit

/// Pemutar video iOS (AVPlayer) — upgrade dari kerangka awal:
/// - Pilihan subtitle dari trek bawaan stream (mis. HLS), otomatis memilih
///   bahasa sesuai Settings (subtitleLanguage) bila tersedia.
/// - Subtitle WebVTT eksternal dicoba ditempel untuk file progresif (bukan HLS).
/// - Kecepatan putar 0.5x-2x, tombol AirPlay, dan lanjut menonton
///   (posisi terakhir disimpan per konten di UserDefaults).
struct PlayerView: View {
    var title: String
    var streamURL: String?
    var subtitleURL: String? = nil
    var contentID: String? = nil
    @AppStorage("subtitleLanguage") private var subtitleLanguage = "id"
    @StateObject private var vm = PlayerViewModel()

    var body: some View {
        VStack(spacing: 12) {
            if vm.hasSource {
                VideoPlayer(player: vm.player)
                    .aspectRatio(16 / 9, contentMode: .fit)
                HStack(spacing: 18) {
                    Button { vm.togglePlayPause() } label: {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                    }
                    Menu {
                        ForEach(vm.speeds, id: \.self) { speed in
                            Button { vm.setSpeed(speed) } label: {
                                if speed == vm.selectedSpeed {
                                    Label(String(format: "%.2gx", speed), systemImage: "checkmark")
                                } else {
                                    Text(String(format: "%.2gx", speed))
                                }
                            }
                        }
                    } label: {
                        Label(String(format: "%.2gx", vm.selectedSpeed), systemImage: "gauge.with.dots.needle.67percent")
                    }
                    if !vm.subtitleOptions.isEmpty {
                        Menu {
                            Button("Matikan subtitle") { vm.selectSubtitle(nil) }
                            ForEach(Array(vm.subtitleOptions.enumerated()), id: \.offset) { _, option in
                                Button(option.displayName) { vm.selectSubtitle(option) }
                            }
                        } label: {
                            Label(vm.selectedSubtitleName ?? "Subtitle", systemImage: "captions.bubble")
                        }
                    }
                    RoutePickerView().frame(width: 44, height: 44)
                }
                .font(.title3)
                .padding(.horizontal)
            } else {
                RoundedRectangle(cornerRadius: 12).fill(Color.black).frame(height: 220)
                    .overlay {
                        Text("Belum ada URL stream — isi streamURL dari provider milikmu, atau coba item Demo Stream HLS di Home.")
                            .multilineTextAlignment(.center).foregroundStyle(.white).padding()
                    }
                    .padding()
            }
            Text(title).font(.headline)
            Spacer()
        }
        .navigationTitle("Player").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.load(urlString: streamURL, subtitleURLString: subtitleURL,
                    contentID: contentID ?? title, preferredSubtitleLanguage: subtitleLanguage)
        }
        .onDisappear { vm.pauseAndSave() }
    }
}

struct RoutePickerView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = true
        return view
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

final class PlayerViewModel: ObservableObject {
    @Published var player = AVPlayer()
    @Published var isPlaying = false
    @Published var hasSource = false
    @Published var selectedSpeed: Float = 1.0
    @Published var subtitleOptions: [AVMediaSelectionOption] = []
    @Published var selectedSubtitleName: String?

    let speeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    private var timeObserver: Any?
    private var subtitleGroup: AVMediaSelectionGroup?
    private var currentContentID = ""

    func load(urlString: String?, subtitleURLString: String?, contentID: String, preferredSubtitleLanguage: String) {
        guard let urlString, let url = URL(string: urlString) else { hasSource = false; return }
        hasSource = true
        currentContentID = contentID
        let asset = AVURLAsset(url: url)
        let item = makePlayerItem(asset: asset, sourceURL: url, subtitleURLString: subtitleURLString)
        player.replaceCurrentItem(with: item)
        setupSubtitles(asset: asset, preferredLanguage: preferredSubtitleLanguage)
        let saved = UserDefaults.standard.double(forKey: "resume." + contentID)
        if saved > 5 {
            player.seek(to: CMTime(seconds: saved, preferredTimescale: 600))
        }
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 5, preferredTimescale: 600), queue: .main
        ) { [weak self] time in self?.savePosition(time: time) }
        player.play()
        player.rate = selectedSpeed
        isPlaying = true
    }

    /// HLS biasanya sudah membawa trek subtitle sendiri (dipilih lewat grup legible).
    /// Komposisi subtitle eksternal hanya dicoba untuk file progresif.
    private func makePlayerItem(asset: AVURLAsset, sourceURL: URL, subtitleURLString: String?) -> AVPlayerItem {
        guard sourceURL.pathExtension.lowercased() != "m3u8",
              let subtitleURLString, let subtitleURL = URL(string: subtitleURLString) else {
            return AVPlayerItem(asset: asset)
        }
        let subtitleAsset = AVURLAsset(url: subtitleURL)
        let composition = AVMutableComposition()
        for mediaType in [AVMediaType.video, AVMediaType.audio] {
            if let track = asset.tracks(withMediaType: mediaType).first,
               let compTrack = composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) {
                try? compTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: track, at: .zero)
            }
        }
        let subtitleTrack = subtitleAsset.tracks(withMediaType: .text).first
            ?? subtitleAsset.tracks(withMediaType: .subtitle).first
        if let subtitleTrack,
           let compTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid) {
            try? compTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: subtitleTrack, at: .zero)
        } else {
            return AVPlayerItem(asset: asset)
        }
        return AVPlayerItem(asset: composition)
    }

    private func setupSubtitles(asset: AVAsset, preferredLanguage: String) {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            subtitleOptions = []; subtitleGroup = nil; return
        }
        subtitleGroup = group
        subtitleOptions = group.options
        if let match = group.options.first(where: { $0.locale?.languageCode == preferredLanguage }) {
            selectSubtitle(match)
        }
    }

    func selectSubtitle(_ option: AVMediaSelectionOption?) {
        guard let group = subtitleGroup else { return }
        player.currentItem?.select(option, in: group)
        selectedSubtitleName = option?.displayName
    }

    func togglePlayPause() {
        if isPlaying { player.pause(); isPlaying = false; savePosition(time: player.currentTime()) }
        else { player.play(); player.rate = selectedSpeed; isPlaying = true }
    }

    func setSpeed(_ speed: Float) {
        selectedSpeed = speed
        if isPlaying { player.rate = speed }
    }

    func pauseAndSave() {
        savePosition(time: player.currentTime())
        player.pause()
        isPlaying = false
    }

    private func savePosition(time: CMTime) {
        guard !currentContentID.isEmpty else { return }
        let seconds = CMTimeGetSeconds(time)
        if seconds.isFinite && seconds > 0 {
            UserDefaults.standard.set(seconds, forKey: "resume." + currentContentID)
        }
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
    }
}
