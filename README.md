# Catat Saku - Flutter Version

Aplikasi pencatat keuangan untuk melacak pengeluaran dan pemasukan harian Anda, dibuat dengan Flutter.

## Fitur

- 📊 **Dashboard** - Menampilkan saldo saat ini, total pengeluaran, dan riwayat transaksi terbaru
- ➕ **Tambah Transaksi** - Form untuk menambah catatan pengeluaran atau pemasukan dengan kategori, tanggal, dan catatan
- 📈 **Grafik Riwayat** - Visualisasi transaksi dengan grafik interaktif (mingguan/bulanan/tahunan)
- ⚙️ **Pengaturan** - Konfigurasi tema, mata uang, backup, restore, dan reset data
- 💾 **Penyimpanan Lokal** - Data tersimpan secara otomatis menggunakan SharedPreferences

## Teknologi

- **Flutter** 3.x
- **Dart** 3.x
- **Provider** - State management
- **SharedPreferences** - Local storage
- **FL Chart** - Grafik dan visualisasi data
- **Intl** - Format currency dan tanggal

## Instalasi

### Prerequisites

Pastikan Anda sudah menginstall:
- Flutter SDK (3.0.0 atau lebih baru)
- Android Studio atau VS Code
- Android SDK & Emulator atau device fisik

### Langkah-langkah

1. Clone atau download repository ini

2. Masuk ke direktori project:
```bash
cd flutter_catat_saku
```

3. Install dependencies:
```bash
flutter pub get
```

4. Jalankan aplikasi:
```bash
flutter run
```

Untuk build APK:
```bash
flutter build apk --release
```

## Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── models/
│   └── transaction.dart         # Model data transaksi
├── providers/
│   └── transaction_provider.dart # State management dengan Provider
└── pages/
    ├── welcome_page.dart        # Halaman sambutan
    ├── home_page.dart           # Dashboard utama
    ├── add_transaction_page.dart # Form tambah transaksi
    ├── history_page.dart        # Halaman riwayat dengan grafik
    └── settings_page.dart       # Halaman pengaturan
```

## Fitur Detail

### 1. Welcome Page
- Halaman sambutan dengan tombol "AYO MULAI"
- Animasi dan dekorasi yang menarik

### 2. Home Page
- Card saldo dengan gradient
- Menampilkan saldo saat ini dan total pengeluaran
- List transaksi terbaru (5 terakhir)
- Floating action button untuk tambah transaksi
- Akses cepat ke History dan Settings

### 3. Add Transaction Page
- Toggle untuk pilih tipe (Pengeluaran/Pemasukan)
- Input jumlah dengan format currency otomatis
- Input kategori transaksi
- Date picker untuk pilih tanggal
- Textarea untuk catatan opsional
- Validasi form sebelum simpan

### 4. History Page
- Filter periode: Mingguan, Bulanan, Tahunan
- Grafik line chart untuk visualisasi income vs expense
- List semua transaksi sesuai periode yang dipilih
- Tampilan yang clean dan mudah dibaca

### 5. Settings Page
- **Tampilan**: Pilihan theme (Terang/Gelap)
- **Mata Uang**: Pilihan currency (IDR/USD)
- **Backup Data**: Export data transaksi
- **Restore Data**: Import data dari backup
- **Reset Data**: Hapus semua data (dengan konfirmasi)
- **Info Aplikasi**: Versi aplikasi

## Warna Theme

- **Primary**: `#5D5FEF` (Purple)
- **Secondary**: `#8E90FF` (Light Purple)
- **Accent**: `#3AC6D5` (Cyan)
- **Background**: `#FFFFFF` (White)
- **Surface**: `#F7FCF7` (Light Green)
- **Text**: `#1B1B1B` (Dark Gray)

## Data Sample

Aplikasi dilengkapi dengan sample data untuk demonstrasi:
- Gaji: Rp 8.700.000 (Income)
- Online Shopping: Rp 360.000 (Expense)
- Belanja: Rp 349.000 (Expense)
- Makan: Rp 24.000 (Expense)

Data disimpan secara otomatis di local storage menggunakan SharedPreferences.

## Catatan Pengembangan

### State Management
Menggunakan Provider pattern untuk:
- Manage list transaksi
- Calculate balance, income, dan expense
- Handle CRUD operations
- Auto-save ke local storage

### Local Storage
Semua transaksi disimpan dalam format JSON di SharedPreferences, memungkinkan:
- Persistence data
- Offline-first approach
- Backup dan restore capability

### Chart Implementation
Menggunakan FL Chart untuk visualisasi:
- Line chart untuk tracking income vs expense
- Responsive dan interactive
- Support multiple time periods

## License

MIT License - Feel free to use this project for learning purposes.

## Developer

Dibuat dengan ❤️ menggunakan Flutter
