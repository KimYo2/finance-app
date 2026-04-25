# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-04-25

### Changed

- **AI Chat Migration** - Switch dari Gemini ke Groq API
  - Ganti provider: Google Gemini → Groq API
  - Ganti model: llama-3.1-8b-instruct untuk rate limit lebih tinggi
  - Lebih stabil untuk usage tinggi
  - hapus .env dari git tracking

## [1.1.0] - 2026-04-24

### Added

- **Dark Mode** - Support tema gelap/terang
  - Toggle di AppBar dashboard
  - Simpan preferensi di SharedPreferences
  - Semua screen sudah dark mode aware

- **AI Chat Integration** - Catat transaksi via natural language
  - Gemini 2.5 Flash integration
  - Input teks natural: "makan siang 35rb", "gajian 5 juta"
  - Ekstrak otomatis: nominal, kategori, tipe (income/expense)
  - Konfirmasi sebelum simpan

- **Voice Input** - Catat transaksi via suara
  - Speech-to-text dengan speech_to_text package
  - Auto-detect locale Indonesia dengan fallback
  - Tekan lama tombol mic untuk merekam

- **OCR Scan** - Scan struk/nota via kamera
  - Google ML Kit text recognition
  - Ambil dari kamera atau galeri
  - Tampilkan preview gambar di chat
  - AI ekstrak transaksi dari teks hasil OCR

### Changed

- All screens updated with dark mode support
- TransactionCard now uses Theme.of(context).brightness

## [1.0.0] - 2026-04-23

### Added

- **Edit Transaksi** - User bisa edit transaksi yang sudah tersimpan
  - Navigasi dari Dashboard atau History screen
  - Android: tap item atau icon edit
  - iOS: tap item atau long press (CupertinoContextMenu)

- **UI Polish** - Tampilan lebih premium
  - TransactionCard: left accent border, edit icon di bawah nominal (tidak overlap)
  - HistoryScreen: group by date, swipe delete style, stats header
  - DashboardScreen: FAB solid green, saldo card bulan ini, empty state upgrade
  - AddTransactionScreen: pill toggle dengan checkmark, format angka otomatis
  - ReportScreen: section title dengan accent bar hijau

### Changed

- **Storage** - Default SQLite (offline mode)
  - Belum ada backend server, jadi SQLite dulu

## [0.2.0] - 2026-04-XX

### Added

- **SQLite Local Storage** dengan DbInterface abstraction layer
- **PocketBase Integration** (optional for online mode)

### Fixed

- PocketBase URL per platform
- Date formatting Indonesian localization

## [0.1.0] - 2026-04-XX

### Added

- Initial release
- Dashboard dengan saldo & ringkasan bulan ini
- Tambah transaksi (pemasukan/pengeluaran)
- Riwayat transaksi dengan filter (Semua/Pemasukan/Pengeluaran)
- Laporan: pie chart pengeluaran per kategori, bar chart 6 bulan
- Cross-platform UI (Android Material & iOS Cupertino)
- SQLite local storage