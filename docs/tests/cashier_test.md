# Test Script Cashier Flow Ourbit Kasir

## Overview

Dokumen ini berisi test script untuk menguji keseluruhan flow cashier aplikasi Ourbit Kasir berdasarkan spesifikasi di `docs/specs/cashier.md`. Test script ini mencakup semua skenario dari cart management hingga payment processing, termasuk happy path, error cases, dan integrasi BLoC architecture.

## Test Environment Setup

### Prerequisites

1. **Database Setup**

   ```sql
   -- Pastikan tabel-tabel berikut sudah ada dan terisi data test
   -- categories
   -- products
   -- store_carts
   -- payment_types
   -- payment_methods
   -- store_payment_methods
   -- sales
   -- sales_items
   -- financial_transactions
   -- inventory_transactions
   ```

2. **Test Data Preparation**

   ```sql
   -- Insert test categories
   INSERT INTO categories (id, name, description, created_at, updated_at)
   VALUES
   ('test-category-1', 'Makanan', 'Kategori makanan dan minuman', NOW(), NOW()),
   ('test-category-2', 'Elektronik', 'Kategori elektronik dan gadget', NOW(), NOW());

   -- Insert test products
   INSERT INTO products (id, store_id, category_id, name, selling_price, stock, is_active, created_at, updated_at)
   VALUES
   ('test-product-1', 'test-store-id', 'test-category-1', 'Test Product 1', 15000, 100, true, NOW(), NOW()),
   ('test-product-2', 'test-store-id', 'test-category-1', 'Test Product 2', 25000, 50, true, NOW(), NOW()),
   ('test-product-3', 'test-store-id', 'test-category-2', 'Test Product 3', 35000, 25, true, NOW(), NOW());

   -- Insert test cart items
   INSERT INTO store_carts (id, store_id, product_id, quantity, created_at)
   VALUES
   ('test-cart-1', 'test-store-id', 'test-product-1', 2, NOW()),
   ('test-cart-2', 'test-store-id', 'test-product-2', 1, NOW());

   -- Insert payment types
   INSERT INTO payment_types (id, name, description, created_at)
   VALUES
   ('cash-type', 'Cash', 'Pembayaran tunai', NOW()),
   ('card-type', 'Card', 'Pembayaran kartu', NOW()),
   ('digital-type', 'Digital', 'Pembayaran digital', NOW());

   -- Insert payment methods
   INSERT INTO payment_methods (id, payment_type_id, name, description, created_at)
   VALUES
   ('cash-method', 'cash-type', 'Tunai', 'Pembayaran menggunakan uang tunai', NOW()),
   ('debit-method', 'card-type', 'Kartu Debit', 'Pembayaran menggunakan kartu debit', NOW()),
   ('qris-method', 'digital-type', 'QRIS', 'Pembayaran menggunakan QRIS', NOW());

   -- Insert store payment methods (active methods for store)
   INSERT INTO store_payment_methods (id, store_id, payment_method_id, is_active, created_at)
   VALUES
   ('store-cash', 'test-store-id', 'cash-method', true, NOW()),
   ('store-debit', 'test-store-id', 'debit-method', true, NOW()),
   ('store-qris', 'test-store-id', 'qris-method', true, NOW());
   ```

3. **Test Prerequisites**
   - User sudah login dan berada di CashierPage
   - Categories dan products tersedia di store
   - Store memiliki payment methods yang aktif

## Test Cases

### Section A: Cashier Page Loading & Cart Management

### TC-A01: Cashier Page Loading Test

**Objective**: Memverifikasi cashier page loading dengan CashierBloc

**Test Steps**:

1. Login dengan user yang valid
2. Navigasi ke CashierPage (/pos)
3. Amati loading process
4. Verifikasi data yang dimuat

**Expected Results**:

- [ ] CashierInitial state awal
- [ ] CashierLoading state ditampilkan dengan skeleton
- [ ] LoadProducts event dispatch
- [ ] GetCategoriesByStoreUseCase execute
- [ ] GetProductsUseCase execute
- [ ] GetProductTypesUseCase execute
- [ ] GetCartUseCase execute
- [ ] CashierLoaded state dengan data:
  - [ ] categories: List dengan 2 categories
  - [ ] products: List dengan 3 products
  - [ ] productTypes: List dengan product types
  - [ ] cartItems: List kosong (initial)
