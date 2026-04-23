# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-23

### Added

- **Dashboard Screen**
  - Menampilkan saldo total, pemasukan & pengeluaran bulan ini
  - Tambah Transaksi Terbaru section dengan "Lihat Semua" button
  - Empty state dengan button "Tambah Sekarang"
  - FAB button solid green

- **Add Transaction Screen**
  - Mode ADD dan EDIT dengan parameter `existingTransaction`
  - Pill-shaped toggle (Pengeluaran/Pemasukan) dengan checkmark
  - Format angka otomatis dengan titik ribuan (contoh: 5000000 → 5.000.000)
  - Kategori dengan icon prefixsesuai kategori
  - Tanggal picker konsisten dengan form field lainnya

- **History Screen**
  - Group transaksi berdasarkan tanggal (Hari ini, Kemarin, dd MMM yyyy)
  - Stats header: "Total: X transaksi bulan ini"
  - Swipe to delete dengan style baru
  - Android: edit icon di bawah nominal (tidak overlap)
  - iOS: CupertinoContextMenu untuk Edit & Hapus

- **Transaction Card**
  - Left accent border (green untuk income, red untuk expense)
  - Icon container dengan shadow lembut
  - Edit icon di bawah nominal (tidak overlap)
  - Padding & border radius lebih premium

- **Report Screen**
  - Bottom padding 80px (fix chart terpotong)
  - Section title dengan accent bar hijau

- **App Theme**
  - Global styling constants di `lib/utils/app_theme.dart`

- **Edit Transaksi**
  - User bisa mengedit transaksi yang sudah tersimpan
  - Navigasi dari Dashboard atau History screen
  - Android: tap item atau icon edit
  - iOS: tap item atau long press (context menu)

### Changed

- **Storage Layer**
  - Default menggunakan SQLite (offline mode)
  - Belum ada backend server, jadi SQLite dulu untuk saat ini

### Fixed

- **UI Overlap**
  - Edit icon di TransactionCard tidak lagi overlap dengan nominal
  - Menggunakan Column sebagai trailing statt Stack

## [0.1.0] - 2026-04-XX

### Added

- Initial release
- Dashboard dengan saldo & ringkasan bulan ini
- Tambah transaksi (pemasukan/pengeluaran)
- Riwayat transaksi dengan filter
- Laporan pie chart & bar chart
- SQLite local storage
- Cross-platform (Android & iOS adaptive UI)