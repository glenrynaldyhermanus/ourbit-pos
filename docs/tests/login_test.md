# Test Script Login Ourbit POS

## Overview

Dokumen ini berisi test script untuk menguji flow login aplikasi Ourbit POS berdasarkan spesifikasi di `docs/specs/login.md`. Test script ini mencakup semua skenario termasuk happy path dan error cases.

## Test Environment Setup

### Prerequisites

1. **Database Setup**

   ```sql
   -- Pastikan tabel-tabel berikut sudah ada dan terisi data test
   -- auth.users
   -- role_assignments
   -- businesses
   -- stores
   -- roles
   ```

2. **Test Data Preparation**

   ```sql
   -- Insert test user
   INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
   VALUES (
     'test-user-id',
     'test@ourbit.com',
     'Test User',
     'https://example.com/avatar.jpg',
     NOW(),
     NOW()
   );

   -- Insert test business
   INSERT INTO businesses (id, name, description, is_active, created_at, updated_at)
   VALUES (
     'test-business-id',
     'Test Business',
     'Test business description',
     true,
     NOW(),
     NOW()
   );

   -- Insert test store
   INSERT INTO stores (id, business_id, name, address, is_active, created_at, updated_at)
   VALUES (
     'test-store-id',
     'test-business-id',
     'Test Store',
     'Test Address',
     true,
     NOW(),
     NOW()
   );

   -- Insert test role
   INSERT INTO roles (id, name, description, permissions, created_at, updated_at)
   VALUES (
     'test-role-id',
     'POS User',
     'POS application user',
     '{"pos_access": true}',
     NOW(),
     NOW()
   );

   -- Insert test role assignment
   INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
   VALUES (
     'test-role-assignment-id',
     'test-user-id',
     'test-business-id',
     'test-store-id',
     'test-role-id',
     NOW(),
     NOW()
   );
   ```

3. **Test User Credentials**
   - Email: `test@ourbit.com`
   - Password: `testpassword123`

## Test Cases

### TC-001: Happy Path - Login Berhasil

**Objective**: Memverifikasi bahwa user dengan kredensial valid dapat login berhasil

**Precondition**:

- User dengan email `test@ourbit.com` ada di database
- User memiliki role assignment yang valid
- Business dan store aktif

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `test@ourbit.com`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Form validation berhasil (tidak ada error)
- [ ] Loading state ditampilkan
- [ ] User data tersimpan di SharedPreferences
- [ ] Role assignment data tersimpan di SharedPreferences
- [ ] Business data tersimpan di SharedPreferences
- [ ] Store data tersimpan di SharedPreferences
- [ ] Navigasi ke halaman CashierPage (`/pos`)
- [ ] Tidak ada error message yang ditampilkan

**Test Data**:

```json
{
	"email": "test@ourbit.com",
	"password": "testpassword123",
	"expected_user_data": {
		"id": "test-user-id",
		"email": "test@ourbit.com",
		"name": "Test User",
		"avatar": "https://example.com/avatar.jpg"
	}
}
```

---

### TC-002: Form Validation - Email Kosong

**Objective**: Memverifikasi validasi form ketika email kosong

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Biarkan field email kosong
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] OurbitToast error ditampilkan dengan title "Data Tidak Lengkap" dan content "Masukkan username dan password"
- [ ] Form tidak submit
- [ ] Tidak ada request ke server
- [ ] User tetap di halaman login

---

### TC-003: Form Validation - Password Kosong

**Objective**: Memverifikasi validasi form ketika password kosong

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `test@ourbit.com`
3. Biarkan field password kosong
4. Klik tombol "Login"

**Expected Results**:

- [ ] OurbitToast error ditampilkan dengan title "Data Tidak Lengkap" dan content "Masukkan username dan password"
- [ ] Form tidak submit
- [ ] Tidak ada request ke server
- [ ] User tetap di halaman login

---

### TC-004: Form Validation - Email Format Invalid

**Objective**: Memverifikasi validasi format email

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `invalid-email`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] OurbitToast error ditampilkan dengan title "Login Gagal" dan content dari AuthBloc error message
- [ ] Form tidak submit
- [ ] Request ke server untuk validasi
- [ ] User tetap di halaman login

---

### TC-005: Authentication Error - User Tidak Ditemukan

**Objective**: Memverifikasi error handling ketika user tidak ditemukan

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `nonexistent@ourbit.com`
3. Masukkan password: `wrongpassword`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] OurbitToast error ditampilkan dengan title "Login Gagal" dan content "Email atau password salah"
- [ ] Tidak ada data yang tersimpan di SharedPreferences
- [ ] User tetap di halaman login
- [ ] Form fields dikosongkan atau tetap terisi (sesuai UX)

---

### TC-006: Authentication Error - Password Salah

**Objective**: Memverifikasi error handling ketika password salah

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `test@ourbit.com`
3. Masukkan password: `wrongpassword`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] OurbitToast error ditampilkan dengan title "Login Gagal" dan content "Email atau password salah"
- [ ] Tidak ada data yang tersimpan di SharedPreferences
- [ ] User tetap di halaman login