- [ ] ProductSkeleton diganti dengan ProductCard
- [ ] CartSkeleton diganti dengan PosCart

---

### TC-A02: Add to Cart Test

**Objective**: Memverifikasi AddToCart functionality dengan CashierBloc

**Test Steps**:

1. Di CashierPage dengan products loaded
2. Klik ProductCard "Test Product 1"
3. Verifikasi cart update
4. Klik ProductCard "Test Product 2"
5. Verifikasi cart dengan multiple items

**Expected Results**:

- [ ] AddToCart event dispatch dengan product data
- [ ] AddToCartUseCase execute
- [ ] Cart UI update dengan animasi
- [ ] Item pertama muncul di cart: "Test Product 1" qty 1
- [ ] Item kedua ditambahkan: "Test Product 2" qty 1
- [ ] Total calculation otomatis dengan tax (11%)
- [ ] Cart counter update
- [ ] Smooth animation pada cart items
- [ ] Micro animation pada ProductCard (scale & opacity)

---

### TC-A03: Update Cart Quantity Test

**Objective**: Memverifikasi update quantity di cart

**Test Steps**:

1. Tambah item ke cart
2. Klik tombol "+" pada cart item
3. Verifikasi quantity increase
4. Klik tombol "-" pada cart item
5. Verifikasi quantity decrease

**Expected Results**:

- [ ] UpdateCartQuantity event dispatch
- [ ] UpdateCartQuantityUseCase execute
- [ ] Quantity berubah dengan animasi
- [ ] Total recalculation
- [ ] Database update (store_carts table)
- [ ] UI responsive dan smooth

---

### TC-A04: Clear Cart Test

**Objective**: Memverifikasi clear cart functionality

**Test Steps**:

1. Tambah beberapa items ke cart
2. Klik tombol "Hapus Semua"
3. Verifikasi cart dikosongkan

**Expected Results**:

- [ ] ClearCart event dispatch
- [ ] ClearCartUseCase execute
- [ ] Confirmation dialog (jika ada)
- [ ] Cart items hilang dengan animasi
- [ ] Total reset ke 0
- [ ] Database cart cleared
- [ ] Cart counter reset

---

### TC-A05: Search and Filter Test

**Objective**: Memverifikasi search dan filter products

**Test Steps**:

1. Di CashierPage, gunakan search box
2. Ketik "Test Product 1"
3. Verifikasi filter results
4. Clear search
5. Test category filter
6. Test type filter

**Expected Results**:

- [ ] Search functionality bekerja dengan OurbitTextInput
- [ ] Products filtered real-time
- [ ] Category filter berfungsi dengan OurbitSelect
- [ ] Type filter berfungsi dengan OurbitSelect
- [ ] Clear search restore semua products
- [ ] No products found state dengan icon dan message yang sesuai

---

### Section B: Payment Flow Tests

### TC-B01: Happy Path - Payment Flow Berhasil

**Objective**: Memverifikasi bahwa payment flow dengan PaymentBloc berhasil dari awal hingga akhir

**Precondition**:

- User sudah login
- Cart berisi item (2x Test Product 1 @ Rp 15.000, 1x Test Product 2 @ Rp 25.000)
- Store memiliki payment methods aktif

**Test Steps**:

1. Di CashierPage, klik tombol "Bayar"
2. Verifikasi navigasi ke PaymentPage
3. Tunggu data loading selesai
4. Verifikasi panel kiri menampilkan order summary
5. Verifikasi panel kanan menampilkan payment methods
6. Pilih payment method "Tunai"
7. Klik tombol "Bayar Rp 61.500"
8. Di dialog sales draft, masukkan catatan: "Test pembayaran tunai"
9. Klik "Lanjutkan"
10. Tunggu proses payment selesai

**Expected Results**:

- [ ] LoadPaymentData event berhasil dispatch
- [ ] PaymentLoaded state ditampilkan dengan data yang benar
- [ ] Panel kiri menampilkan:
  - [ ] 2x Test Product 1 @ Rp 15.000 = Rp 30.000
  - [ ] 1x Test Product 2 @ Rp 25.000 = Rp 25.000
  - [ ] Subtotal: Rp 55.000
  - [ ] Pajak (11%): Rp 6.050
  - [ ] Total: Rp 61.050
