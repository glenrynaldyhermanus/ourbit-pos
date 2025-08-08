# Test Script Autentikasi Ourbit POS

## Overview

Dokumen ini berisi test script untuk menguji sistem autentikasi aplikasi Ourbit POS berdasarkan spesifikasi di `docs/specs/auth.md`. Test script ini mencakup token validation, AppBar integration, offline support, dan force logout functionality.

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
     'Allnimall Pet Shop',
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
     'Toko Pusat',
     'Test Address',
     true,
     NOW(),
     NOW()
   );

   -- Insert test role
   INSERT INTO roles (id, name, description, permissions, created_at, updated_at)
   VALUES (
     'test-role-id',
     'Cashier',
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

### TC-001: App Startup - Valid Token

**Objective**: Memverifikasi aplikasi dapat start dengan token valid dan route ke Cashier

**Precondition**:

- User sudah login sebelumnya
- Token valid tersimpan di SharedPreferences
- User data, business data, store data tersimpan

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Amati proses startup
3. Verifikasi routing

**Expected Results**:

- [ ] Token validation berhasil
- [ ] Aplikasi route ke `/pos` (Cashier)
- [ ] OurbitAppBar menampilkan informasi lengkap
- [ ] Token validation timer berjalan (30 detik interval)
- [ ] Tidak ada error message

**Test Data**:

```json
{
	"stored_token": "valid-jwt-token",
	"user_data": {
		"id": "test-user-id",
		"email": "test@ourbit.com",
		"name": "Test User"
	},
	"business_data": {
		"id": "test-business-id",
		"name": "Allnimall Pet Shop"
	},
	"store_data": {
		"id": "test-store-id",
		"name": "Toko Pusat"
	},
	"role_data": {
		"role": {
			"name": "Cashier"
		}
	}
}
```

---

### TC-002: App Startup - Invalid Token

**Objective**: Memverifikasi aplikasi handle invalid token dengan benar

**Precondition**:

- Token expired atau invalid tersimpan di SharedPreferences

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Amati proses startup
3. Verifikasi routing

**Expected Results**:

- [ ] Token validation gagal
- [ ] Token dihapus dari SharedPreferences
- [ ] Aplikasi route ke `/login`
- [ ] Tidak ada data yang tersimpan

---

### TC-003: App Startup - No Token

**Objective**: Memverifikasi aplikasi handle tidak ada token

**Precondition**:

- Tidak ada token tersimpan di SharedPreferences
- Aplikasi dalam clean state

**Test Steps**:

1. Buka aplikasi Ourbit POS
2. Amati proses startup
3. Verifikasi routing

**Expected Results**:

- [ ] Token validation return false
- [ ] Aplikasi route ke `/login`
- [ ] Login page ditampilkan

---

### TC-004: OurbitAppBar - Token Validation Timer

**Objective**: Memverifikasi token validation timer berjalan setiap 5 menit

**Precondition**:

- User sudah login dan berada di halaman dengan OurbitAppBar
- Token valid

**Test Steps**:

1. Login dengan kredensial valid
2. Navigasi ke halaman dengan OurbitAppBar
3. Tunggu 5 menit
4. Amati token validation

**Expected Results**:

- [ ] Timer berjalan setiap 5 menit
- [ ] Token validation dipanggil
- [ ] Session tetap aktif
- [ ] Tidak ada logout otomatis

---

### TC-005: OurbitAppBar - Token Expired During Session

**Objective**: Memverifikasi auto logout ketika token expired saat aplikasi berjalan

**Precondition**:

- User sudah login
- Token akan expired dalam 10 menit

**Test Steps**:

1. Login dengan kredensial valid
2. Tunggu token expired
3. Amati OurbitAppBar behavior

**Expected Results**:

- [ ] Token validation mendeteksi expired token
- [ ] Auto refresh session sebelum expired
- [ ] Force logout dijalankan jika refresh gagal
- [ ] Semua data dihapus dari SharedPreferences
- [ ] Navigasi ke `/login`
- [ ] Timer di-cancel

---

### TC-006: OurbitAppBar - Display Information

**Objective**: Memverifikasi OurbitAppBar menampilkan informasi dengan benar

**Precondition**:

- User sudah login dengan data lengkap

**Test Steps**:

1. Login dengan kredensial valid
2. Amati OurbitAppBar layout
3. Verifikasi informasi yang ditampilkan

**Expected Results**:

- [ ] Business name ditampilkan: "Allnimall Pet Shop"
- [ ] Store name ditampilkan: "Toko Pusat"
- [ ] User name ditampilkan: "Test" (first name)
- [ ] User role ditampilkan: "Cashier"
- [ ] Avatar dengan initials ditampilkan: "TU"
- [ ] Layout responsive dan rapi

---

### TC-007: OurbitAppBar - Fallback Data

**Objective**: Memverifikasi OurbitAppBar menggunakan fallback data ketika data tidak lengkap

**Precondition**:

- User login dengan data tidak lengkap
- Beberapa field kosong atau null

**Test Steps**:

1. Login dengan user yang data tidak lengkap
2. Amati OurbitAppBar display
3. Verifikasi fallback values

**Expected Results**:

- [ ] Business name fallback: "Allnimall Pet Shop"
- [ ] Store name fallback: "Toko"
- [ ] User name fallback: email prefix atau "User"
- [ ] User role fallback: "User"
- [ ] Avatar dengan fallback initial: "U"

---

### TC-008: Force Logout - Complete Data Clearing

**Objective**: Memverifikasi force logout menghapus semua data dengan benar

**Precondition**:

- User sudah login dengan data lengkap
- Token valid

**Test Steps**:

1. Login dengan kredensial valid
2. Trigger force logout (simulasi token expired)
3. Verifikasi data clearing

**Expected Results**:

- [ ] Supabase session di-clear
- [ ] Token dihapus dari SharedPreferences
- [ ] User data dihapus
- [ ] Business data dihapus
- [ ] Store data dihapus
- [ ] Role assignment data dihapus
- [ ] Navigasi ke `/login`

---

### TC-009: Offline Support - Cached Data Display

**Objective**: Memverifikasi aplikasi dapat menampilkan data dari cache saat offline

**Precondition**:

- User sudah login dengan data tersimpan
- Network connection dimatikan

**Test Steps**:

1. Login dengan kredensial valid
2. Matikan network connection
3. Restart aplikasi
4. Amati OurbitAppBar display

**Expected Results**:

- [ ] Aplikasi dapat start tanpa network
- [ ] OurbitAppBar menampilkan cached data
- [ ] Business/Store/User info ditampilkan dari cache
- [ ] Tidak ada error karena network

---

### TC-010: Offline Support - Token Validation

**Objective**: Memverifikasi token validation behavior saat offline

**Precondition**:

- User sudah login
- Network connection dimatikan

**Test Steps**:

1. Login dengan kredensial valid
2. Matikan network connection
3. Tunggu token validation timer (5 menit)
4. Amati behavior

**Expected Results**:

- [ ] Token validation menggunakan cached validation
- [ ] Tidak ada network error
- [ ] Session tetap aktif
- [ ] Tidak ada force logout

---

### TC-011: Network Error Handling

**Objective**: Memverifikasi aplikasi handle network error dengan graceful

**Precondition**:

- User sudah login
- Network connection tidak stabil

**Test Steps**:

1. Login dengan kredensial valid
2. Simulasi network error
3. Tunggu token validation
4. Amati error handling

**Expected Results**:

- [ ] Token validation tidak crash
- [ ] Menggunakan cached validation
- [ ] Tidak ada force logout karena network error
- [ ] Session tetap aktif

---

### TC-012: Multiple Invalid Token Detection

**Objective**: Memverifikasi aplikasi tidak melakukan multiple logout calls

**Precondition**:

- User sudah login
- Token expired

**Test Steps**:

1. Login dengan kredensial valid
2. Simulasi token expired
3. Trigger multiple validation calls
4. Amati logout behavior

**Expected Results**:

- [ ] Hanya satu kali force logout
- [ ] Timer di-cancel setelah logout pertama
- [ ] Tidak ada multiple navigation ke login
- [ ] Tidak ada multiple data clearing

---

### TC-013: AppBar Error State

**Objective**: Memverifikasi OurbitAppBar handle error state dengan benar

**Precondition**:

- Error saat loading data dari SharedPreferences

**Test Steps**:

1. Corrupt SharedPreferences data
2. Restart aplikasi
3. Amati OurbitAppBar error state

**Expected Results**:

- [ ] Error state ditampilkan
- [ ] Refresh button tersedia
- [ ] Error message informatif
- [ ] User dapat refresh data

---

### TC-014: Token Service - URL Token Handling (Web)

**Objective**: Memverifikasi TokenService dapat handle token dari URL (web only)

**Precondition**:

- Aplikasi berjalan di web browser
- Token dan expiry di URL parameters

**Test Steps**:

1. Akses aplikasi dengan URL: `/?token=valid-token&expiry=2024-12-31T23:59:59Z`
2. Amati token processing
3. Verifikasi URL cleaning

**Expected Results**:

- [ ] Token diproses dari URL
- [ ] Token disimpan ke SharedPreferences
- [ ] User data di-load
- [ ] URL parameters di-clear
- [ ] Navigasi ke Cashier

---

### TC-015: Token Service - Token Expiry Handling

**Objective**: Memverifikasi TokenService handle token expiry dengan benar

**Precondition**:

- Token dengan expiry time di masa lalu

**Test Steps**:

1. Set token dengan expiry time yang sudah lewat
2. Restart aplikasi
3. Amati token validation

**Expected Results**:

- [ ] Token expired terdeteksi
- [ ] Token dihapus dari storage
- [ ] Aplikasi route ke login
- [ ] Tidak ada data yang tersimpan

---

### TC-016: Performance - Token Validation Frequency

**Objective**: Memverifikasi token validation tidak terlalu sering

**Precondition**:

- User sudah login
- Aplikasi berjalan normal

**Test Steps**:

1. Login dengan kredensial valid
2. Monitor token validation calls
3. Amati performance impact

**Expected Results**:

- [ ] Token validation setiap 5 menit
- [ ] Tidak ada excessive API calls
- [ ] Performance tidak terpengaruh
- [ ] Battery usage normal

---

### TC-017: Security - Token Storage

**Objective**: Memverifikasi token disimpan dengan aman

**Precondition**:

- User login dengan token valid

**Test Steps**:

1. Login dengan kredensial valid
2. Inspect SharedPreferences storage
3. Verifikasi token storage

**Expected Results**:

- [ ] Token disimpan dengan key yang aman
- [ ] Expiry time disimpan
- [ ] Token tidak exposed di log
- [ ] Storage encrypted (jika available)

---

### TC-018: Security - Force Logout Security

**Objective**: Memverifikasi force logout menghapus semua data sensitif

**Precondition**:

- User sudah login dengan data lengkap

**Test Steps**:

1. Login dengan kredensial valid
2. Trigger force logout
3. Inspect SharedPreferences setelah logout

**Expected Results**:

- [ ] Semua auth data terhapus
- [ ] Token terhapus
- [ ] User data terhapus
- [ ] Business/Store data terhapus
- [ ] Tidak ada data sensitif tersisa

---

### TC-019: UI/UX - AppBar Loading State

**Objective**: Memverifikasi OurbitAppBar loading state ditampilkan dengan benar

**Test Steps**:

1. Restart aplikasi
2. Amati OurbitAppBar loading state
3. Verifikasi loading indicators

**Expected Results**:

- [ ] Loading skeleton ditampilkan
- [ ] Placeholder text ditampilkan
- [ ] Loading state smooth
- [ ] Transisi ke loaded state smooth

---

### TC-020: UI/UX - AppBar Error Recovery

**Objective**: Memverifikasi user dapat recover dari error state

**Test Steps**:

1. Trigger AppBar error state
2. Klik refresh button
3. Amati recovery process

**Expected Results**:

- [ ] Refresh button berfungsi
- [ ] Data di-load ulang
- [ ] Error state hilang
- [ ] Normal state ditampilkan

## Test Data Setup

### Valid Test Users

```sql
-- User dengan data lengkap
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('complete-user', 'complete@ourbit.com', 'Complete User', 'https://example.com/complete.jpg', NOW(), NOW());

-- User dengan data tidak lengkap
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('incomplete-user', 'incomplete@ourbit.com', '', NULL, NOW(), NOW());

-- User dengan email tanpa nama
INSERT INTO auth.users (id, email, full_name, avatar_url, created_at, updated_at)
VALUES ('email-only-user', 'emailonly@ourbit.com', NULL, NULL, NOW(), NOW());
```

### Test Businesses

```sql
-- Business dengan nama lengkap
INSERT INTO businesses (id, name, description, is_active, created_at, updated_at)
VALUES ('complete-business', 'Allnimall Pet Shop', 'Complete business for testing', true, NOW(), NOW());

-- Business dengan nama kosong
INSERT INTO businesses (id, name, description, is_active, created_at, updated_at)
VALUES ('empty-business', '', 'Empty business for testing', true, NOW(), NOW());
```

### Test Stores

```sql
-- Store dengan nama lengkap
INSERT INTO stores (id, business_id, name, address, is_active, created_at, updated_at)
VALUES ('complete-store', 'complete-business', 'Toko Pusat', 'Complete store address', true, NOW(), NOW());

-- Store dengan nama kosong
INSERT INTO stores (id, business_id, name, address, is_active, created_at, updated_at)
VALUES ('empty-store', 'complete-business', '', 'Empty store address', true, NOW(), NOW());
```

### Test Role Assignments

```sql
-- Role assignment untuk user lengkap
INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
VALUES ('complete-role', 'complete-user', 'complete-business', 'complete-store', 'test-role-id', NOW(), NOW());

-- Role assignment untuk user tidak lengkap
INSERT INTO role_assignments (id, user_id, business_id, store_id, role_id, created_at, updated_at)
VALUES ('incomplete-role', 'incomplete-user', 'complete-business', 'complete-store', 'test-role-id', NOW(), NOW());
```

## Test Execution Checklist

### Pre-Test Setup

- [ ] Database test data sudah disiapkan
- [ ] Aplikasi dalam kondisi clean state
- [ ] Network connection stabil
- [ ] Test environment terisolasi
- [ ] SharedPreferences cleared

### Test Execution

- [ ] Jalankan test cases secara berurutan
- [ ] Dokumentasikan hasil setiap test case
- [ ] Screenshot error messages jika ada
- [ ] Catat waktu response untuk performance testing
- [ ] Monitor network calls

### Post-Test Cleanup

- [ ] Hapus test data dari database
- [ ] Clear SharedPreferences
- [ ] Restart aplikasi
- [ ] Verifikasi aplikasi kembali ke state awal

## Performance Testing

### Response Time Requirements

- Token validation: < 100ms
- AppBar data loading: < 500ms
- Force logout: < 1s
- Timer accuracy: ±1 second
- Auto refresh session: < 2s

### Memory Testing

- [ ] No memory leaks dari timer
- [ ] Proper cleanup saat widget dispose
- [ ] Efficient data loading
- [ ] Minimal memory footprint

## Security Testing

### Token Security

- [ ] Token tidak exposed di logs
- [ ] Secure token storage
- [ ] Proper token expiration
- [ ] Secure logout process

### Data Protection

- [ ] Sensitive data encrypted
- [ ] Proper data clearing
- [ ] No data leakage
- [ ] Secure error messages

## Accessibility Testing

### Screen Reader Compatibility

- [ ] AppBar information accessible
- [ ] Error states announced
- [ ] Loading states announced
- [ ] Navigation accessible

### Keyboard Navigation

- [ ] Tab order logical
- [ ] Focus management during errors
- [ ] Keyboard shortcuts work
- [ ] Escape key handling

## Mobile Testing

### Responsive Design

- [ ] AppBar responsive di mobile
- [ ] Information readable di small screen
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
Average Token Validation Time: [TIME]
AppBar Loading Time: [TIME]
Force Logout Time: [TIME]
Timer Accuracy: [ACCURACY]
```

### Security Assessment

- [ ] Token security verified
- [ ] Data protection adequate
- [ ] No security vulnerabilities
- [ ] Proper error handling

### Recommendations

- [ ] Bug fixes required
- [ ] Performance improvements
- [ ] UX improvements
- [ ] Security enhancements
- [ ] Accessibility improvements