---

### TC-007: Access Error - User Tanpa Role Assignment

**Objective**: Memverifikasi error handling ketika user tidak memiliki role assignment

**Precondition**:

- User ada di database
- User tidak memiliki role assignment

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `user-without-role@ourbit.com`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] Popup dialog ditampilkan dengan pesan "Kamu tidak memiliki akses ke aplikasi POS"
- [ ] User data tersimpan di SharedPreferences
- [ ] Role assignment data tidak tersimpan
- [ ] User tetap di halaman login

---

### TC-008: Business Error - Business Tidak Aktif

**Objective**: Memverifikasi error handling ketika business tidak aktif

**Precondition**:

- User ada di database
- User memiliki role assignment
- Business dengan `is_active = false`

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `user-inactive-business@ourbit.com`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] Popup dialog ditampilkan dengan pesan "Bisnis tidak aktif atau tidak ditemukan"
- [ ] User data tersimpan di SharedPreferences
- [ ] Role assignment data tersimpan di SharedPreferences
- [ ] Business data tidak tersimpan
- [ ] User tetap di halaman login

---

### TC-009: Store Error - Store Tidak Aktif

**Objective**: Memverifikasi error handling ketika store tidak aktif

**Precondition**:

- User ada di database
- User memiliki role assignment
- Business aktif
- Store dengan `is_active = false`

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `user-inactive-store@ourbit.com`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] Popup dialog ditampilkan dengan pesan "Store tidak aktif atau tidak ditemukan"
- [ ] User data tersimpan di SharedPreferences
- [ ] Role assignment data tersimpan di SharedPreferences
- [ ] Business data tersimpan di SharedPreferences
- [ ] Store data tidak tersimpan
- [ ] User tetap di halaman login

---

### TC-010: Network Error - Tidak Ada Koneksi Internet

**Objective**: Memverifikasi error handling ketika tidak ada koneksi internet

**Test Steps**:

1. Matikan koneksi internet
2. Buka aplikasi Ourbit POS
3. Masukkan email: `test@ourbit.com`
4. Masukkan password: `testpassword123`
5. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] OurbitToast error ditampilkan dengan title "Login Gagal" dan content network error message dari AuthBloc
- [ ] Tidak ada data yang tersimpan di SharedPreferences
- [ ] User tetap di halaman login

---

### TC-011: Server Error - Database Down

**Objective**: Memverifikasi error handling ketika server error

**Precondition**:

- Simulasi server error dengan mengubah endpoint atau database down

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan email: `test@ourbit.com`
3. Masukkan password: `testpassword123`
4. Klik tombol "Login"

**Expected Results**:

- [ ] Loading state ditampilkan
- [ ] OurbitToast error ditampilkan dengan title "Login Gagal" dan content server error message dari AuthBloc
- [ ] Tidak ada data yang tersimpan di SharedPreferences
- [ ] User tetap di halaman login

---

### TC-012: UI/UX Test - Loading State

**Objective**: Memverifikasi loading state ditampilkan dengan benar

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Masukkan kredensial valid
3. Klik tombol "Login"
4. Amati loading state

**Expected Results**:

- [ ] Loading indicator ditampilkan
- [ ] Tombol login disabled
- [ ] Form fields disabled
- [ ] Loading state hilang setelah proses selesai

---

### TC-013: UI/UX Test - Error State Recovery

**Objective**: Memverifikasi user dapat mencoba login lagi setelah error

**Test Steps**:

1. Masukkan kredensial salah
2. Klik tombol "Login"
3. Tunggu error message muncul
4. Masukkan kredensial yang benar
5. Klik tombol "Login"

**Expected Results**:

- [ ] Error message hilang
- [ ] Form dapat diisi ulang
- [ ] Login berhasil dengan kredensial yang benar
- [ ] Navigasi ke CashierPage

---

### TC-014: Data Persistence Test

**Objective**: Memverifikasi data tersimpan dengan benar di SharedPreferences

**Test Steps**:

1. Login dengan kredensial valid
2. Setelah berhasil login, cek SharedPreferences
3. Restart aplikasi
4. Verifikasi data masih tersimpan

**Expected Results**:

- [ ] User data tersimpan dengan format yang benar
- [ ] Role assignment data tersimpan
- [ ] Business data tersimpan
- [ ] Store data tersimpan
- [ ] Data tetap ada setelah restart aplikasi

---

### TC-015: Logout Test

**Objective**: Memverifikasi logout berfungsi dengan benar

**Test Steps**:

1. Login dengan kredensial valid
2. Navigasi ke halaman lain
3. Klik tombol logout
4. Verifikasi logout

**Expected Results**:

- [ ] Semua data di SharedPreferences terhapus
- [ ] Navigasi kembali ke halaman login
- [ ] Form login dikosongkan
- [ ] User tidak dapat mengakses halaman lain

## Test Data Setup

### Valid Test Users

