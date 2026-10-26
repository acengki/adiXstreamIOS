# Analisis APK — pedro.apk

- File: pedro.apk, 78 MB (81.529.638 byte)
- Nama aplikasi: AdiXtream MOD V4.8.5
- Package: com.adixtream.app
- Versi: 4.8.5 (versionCode 92)
- Min Android: SDK 23 (Android 6.0), Target: SDK 36
- Aktivitas utama: com.lagradost.cloudstream3.SplashActivity
- Basis: CloudStream (com.lagradost.cloudstream3 / cloudstream4 resources)
- Teknologi: Kotlin, Jetpack Compose / Compose resources, Room, WorkManager,
  Ktor/OkHttp, Coil, Media3/ExoPlayer, FFmpeg (libavcodec/libavformat),
  QuickJS (mesin JS untuk plugin), libgojni (Go), Conscrypt, Firebase, Cast

## Izin Android (20)
INTERNET, ACCESS_NETWORK_STATE, POST_NOTIFICATIONS, WAKE_LOCK,
FOREGROUND_SERVICE (+DATA_SYNC), READ/WRITE/MANAGE_EXTERNAL_STORAGE,
REQUEST_INSTALL_PACKAGES, UPDATE_PACKAGES_WITHOUT_USER_ACTION,
QUERY_ALL_PACKAGES, USE_BIOMETRIC / USE_FINGERPRINT, MODIFY_AUDIO_SETTINGS,
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, RECEIVE_BOOT_COMPLETED, EPG TV.

## Fitur yang dipetakan ke iOS
| Android (CloudStream) | iOS di proyek ini |
|---|---|
| Home film/series/anime | HomeView dengan rail per tipe |
| Search + saran | SearchView (.searchable) |
| Detail + episode | DetailView + daftar episode |
| Player Media3/FFmpeg, subtitle, speed, cast | PlayerView memakai AVPlayer (HLS bawaan). Cast/AirPlay dan subtitle WebVTT adalah langkah lanjutan |
| Download episode (foreground service) | DownloadsView + DownloadManager (rencana: URLSession background) |
| Library / bookmark / resume | LibraryView (tulang, perlu penyimpanan lokal) |
| Akun & biometrik | SettingsView + LocalAuthentication (Face ID/Touch ID) |
| Plugin/repository (QuickJS/Go) | ExtensionsView — TIDAK bisa ditiru persis di iOS; provider ditulis sebagai kode Swift atau API sendiri |
| Pasang paket / kelola storage total | Tidak ada padanan iOS — dihapus |