- [ ] Panel kanan menampilkan 3 payment methods
- [ ] SelectPaymentMethod event berhasil
- [ ] PaymentProcessing state ditampilkan
- [ ] ProcessPayment event berhasil
- [ ] PaymentSuccess state dan navigasi ke SuccessPage
- [ ] Database records dibuat:
  - [ ] 1 record di sales table dengan notes
  - [ ] 2 records di sales_items table
  - [ ] 1 record di financial_transactions table
  - [ ] 2 records di inventory_transactions table
  - [ ] Stock products berkurang
  - [ ] store_carts dikosongkan

**Test Data**:

```json
{
	"expected_totals": {
		"subtotal": 55000,
		"tax": 6050,
		"total": 61050
	},
	"sales_note": "Test pembayaran tunai",
	"payment_method": "cash-method"
}
```

---

### TC-A06: Cashier Error Handling - Empty Products

**Objective**: Memverifikasi error handling ketika tidak ada products

**Precondition**:

- Store tidak memiliki products aktif

**Test Steps**:

1. Navigasi ke CashierPage
2. Tunggu loading selesai
3. Verifikasi empty state

**Expected Results**:

- [ ] CashierLoaded state dengan products kosong
- [ ] Empty state UI ditampilkan dengan icon inventory_2_outlined
- [ ] Message "No products found"
- [ ] Subtitle "Try adjusting your search or filter"
- [ ] Cart tetap bisa diakses (kosong)
- [ ] No crash atau error

---

### TC-A07: Cashier Error Handling - Network Error

**Objective**: Memverifikasi error handling ketika network error

**Test Steps**:

1. Matikan koneksi internet
2. Navigasi ke CashierPage
3. Amati error handling

**Expected Results**:

- [ ] CashierLoading state ditampilkan
- [ ] CashierError state dengan network error
- [ ] OurbitToast error ditampilkan dengan title "Error" dan content error message
- [ ] Error page dengan retry button tersedia
- [ ] No crash aplikasi

---

### Section C: Payment Integration Tests

### TC-C01: Payment Methods Loading Test

**Objective**: Memverifikasi LoadPaymentData event dan PaymentLoaded state

**Test Steps**:

1. Navigasi ke PaymentPage
2. Amati loading state
3. Verifikasi data yang dimuat

**Expected Results**:

- [ ] PaymentInitial state awal
- [ ] PaymentLoading state ditampilkan
- [ ] PaymentBloc dispatch LoadPaymentData event
- [ ] GetCartUseCase dipanggil
- [ ] GetStorePaymentMethodsUseCase dipanggil
- [ ] PaymentLoaded state dengan data:
  - [ ] cartItems: List dengan 2 items
  - [ ] storePaymentMethods: List dengan 3 methods
  - [ ] selectedPaymentMethod: null
  - [ ] note: empty string
- [ ] Animation fade-in berhasil

---

### TC-C02: Payment Method Selection Test

**Objective**: Memverifikasi SelectPaymentMethod event dan state update

**Test Steps**:

1. Di PaymentPage, tunggu data loading selesai
2. Klik payment method "Kartu Debit"
3. Verifikasi visual feedback
4. Klik payment method "QRIS"
5. Verifikasi perubahan selection

**Expected Results**:

- [ ] SelectPaymentMethod event dispatch dengan method data
- [ ] PaymentLoaded state updated dengan selectedPaymentMethod
- [ ] Visual feedback pada method yang dipilih:
  - [ ] Border orange
  - [ ] Background orange[50]
  - [ ] Check icon ditampilkan
- [ ] Method sebelumnya tidak lagi selected
- [ ] State management reaktif tanpa lag

---

### TC-C03: Sales Draft Dialog Test

**Objective**: Memverifikasi dialog input catatan penjualan

**Test Steps**:

1. Pilih payment method
2. Klik tombol "Bayar"
3. Verifikasi dialog muncul
4. Masukkan catatan: "Test catatan penjualan dengan text panjang untuk memastikan expandable height berfungsi dengan baik"
5. Klik "Lanjutkan"
6. Verifikasi catatan tersimpan