```sql
-- User dengan akses penuh
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('valid-user-1', 'valid1@ourbit.com', 'Valid User 1', 'https://example.com/avatar1.jpg', NOW(), NOW());

-- User tanpa role assignment
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('no-role-user', 'norole@ourbit.com', 'No Role User', 'https://example.com/avatar2.jpg', NOW(), NOW());

-- User dengan business tidak aktif
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('inactive-business-user', 'inactive-business@ourbit.com', 'Inactive Business User', 'https://example.com/avatar3.jpg', NOW(), NOW());

-- User dengan store tidak aktif
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('inactive-store-user', 'inactive-store@ourbit.com', 'Inactive Store User', 'https://example.com/avatar4.jpg', NOW(), NOW());
```

### Test Businesses

```sql
-- Business aktif
INSERT INTO businesses (id, name, description, is_active, created_at, updated_at)
VALUES ('active-business', 'Active Business', 'Active business for testing', true, NOW(), NOW());

-- Business tidak aktif
INSERT INTO businesses (id, name, description, is_active, created_at, updated_at)
VALUES ('inactive-business', 'Inactive Business', 'Inactive business for testing', false, NOW(), NOW());
```

### Test Stores

```sql
-- Store aktif
INSERT INTO stores (id, business_id, name, address, is_active, created_at, updated_at)
VALUES ('active-store', 'active-business', 'Active Store', 'Active store address', true, NOW(), NOW());

-- Store tidak aktif
INSERT INTO stores (id, business_id, name, address, is_active, created_at, updated_at)
VALUES ('inactive-store', 'active-business', 'Inactive Store', 'Inactive store address', false, NOW(), NOW());
```

### Test Role Assignments

```sql
-- Role assignment untuk user valid
INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
VALUES ('valid-role-1', 'valid-user-1', 'active-business', 'active-store', 'test-role-id', NOW(), NOW());

-- Role assignment untuk user dengan business tidak aktif
INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
VALUES ('inactive-business-role', 'inactive-business-user', 'inactive-business', 'active-store', 'test-role-id', NOW(), NOW());

-- Role assignment untuk user dengan store tidak aktif
INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
VALUES ('inactive-store-role', 'inactive-store-user', 'active-business', 'inactive-store', 'test-role-id', NOW(), NOW());
```

## Test Execution Checklist

### Pre-Test Setup

- [ ] Database test data sudah disiapkan
- [ ] Aplikasi dalam kondisi clean state
- [ ] Network connection stabil
- [ ] Test environment terisolasi

### Test Execution

- [ ] Jalankan test cases secara berurutan
- [ ] Dokumentasikan hasil setiap test case
- [ ] Screenshot error messages jika ada
- [ ] Catat waktu response untuk performance testing

### Post-Test Cleanup

- [ ] Hapus test data dari database
- [ ] Clear SharedPreferences
- [ ] Restart aplikasi
- [ ] Verifikasi aplikasi kembali ke state awal

## Performance Testing

### Response Time Requirements

- Form validation: < 100ms
- Authentication request: < 2s
- Role assignment query: < 1s
- Business/Store validation: < 1s
- Total login process: < 5s

### Load Testing

- Test dengan 10 concurrent users
- Test dengan 50 concurrent users
- Test dengan 100 concurrent users

## Security Testing

### Input Validation

- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] Email format validation
- [ ] Password strength validation

### Session Management

- [ ] Token expiration handling
- [ ] Secure logout
- [ ] Session timeout
- [ ] Concurrent session handling

## Accessibility Testing

### Screen Reader Compatibility

- [ ] Form labels accessible
- [ ] Error messages announced
- [ ] Loading states announced
- [ ] Navigation accessible

### Keyboard Navigation

- [ ] Tab order logical
- [ ] Enter key submits form
- [ ] Escape key cancels operations
- [ ] Focus management during errors

## Mobile Testing

### Responsive Design

- [ ] Login form responsive
- [ ] Error messages readable on mobile
- [ ] Touch targets appropriate size
- [ ] Virtual keyboard handling

### Platform Specific

- [ ] iOS Safari compatibility
- [ ] Android Chrome compatibility
- [ ] PWA functionality
- [ ] Offline handling

## Test Report Template

### Test Summary

```
Test Date: [DATE]
Tester: [NAME]
Environment: [DEV/STAGING/PROD]
Build Version: [VERSION]

Total Test Cases: [NUMBER]
Passed: [NUMBER]
Failed: [NUMBER]
Skipped: [NUMBER]
Success Rate: [PERCENTAGE]%
```

### Failed Test Cases

```
TC-[NUMBER]: [TEST CASE NAME]
- Expected: [EXPECTED RESULT]
- Actual: [ACTUAL RESULT]
- Screenshot: [LINK]
- Notes: [ADDITIONAL NOTES]
```

### Performance Metrics

```
Average Login Time: [TIME]
Slowest Operation: [OPERATION] - [TIME]
Network Errors: [COUNT]
Server Errors: [COUNT]
```

### Recommendations

- [ ] Bug fixes required
- [ ] Performance improvements
- [ ] UX improvements
- [ ] Security enhancements
