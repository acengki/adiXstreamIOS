# AdiXtream iOS — Buat Ulang dari APK Android

Proyek ini adalah **pembuatan ulang** aplikasi AdiXtream MOD V4.8.5
(berbasis CloudStream, package `com.adixtream.app`) untuk iOS,
dibuat dari analisis file `pedro.apk` saja — tanpa kode sumber Android.
Ini BUKAN hasil convert otomatis APK menjadi IPA.

## Isi
- `AdiXtreamIOS/` — kode SwiftUI (iOS 17+): Home, Search, Detail, Player (AVPlayer),
  Downloads, Library, Extensions, Settings (Face ID)
- `ANALISIS_APK.md` — hasil analisis APK dan pemetaan fitur Android → iOS
- `project.yml` — spesifikasi XcodeGen untuk membuat `.xcodeproj`

Aplikasi langsung bisa dijalankan dengan **data contoh** (`MockData.swift`).
Untuk katalog asli, hubungkan API/provider milikmu sendiri dan isi
`streamURL` pada episode — jangan memakai sumber yang tidak kamu miliki haknya.

## Cara build (wajib Mac)
1. Install Xcode dari App Store (Mac).
2. Install XcodeGen: `brew install xcodegen`
3. Di folder ini jalankan: `xcodegen generate`
4. Buka `AdiXtreamIOS.xcodeproj`, pilih iPhone/simulator, tekan Run.
   - Untuk memasang ke iPhone sendiri: atur Signing dengan Apple ID kamu di Xcode.
   - Tanpa XcodeGen: buat proyek App SwiftUI baru di Xcode bernama AdiXtreamIOS,
     lalu seret semua file di folder `AdiXtreamIOS/` ke proyek tersebut.

Tanpa Mac/Xcode, file `.ipa` tidak bisa dibuat — itu batasan Apple, bukan proyek ini.

## Batasan penting
- Plugin/repository gaya CloudStream Android tidak bisa dipasang di iOS
  (App Store melarang mengunduh & menjalankan kode ekstensi seperti itu).
  Provider di iOS ditulis sebagai kode Swift di dalam aplikasi / API sendiri.
- Izin Android seperti REQUEST_INSTALL_PACKAGES dan MANAGE_EXTERNAL_STORAGE
  tidak memiliki padanan di iOS.
- Distribusi App Store untuk aplikasi streaming berbasis ekstensi berisiko
  ditolak Apple. Jalur realistis untuk pemakaian pribadi: build sendiri via Xcode,
  atau TestFlight dengan akun Apple Developer.

## Langkah berikutnya yang disarankan
1. Tentukan sumber katalog yang sah milikmu (API/server sendiri) untuk mengganti MockData.
2. Tambahkan penyimpanan lokal (SwiftData) untuk Library, bookmark, dan resume.
3. Selesaikan unduhan nyata dengan URLSession background + AVAssetDownloadTask untuk HLS offline.
4. Tambahkan subtitle WebVTT dan AirPlay di PlayerView.

## Tanpa Mac pribadi — build di cloud (baru)
Kamu TIDAK harus punya Mac. Proyek ini sekarang dilengkapi
`.github/workflows/build-ios.yml` (GitHub Actions):

1. Buat akun GitHub (gratis), buat repository baru, upload isi folder ini
   (termasuk folder `.github`).
2. Buka tab **Actions** di repository → workflow "Build iOS" jalan otomatis
   di komputer macOS milik GitHub.
3. Setelah selesai, unduh artifact `AdiXtreamIOS-unsigned-ipa` — isinya file
   `AdiXtreamIOS-unsigned.ipa`.
4. IPA ini belum ditandatangani (unsigned). Untuk memasangnya di iPhone
   tanpa Mac, tandatangani & pasang dengan **SideStore** atau **AltStore**
   (bisa dari PC Windows + Apple ID biasa). Untuk TestFlight/App Store
   tetap perlu akun Apple Developer berbayar dan proses signing resmi.

Alternatif lain: sewa Mac cloud per jam (mis. MacInCloud) bila suatu saat
ingin membuka Xcode langsung, atau pinjam Mac sebentar hanya untuk build.

## Update v2 — Upgrade Player & Unduhan (2026-10-27)
Sudah diterapkan ke kode (belum terverifikasi kompilasi — verifikasi lewat
GitHub Actions setelah upload, lihat bawah):
- Player: pilihan subtitle dari trek bawaan stream (HLS), otomatis memilih
  bahasa sesuai Settings; subtitle WebVTT eksternal untuk file progresif;
  kecepatan 0.5x–2x; tombol AirPlay; lanjut menonton (posisi tersimpan).
- Unduhan: HLS memakai AVAssetDownloadTask, file progresif memakai
  URLSession background ke Documents/Downloads, progres nyata, dan
  putar offline dari daftar Downloads. Judul tanpa URL stream tercatat
  sebagai tidak bisa diunduh (jujur), bukan progres pura-pura.
- Home kini punya item "Demo Stream HLS (Tes Player)" memakai stream tes
  publik Apple (BipBop) agar player, subtitle, dan unduhan bisa dicoba
  sebelum katalog asli dihubungkan.

Cara verifikasi: upload versi ini ke repo (timpa file lama bila sudah
pernah upload), tunggu Actions "Build iOS (tanpa Mac pribadi)" selesai.
Bila build gagal, kirim link repo / log Actions-nya — akan diperbaiki dari sini.