**Expected Results**:

- [ ] Dialog muncul dengan judul "Catatan Penjualan (Draft)"
- [ ] OurbitTextArea dengan placeholder yang benar
- [ ] expandableHeight: true
- [ ] initialHeight: 120
- [ ] Tombol "Batal" dan "Lanjutkan"
- [ ] Text area expand sesuai konten
- [ ] Catatan tersimpan ke salesDraftNote variable
- [ ] Dialog close setelah submit

---

### TC-C04: Error Handling - No Payment Method Selected

**Objective**: Memverifikasi error handling ketika tidak ada payment method dipilih

**Test Steps**:

1. Di PaymentPage, jangan pilih payment method
2. Klik tombol "Bayar"
3. Verifikasi error handling

**Expected Results**:

- [ ] SnackBar error muncul dengan pesan "Pilih metode pembayaran terlebih dahulu"
- [ ] Dialog sales draft tidak muncul
- [ ] ProcessPayment event tidak dispatch
- [ ] User tetap di PaymentPage
- [ ] State tidak berubah

---

### TC-C05: Error Handling - Empty Cart

**Objective**: Memverifikasi error handling ketika cart kosong

**Precondition**:

- Cart kosong (tidak ada items)

**Test Steps**:

1. Navigasi ke PaymentPage
2. Amati behavior

**Expected Results**:

- [ ] PaymentLoaded state dengan cartItems kosong
- [ ] Panel kiri menampilkan empty state atau subtotal 0
- [ ] Tombol "Bayar" disabled atau tidak dapat diklik
- [ ] Pesan error yang user-friendly

---

### TC-C06: Error Handling - No Payment Methods Available

**Objective**: Memverifikasi error handling ketika tidak ada payment methods

**Precondition**:

- Store tidak memiliki payment methods aktif

**Test Steps**:

1. Navigasi ke PaymentPage
2. Tunggu loading selesai
3. Verifikasi panel kanan

**Expected Results**:

- [ ] Panel kanan menampilkan empty state
- [ ] Icon payment_outlined dengan size 48
- [ ] Pesan "Tidak ada metode pembayaran tersedia"
- [ ] Tombol "Bayar" disabled
- [ ] User tidak dapat melanjutkan payment

---

### TC-C07: Error Handling - Payment Processing Failure

**Objective**: Memverifikasi error handling ketika payment processing gagal

**Precondition**:

- Simulasi database error (disconnect database)

**Test Steps**:

1. Pilih payment method
2. Klik tombol "Bayar"
3. Input sales draft
4. Klik "Lanjutkan"
5. Amati error handling

**Expected Results**:

- [ ] PaymentProcessing state ditampilkan
- [ ] PaymentError state dengan error message
- [ ] SnackBar error muncul dengan pesan database error
- [ ] State revert ke PaymentLoaded
- [ ] User dapat mencoba lagi
- [ ] Tidak ada data corrupt di database

---

### TC-C08: Network Error Handling

**Objective**: Memverifikasi error handling ketika tidak ada koneksi internet

**Test Steps**:

1. Matikan koneksi internet
2. Navigasi ke PaymentPage
3. Amati error handling

**Expected Results**:

- [ ] PaymentLoading state ditampilkan
- [ ] PaymentError state dengan network error
- [ ] Error page dengan pesan "Error: [network error message]"
- [ ] Tombol "Coba Lagi" tersedia
- [ ] Retry functionality bekerja setelah koneksi restored

---

### TC-C09: UI/UX Test - Loading States

**Objective**: Memverifikasi semua loading states ditampilkan dengan benar

**Test Steps**:

1. Navigasi ke PaymentPage
2. Amati loading state awal
3. Pilih payment method dan klik bayar
4. Amati processing state

**Expected Results**:

- [ ] Initial loading: CircularProgressIndicator di center
- [ ] Processing state: Tombol berubah jadi "Memproses..."
- [ ] Tombol disabled selama processing
- [ ] Animation fade-in setelah data loaded
- [ ] Smooth transition antar states

---

### TC-C10: UI/UX Test - Responsive Layout

