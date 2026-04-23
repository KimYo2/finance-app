# Personal Finance App

Aplikasi Pencatatan Pengeluaran & Pemasukan Harian (Finance App) menggunakan Flutter dengan dukungan penuh untuk Android dan iOS.

## Fitur

- **Dashboard** - Menampilkan saldo total, pemasukan & pengeluaran bulan ini
- **Tambah Transaksi** - Input transaksi dengan kategori, nominal, tanggal, dan catatan
- **Riwayat** - Lihat semua transaksi dengan filter (Semua/Pemasukan/Pengeluaran)
- **Laporan** - Pie chart pengeluaran per kategori, bar chart 6 bulan terakhir
- **Cross-Platform** - Tampilan native untuk Android (Material) dan iOS (Cupertino)
- **Offline Mode** - Bisa jalan tanpa internet menggunakan SQLite lokal

## Teknologi

- Flutter SDK ^3.11.4
- Provider (state management)
- SQLite + PocketBase (dual storage)
- fl_chart (charts)
- intl (formatting mata uang Indonesia)

## Struktur Proyek

```
lib/
├── main.dart                  # Entry point & routing
├── database/
│   ├── db_interface.dart     # Abstract storage interface
│   ├── pb_helper.dart         # PocketBase implementation
│   └── sqlite_helper.dart     # SQLite implementation
├── models/
│   └── transaction_model.dart
├── providers/
│   └── transaction_provider.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── history_screen.dart
│   └── report_screen.dart
├── widgets/
│   └── transaction_card.dart
└── utils/
    └── platform_helper.dart
```

## Storage Layer

App menggunakan abstract interface `DbInterface` yang bisa switch antara:

1. **SQLite** (default) - Offline, data tersimpan lokal di device
2. **PocketBase** - Online, data sync ke server

```dart
// Switch ke PocketBase (online)
import 'database/pb_helper.dart';
provider.switchStorage(PbHelper());

// Switch ke SQLite (offline)
import 'database/sqlite_helper.dart';
provider.switchStorage(SqliteHelper());
```

## Setup PocketBase

### 1. Download & Run PocketBase

```bash
# Download dari https://pocketbase.io/docs/
chmod +x pocketbase
./pocketbase serve
# Admin UI: http://127.0.0.1:8090/_/
```

### 2. Cara 1 — Auto Migration (Recommended)

```bash
# Copy folder pb_migrations/ ke direktori PocketBase
cp -r pb_migrations/ /path/to/pocketbase/
./pocketbase migrate up
```

### 3. Cara 2 — Import via Admin UI

1. Buka http://127.0.0.1:8090/_/
2. Settings → Import Collections
3. Upload file `pb_schema.json`
4. Klik "Confirm and import"

### 4. Update Flutter App

Edit file `.env` di root project Flutter:

```
PB_URL=http://127.0.0.1:8090
```

Ganti IP jika PocketBase di server/hosting berbeda.

### 5. Verify Setup

Buka: http://127.0.0.1:8090/_/
Pastikan collections `transactions` dan `categories` sudah muncul.

## Instalasi Flutter

```bash
# Clone repo
git clone https://github.com/KimYo2/finance-app.git

# Install dependencies
flutter pub get

# Run
flutter run
```

## Build

```bash
# Android APK
flutter build apk --debug

# Android Release
flutter build apk --release

# iOS (hanya di macOS)
flutter build ios --release
```

## Requirements

- Android: API 21+ (Android 5.0)
- iOS: 13.0+
- SQLite: included (sqflite)
- PocketBase: v0.21+ (optional for online mode)

## Lisensi

MIT