## Manajemen Staff (Organization > Staff)

Dokumen ini menjelaskan spesifikasi halaman dan form Manajemen Staff pada aplikasi Ourbit POS (paritas dengan versi web). Implementasi Flutter mengacu pada perilaku web (`/admin/staff/page.tsx` dan `components/forms/StaffForm.tsx`) dengan penyesuaian komponen Ourbit.

### Berkas Terkait

- Halaman: `lib/app/organization/staffs/staffs_content.dart`
- Form: `lib/app/organization/staffs/widgets/staff_form_sheet.dart`

### Ringkasan Fungsional

- **List Staff**: Menampilkan assignment staff pada bisnis+toko aktif.
- **Pencarian**: Filter cepat berdasarkan nama, email, atau role (client-side).
- **Sorting**: Berdasarkan nama/email, role, tanggal bergabung (client-side).
- **Pagination**: Kontrol baris per halaman (10/20/50) dan navigasi halaman (client-side).
- **Tambah/Edit Assignment**: Form slide-over untuk menambah assignment (pilih user via email search, pilih role) atau memperbarui role assignment yang ada.
- **Hapus Assignment**: Konfirmasi via `OurbitDialog`, lalu hapus record assignment pada Supabase.

### Sumber Data & Integrasi

- Sumber data utama: tabel `role_assignments` di Supabase.
- Lookup tambahan:
  - `roles` untuk nama role.
  - `profiles` (best-effort) untuk data user (email, name, phone). Jika `profiles` tidak tersedia, UI tetap berjalan dengan fallback email/user_id.
- Identitas konteks halaman:
  - `business_id` dari `LocalStorageService.getBusinessData()`
  - `store_id` dari `LocalStorageService.getStoreId()`

#### Query utama (list)

- Ambil `role_assignments` by `business_id` dan `store_id`, susun mapping `role_id` → `roles.name` dan `user_id` → `profiles`.

#### Mutasi

- Create assignment: `insert({ user_id, business_id, role_id, store_id })` → tabel `role_assignments`.
- Update assignment (role): `update({ role_id })` by `id` (role_assignment_id).
- Delete assignment: `delete()` by `id` (role_assignment_id).

### Skema Data (kolom yang digunakan)

- role_assignments:
  - **id** (role_assignment_id), **created_at**, **user_id**, **business_id**, **role_id**, **store_id**
- roles:
  - **id**, **name**
- profiles (opsional):
  - **id**, **email**, **name**, **phone**

### Antarmuka Pengguna (UI)

- Menggunakan komponen Ourbit terlebih dahulu:
  - `OurbitTextInput`, `OurbitSelect`, `OurbitButton`, `OurbitDialog`, `OurbitTable`.
- Label dan teks UI **Berbahasa Indonesia**.
- Tidak menggunakan `showSnackBar` (gunakan toast Ourbit `showToast`).

### Halaman List (staffs_content.dart)

- Header: "Staff" + tombol "Tambah" (membuka `StaffFormSheet`).
- Search bar: placeholder "Cari staff berdasarkan nama, email, atau role".
- Tabel kolom:
  - **Staff**: nama (tebal) + email (muted)
  - **Telepon**
  - **Role** (badge)
  - **Bergabung** (tanggal dari `created_at`)
  - **Aksi**: Edit (buka form dengan data untuk ubah role), Hapus (dialog konfirmasi, lalu delete assignment)
- Pagination: baris per halaman (10/20/50), halaman sebelumnya/berikutnya.

### Form (staff_form_sheet.dart)

- Mode: Tambah (create assignment) dan Edit (update role) berdasarkan ada/tidaknya `role_assignment_id`.
- Field:
  - Email Staff (pencarian minimal 3 karakter; disabled saat edit)
  - Role (wajib)
- Aksi: "Batal" (tutup sheet), "Simpan" / "Update Assignment" (submit ke Supabase).
- Notifikasi: toast sukses/gagal.

### Alur Operasi

- **Load**: saat halaman dibuka, ambil `business_id` + `store_id` dari local storage → query `role_assignments` → susun data dengan `roles` (dan `profiles` bila ada) → render list.
- **Tambah**: buka form kosong → cari user via email → pilih user dan role → insert assignment → tutup sheet → toast → reload list.
- **Edit**: buka form berisi data → pilih role baru → update assignment → tutup sheet → toast → reload list.
- **Hapus**: dialog konfirmasi → delete assignment → reload list → toast.

### Catatan Teknis

- Halaman Staff tidak menggunakan BLoC karena mengikuti fungsional versi web (langsung via Supabase client). Dapat dipindahkan ke arsitektur BLoC + Usecase bila diperlukan.
- Filter/sort/pagination pada UI (client-side), mengikuti pola halaman lain.

### Validasi Minimal

- Saat tambah: Email staff (user) dan Role wajib diisi.
- Saat edit: Role wajib diisi, assignment id harus valid.
- `business_id` dan `store_id` wajib ada untuk operasi create.

### Perluasan (Opsional)

- Auto-suggest dengan debounce dan highlighting pada hasil pencarian email.
- Manajemen role (CRUD role) terpisah.
- Integrasi BLoC untuk konsistensi arsitektur dan testability.