**Objective**: Memverifikasi two-panel layout responsive

**Test Steps**:

1. Test di berbagai ukuran layar
2. Verifikasi panel layout
3. Test scroll behavior

**Expected Results**:

- [ ] Panel kiri (flex: 3) dan kanan (flex: 2) proporsional
- [ ] Content tidak overflow
- [ ] Scroll berfungsi jika konten panjang
- [ ] Spacing 20px antara panels
- [ ] Mobile responsiveness (jika diperlukan)

---

### TC-C11: Data Calculation Test

**Objective**: Memverifikasi kalkulasi subtotal, tax, dan total

**Test Data**:

```json
{
	"cart_items": [
		{ "name": "Product A", "price": 10000, "quantity": 3 },
		{ "name": "Product B", "price": 15000, "quantity": 2 },
		{ "name": "Product C", "price": 5000, "quantity": 1 }
	],
	"expected": {
		"subtotal": 65000,
		"tax": 7150,
		"total": 72150
	}
}
```

**Test Steps**:

1. Setup cart dengan data di atas
2. Navigasi ke PaymentPage
3. Verifikasi kalkulasi

**Expected Results**:

- [ ] Subtotal: Rp 65.000 (30.000 + 30.000 + 5.000)
- [ ] Pajak (11%): Rp 7.150
- [ ] Total: Rp 72.150
- [ ] Format currency: "Rp 72.150" (dengan titik)
- [ ] Kalkulasi real-time dan akurat

---

### TC-C12: Database Transaction Test

**Objective**: Memverifikasi atomicity database transactions

**Test Steps**:

1. Catat initial stock products
2. Catat initial sales count
3. Lakukan payment
4. Verifikasi semua database changes

**Expected Results**:

- [ ] 1 record baru di sales table dengan data yang benar
- [ ] N records baru di sales_items sesuai cart items
- [ ] 1 record baru di financial_transactions
- [ ] N records baru di inventory_transactions
- [ ] Stock products berkurang sesuai quantity
- [ ] store_carts dikosongkan untuk store_id
- [ ] Semua operations atomic (all or nothing)

---

### TC-C13: Performance Test - Payment Processing Time

**Objective**: Memverifikasi performance payment processing

**Test Steps**:

1. Catat waktu mulai klik "Bayar"
2. Catat waktu selesai processing
3. Verifikasi response time

**Expected Results**:

- [ ] LoadPaymentData: < 2s
- [ ] Payment processing: < 3s
- [ ] Total flow: < 5s
- [ ] UI responsive selama processing
- [ ] No memory leaks

---

### TC-C14: State Management Test - BLoC Events

**Objective**: Memverifikasi BLoC events dan state transitions

**Test Steps**:

1. Monitor PaymentBloc events
2. Verifikasi state transitions
3. Test concurrent events

**Expected Results**:

- [ ] LoadPaymentData → PaymentLoading → PaymentLoaded
- [ ] SelectPaymentMethod → PaymentLoaded (updated)
- [ ] ProcessPayment → PaymentProcessing → PaymentSuccess
- [ ] Error scenarios → PaymentError → (revert to previous)
- [ ] No race conditions
- [ ] State consistency maintained

---

### TC-C15: Memory Management Test

**Objective**: Memverifikasi memory management dan cleanup

**Test Steps**:

1. Navigasi multiple kali ke PaymentPage
2. Monitor memory usage
3. Test animation controller cleanup

**Expected Results**:

- [ ] Animation controllers disposed properly
- [ ] No memory leaks
- [ ] BLoC state cleaned up on navigation
- [ ] Image cache managed
- [ ] Event streams closed

---

### Section D: Integration & Performance Tests

### TC-D01: Integration Test - Full Cashier to Payment Flow

**Objective**: Memverifikasi integrasi penuh dari cashier ke payment

**Test Steps**:

1. Mulai dari CashierPage kosong
2. Tambah items ke cart
3. Klik "Bayar"
4. Complete payment flow
5. Verifikasi SuccessPage
6. Return ke CashierPage

**Expected Results**:

- [ ] Cart state synchronized antara CashierPage dan PaymentPage
- [ ] Navigation flow smooth
- [ ] Data consistency maintained
- [ ] Cart cleared setelah payment success
- [ ] CashierPage updated dengan cart kosong

