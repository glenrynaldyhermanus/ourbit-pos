## Toko Online (Organization > Online Store)

Dokumen ini menjelaskan spesifikasi halaman Toko Online pada aplikasi Ourbit POS (paritas dengan versi web). Implementasi Flutter mengacu pada perilaku web (`/admin/online-store/page.tsx`) dengan penyesuaian komponen Ourbit.

Catatan: Online store tidak list-based. Satu bisnis hanya memiliki satu konfigurasi `business_online_settings`.

### Berkas Terkait

- Halaman: `lib/app/organization/onlinestores/onlinestores_content.dart`

### Ringkasan Fungsional

- **Pengaturan Online**: Aktif/nonaktif toko online, subdomain, email kontak, deskripsi, tautan sosial, tracking stok.
- **Lokasi Pengiriman**: Toggle pengiriman online untuk setiap Toko dan Gudang.

### Sumber Data & Integrasi

- Identitas bisnis: `business_id` dari `LocalStorageService.getBusinessData()`.
- Tabel utama: `business_online_settings` (single-row per business).
- Tabel lokasi: `stores` dan `warehouses` untuk toggle `is_online_delivery_active`.

#### Query utama

- `business_online_settings`: `select('*').eq('business_id', businessId).maybeSingle()`.
- `stores`: `select('id, name, is_online_delivery_active').eq('business_id', businessId)`.
- `warehouses`: `select('id, name, is_online_delivery_active').eq('business_id', businessId)`.

#### Mutasi

- Simpan pengaturan:
  - Jika aktif: `insert` (ketika belum ada) atau `update` (ketika sudah ada) ke `business_online_settings`.
  - Jika nonaktif: `delete` record `business_online_settings` untuk business tersebut.
- Toggle pengiriman:
  - Store: `update({ is_online_delivery_active })` by `id` di `stores`.
  - Warehouse: `update({ is_online_delivery_active })` by `id` di `warehouses`.

### Antarmuka Pengguna (UI)

- Menggunakan komponen Ourbit terlebih dahulu:
  - `OurbitTextInput`, `OurbitTextArea`, `OurbitButton`, `OurbitSwitch`.
- Label dan teks UI **Berbahasa Indonesia**.
- Tidak menggunakan `showSnackBar` (gunakan toast Ourbit `showToast`).

### Halaman (onlinestores_content.dart)

- Header: "Toko Online" + deskripsi singkat.
- Kartu Pengaturan Online:
  - Switch "Aktifkan" untuk mengaktifkan/mematikan fitur.
  - Field: Subdomain (prefiks ourbit.web.app/@), Email Kontak, Deskripsi, Facebook/Instagram/Twitter URL.
  - Tracking Stok: Real-time, Manual, Tidak Ada.
  - Tombol "Simpan Pengaturan" (insert/update/delete sesuai state aktif/nonaktif).
- Kartu Lokasi Pengiriman:
  - Daftar Toko: nama + status pengiriman (switch toggle).
  - Daftar Gudang: nama + status pengiriman (switch toggle).

### Alur Operasi

- **Load**: ambil `business_id` dari local storage → muat `business_online_settings` → muat `stores` + `warehouses` → render UI.
- **Simpan**: tergantung switch aktif/nonaktif → insert/update/delete `business_online_settings` → toast → reload pengaturan.
- **Toggle Pengiriman**: update `is_online_delivery_active` untuk store/warehouse terkait → toast → update daftar lokal.

### Catatan Teknis

- Halaman tidak menggunakan BLoC karena mengikuti fungsional versi web (langsung via Supabase client). Dapat dipindahkan ke arsitektur BLoC + Usecase bila diperlukan.
- Validasi dasar: subdomain dibersihkan menjadi lowercase (frontend) sebelum simpan; validasi tambahan bisa ditambahkan sesuai kebutuhan backend.

### Validasi Minimal

- Saat aktif: `business_id` wajib ada.
- Subdomain/email/sosial opsional namun direkomendasikan sesuai kebutuhan bisnis.
