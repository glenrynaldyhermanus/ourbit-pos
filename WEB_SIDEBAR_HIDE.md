# Menyembunyikan Sidebar di Web

## Perubahan yang Dilakukan

### 1. Modifikasi CashierPage (`lib/app/cashier/cashier_page.dart`)

- Menambahkan import `Responsive` utility
- Mengubah kondisi render sidebar dari `const AppSidebar()` menjadi `if (!Responsive.isWeb()) const AppSidebar()`
- Sidebar sekarang hanya akan ditampilkan ketika aplikasi tidak berjalan di web

### 2. Menambahkan Platform Detection di Responsive (`lib/src/core/utils/responsive.dart`)

- Menambahkan import `flutter/foundation.dart`
- Menambahkan method `isWeb()` untuk mendeteksi platform web
- Menambahkan method `isMobilePlatform()` untuk mendeteksi platform mobile

## Cara Kerja

1. **Deteksi Platform**: Menggunakan `kIsWeb` dari Flutter untuk mendeteksi apakah aplikasi berjalan di web
2. **Conditional Rendering**: Sidebar hanya dirender jika aplikasi tidak berjalan di web
3. **Responsive Design**: Layout tetap responsif dan optimal untuk berbagai ukuran layar

## Keuntungan

- **Ruang Lebih Luas**: Di web, konten utama mendapat ruang lebih luas tanpa sidebar
- **UX yang Lebih Baik**: Interface yang lebih bersih untuk pengguna web
- **Konsistensi**: Sidebar tetap ada di platform mobile untuk navigasi yang mudah

## Penggunaan

Untuk menggunakan fitur ini di halaman lain, gunakan:

```dart
import 'package:ourbit_pos/src/core/utils/responsive.dart';

// Dalam widget build
if (!Responsive.isWeb()) const AppSidebar(),
```

## Testing

Untuk test perubahan ini:

1. Jalankan aplikasi di web: `flutter run -d chrome`
2. Jalankan aplikasi di mobile: `flutter run -d <device_id>`
3. Verifikasi bahwa sidebar hanya muncul di mobile, tidak di web