---

### TC-D02: Accessibility Test

**Objective**: Memverifikasi accessibility features

**Test Steps**:

1. Test dengan screen reader
2. Test keyboard navigation
3. Test focus management

**Expected Results**:

- [ ] Payment methods accessible via keyboard
- [ ] Dialog accessible
- [ ] Error messages announced
- [ ] Focus management proper
- [ ] Semantic HTML structure

---

### TC-D03: Security Test - Data Validation

**Objective**: Memverifikasi validasi data dan security

**Test Steps**:

1. Test dengan data cart yang dimanipulasi
2. Test dengan payment method ID invalid
3. Test dengan negative quantities

**Expected Results**:

- [ ] Input validation proper
- [ ] SQL injection prevention
- [ ] Data sanitization
- [ ] Authorization checks
- [ ] Error handling for malicious data

---

### TC-D04: Concurrent User Test

**Objective**: Memverifikasi handling multiple users cashier operations simultaneously

**Test Steps**:

1. Simulasi multiple users payment bersamaan
2. Verifikasi database consistency
3. Test inventory management

**Expected Results**:

- [ ] No race conditions
- [ ] Stock updates atomic
- [ ] Database locks handled
- [ ] Transaction isolation maintained
- [ ] No data corruption

## Test Data Setup

### Complete Test Data SQL

```sql
-- Cleanup existing test data
DELETE FROM inventory_transactions WHERE reference LIKE 'TEST-%';
DELETE FROM sales_items WHERE sale_id IN (SELECT id FROM sales WHERE sale_number LIKE 'TEST-%');
DELETE FROM financial_transactions WHERE description LIKE 'TEST Payment%';
DELETE FROM sales WHERE sale_number LIKE 'TEST-%';
DELETE FROM store_carts WHERE store_id = 'test-store-id';
DELETE FROM store_payment_methods WHERE store_id = 'test-store-id';
DELETE FROM payment_methods WHERE id LIKE 'test-%';
DELETE FROM payment_types WHERE id LIKE 'test-%';
DELETE FROM products WHERE id LIKE 'test-product-%';

-- Insert test products
INSERT INTO products (id, store_id, name, selling_price, purchase_price, stock, min_stock, weight_grams, discount_type, discount_value, is_active, category_id, type, auto_sku, created_at, updated_at)
VALUES
('test-product-1', 'test-store-id', 'Test Product 1', 15000, 10000, 100, 5, 500, 1, 0, true, 'test-category', 'product', true, NOW(), NOW()),
('test-product-2', 'test-store-id', 'Test Product 2', 25000, 20000, 50, 5, 750, 1, 0, true, 'test-category', 'product', true, NOW(), NOW()),
('test-product-3', 'test-store-id', 'Test Product 3', 5000, 3000, 200, 10, 250, 1, 0, true, 'test-category', 'product', true, NOW(), NOW());

-- Insert payment types
INSERT INTO payment_types (id, name, description, created_at, updated_at)
VALUES
('test-cash-type', 'Cash', 'Pembayaran tunai', NOW(), NOW()),
('test-card-type', 'Card', 'Pembayaran kartu', NOW(), NOW()),
('test-digital-type', 'Digital', 'Pembayaran digital', NOW(), NOW());

-- Insert payment methods
INSERT INTO payment_methods (id, payment_type_id, name, description, created_at, updated_at)
VALUES
('test-cash-method', 'test-cash-type', 'Tunai', 'Pembayaran menggunakan uang tunai', NOW(), NOW()),
('test-debit-method', 'test-card-type', 'Kartu Debit', 'Pembayaran menggunakan kartu debit', NOW(), NOW()),
('test-credit-method', 'test-card-type', 'Kartu Kredit', 'Pembayaran menggunakan kartu kredit', NOW(), NOW()),
('test-qris-method', 'test-digital-type', 'QRIS', 'Pembayaran menggunakan QRIS', NOW(), NOW()),
('test-ovo-method', 'test-digital-type', 'OVO', 'Pembayaran menggunakan OVO', NOW(), NOW());

-- Insert store payment methods (active methods for store)
INSERT INTO store_payment_methods (id, store_id, payment_method_id, is_active, created_at, updated_at)
VALUES
('test-store-cash', 'test-store-id', 'test-cash-method', true, NOW(), NOW()),
('test-store-debit', 'test-store-id', 'test-debit-method', true, NOW(), NOW()),
('test-store-qris', 'test-store-id', 'test-qris-method', true, NOW(), NOW()),
('test-store-ovo', 'test-store-id', 'test-ovo-method', false, NOW(), NOW()); -- inactive method
```

