## Manajemen Toko (Organization > Stores)

Dokumen ini menjelaskan spesifikasi halaman dan form Manajemen Toko pada aplikasi Ourbit POS (paritas dengan versi web). Implementasi Flutter mengacu pada perilaku web (`/admin/stores/page.tsx` dan `components/forms/StoreForm.tsx`) dengan penyesuaian komponen Ourbit.

### Berkas Terkait

- Halaman: `lib/app/organization/stores/stores_content.dart`
- Form: `lib/app/organization/stores/widgets/store_form_sheet.dart`

### Ringkasan Fungsional

- **List Toko**: Menampilkan data toko/cabang milik bisnis aktif.
- **Pencarian**: Filter cepat berdasarkan nama, alamat, bidang usaha (client-side).
- **Sorting**: Berdasarkan nama, tipe (Pusat/Cabang), dan mata uang (client-side).
- **Pagination**: Kontrol baris per halaman (10/20/50) dan navigasi halaman (client-side).
- **Tambah/Edit Toko**: Form slide-over di sisi kanan (Ourbit Sheet) untuk membuat/memperbarui data.
- **Hapus Toko**: Konfirmasi via `OurbitDialog`, lalu hapus di Supabase.

### Sumber Data & Integrasi

- Sumber data: tabel `stores` di Supabase.
- `business_id` diambil dari `LocalStorageService.getBusinessData()`.
- Query utama (list): `from('stores').select().eq('business_id', businessId)`.
- Mutasi:
  - Create: `insert([payload + business_id])` ke `stores`.
  - Update: `update({...payload, updated_at})` by `id`.
  - Delete: `delete().eq('id', id)`.

### Skema Data Stores (kolom yang digunakan)

- **name**: string, nama toko
- **address**: string, alamat
- **phone_country_code**: string (default +62)
- **phone_number**: string
- **business_field**: string, bidang usaha
- **business_description**: string|null
- **stock_setting**: enum teks "auto" | "manual" | "none"
- **currency**: string (contoh: IDR, USD)
- **default_tax_rate**: number (persentase)
- **motto**: string|null
- **is_branch**: boolean (true = Cabang, false = Pusat)
- **business_id**: string (relasi ke bisnis)
- **updated_at**: timestamp (di-set saat update)

### Antarmuka Pengguna (UI)

- Menggunakan komponen Ourbit terlebih dahulu (sesuai aturan UI):
  - `OurbitTextInput`, `OurbitSelect`, `OurbitButton`, `OurbitDialog`, `OurbitTable`.
- Label dan teks UI **Berbahasa Indonesia**.
- Tidak menggunakan `showSnackBar` (menggunakan toast Ourbit melalui `showToast`).

### Halaman List (stores_content.dart)

- Header: "Toko" + tombol "Tambah" (membuka `StoreFormSheet`).
- Search bar: placeholder "Cari toko berdasarkan nama/alamat/bidang usaha".
- Tabel kolom:
  - **Toko**: nama (tebal) + bidang usaha (muted)
  - **Alamat**
  - **Telepon**: kode negara + nomor
  - **Tipe**: badge Pusat/Cabang
  - **Mata Uang**
  - **Aksi**: Edit (buka form dengan data), Hapus (dialog konfirmasi, lalu delete)
- Pagination: baris per halaman (10/20/50), halaman sebelumnya/berikutnya.

### Form (store_form_sheet.dart)

- Mode: Tambah (create) dan Edit (update) berdasarkan ada/tidaknya `store`.
- Field:
  - Nama Toko (wajib)
  - Alamat (wajib)
  - Kode Negara (+62 default) dan Nomor Telepon
  - Bidang Usaha, Deskripsi Bisnis
  - Pengaturan Stok: "Otomatis", "Manual", "Tidak Ada"
  - Mata Uang: "IDR", "USD"
  - Tipe Toko: "Pusat" (false) atau "Cabang" (true)
  - Pajak Default (%)
  - Motto (opsional)
- Aksi: "Batal" (tutup sheet), "Simpan" / "Update Toko" (submit ke Supabase).
- Notifikasi: toast sukses/gagal.

### Alur Operasi

- **Load**: saat halaman dibuka, ambil `business_id` dari local storage -> query `stores` -> render list.
- **Tambah**: buka form kosong -> submit -> insert -> tutup sheet -> toast -> reload list.
- **Edit**: buka form berisi data -> submit -> update -> tutup sheet -> toast -> reload list.
- **Hapus**: dialog konfirmasi -> delete -> reload list -> toast.

### Catatan Teknis

- Saat ini halaman Stores tidak menggunakan BLoC karena mengikuti fungsional versi web (langsung via Supabase client). Dapat dipindahkan ke arsitektur BLoC + Usecase jika diperlukan di masa depan.
- Filter/sort/pagination dikerjakan di sisi UI (client-side) sesuai pola halaman lain.

### Validasi Minimal

- Nama Toko dan Alamat wajib diisi (disarankan tambahkan validasi lebih lanjut sesuai kebutuhan bisnis).
- `business_id` wajib ada untuk operasi create.

### Perluasan (Opsional)

- Menambah kolom tambahan (misal: lokasi geo, status verifikasi) mengikuti skema tabel.
- Integrasi BLoC untuk konsistensi arsitektur (state: loading/success/error) & testability.