### Test Cart Setup

```sql
-- Insert test cart items (setup before each payment test)
INSERT INTO store_carts (id, store_id, product_id, quantity, created_at)
VALUES
('test-cart-1', 'test-store-id', 'test-product-1', 2, NOW()),
('test-cart-2', 'test-store-id', 'test-product-2', 1, NOW());
```

## Test Execution Checklist

### Pre-Test Setup

- [ ] Database test data sudah disiapkan
- [ ] User sudah login dengan role yang tepat
- [ ] Store ID tersedia di local storage
- [ ] Test environment terisolasi
- [ ] Network connection stabil

### Test Execution Order

1. [ ] TC-002: Payment Methods Loading Test
2. [ ] TC-001: Happy Path - Payment Flow Berhasil
3. [ ] TC-003: Payment Method Selection Test
4. [ ] TC-004: Sales Draft Dialog Test
5. [ ] TC-005-011: Error Handling Tests
6. [ ] TC-012: Data Calculation Test
7. [ ] TC-013: Database Transaction Test
8. [ ] TC-014-020: Performance & Integration Tests

### Post-Test Cleanup

- [ ] Hapus test data dari semua tables
- [ ] Clear cart di store_carts
- [ ] Reset product stock ke nilai awal
- [ ] Clear local storage
- [ ] Restart aplikasi untuk fresh state

## Performance Requirements

### Response Time Targets

- LoadPaymentData: < 2 seconds
- SelectPaymentMethod: < 100ms
- ProcessPayment: < 3 seconds
- Total payment flow: < 5 seconds
- UI animations: 60 FPS

### Resource Usage

- Memory usage: < 50MB increase during payment
- CPU usage: < 30% average
- Network requests: Minimal (only necessary calls)
- Database connections: Proper pooling and cleanup

## Test Report Template

### Test Summary

```
Test Date: [DATE]
Tester: [NAME]
Environment: [DEV/STAGING/PROD]
Build Version: [VERSION]
CashierBloc Version: [BLOC_VERSION]
PaymentBloc Version: [BLOC_VERSION]

Total Test Cases: 27
- Section A (Cashier): 7 test cases
- Section B (Payment): 1 test case
- Section C (Payment Integration): 15 test cases
- Section D (Integration & Performance): 4 test cases

Passed: [NUMBER]
Failed: [NUMBER]
Skipped: [NUMBER]
Success Rate: [PERCENTAGE]%

Performance Results:
- Average CashierPage Load Time: [TIME]
- Average Add to Cart Time: [TIME]
- Average LoadPaymentData Time: [TIME]
- Average ProcessPayment Time: [TIME]
- Memory Usage Peak: [MB]
```

### Critical Issues Found

```
Severity: [HIGH/MEDIUM/LOW]
TC-[NUMBER]: [TEST CASE NAME]
Issue: [DESCRIPTION]
Impact: [USER IMPACT]
Reproducible: [YES/NO]
Screenshot: [LINK]
Workaround: [IF ANY]
```

### BLoC State Management Issues

```
Event: [EVENT_NAME]
Expected State: [STATE]
Actual State: [STATE]
Error Message: [IF ANY]
Stack Trace: [IF AVAILABLE]
```

### Database Transaction Issues

```
Transaction: [DESCRIPTION]
Tables Affected: [TABLE_NAMES]
Data Integrity: [OK/CORRUPTED]
Rollback: [SUCCESS/FAILED]
```

### Recommendations

- [ ] Critical bugs yang harus diperbaiki sebelum release
- [ ] Performance optimizations diperlukan
- [ ] UX improvements untuk error handling
- [ ] Additional test coverage needed
- [ ] Security enhancements required
