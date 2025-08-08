-- Script untuk memperbaiki role assignment user Glen
-- Jalankan script ini di Supabase SQL Editor

-- 1. Pastikan role "Owner" ada
INSERT INTO roles (name) 
VALUES ('Owner') 
ON CONFLICT (name) DO NOTHING;

-- 2. Cek data yang ada
SELECT '=== ROLES ===' as info;
SELECT * FROM roles;

SELECT '=== USERS ===' as info;
SELECT id, email, name FROM users;

SELECT '=== BUSINESSES ===' as info;
SELECT id, name FROM businesses;

SELECT '=== STORES ===' as info;
SELECT id, name, business_id FROM stores;

SELECT '=== ROLE ASSIGNMENTS ===' as info;
SELECT 
    ra.id,
    ra.user_id,
    ra.business_id,
    ra.store_id,
    ra.role_id,
    r.name as role_name,
    u.email as user_email,
    b.name as business_name,
    s.name as store_name
FROM role_assignments ra
LEFT JOIN roles r ON ra.role_id = r.id
LEFT JOIN users u ON ra.user_id = u.id
LEFT JOIN businesses b ON ra.business_id = b.id
LEFT JOIN stores s ON ra.store_id = s.id;

-- 3. Update role assignment untuk user Glen (ganti email sesuai yang ada)
-- Jika user Glen belum punya role assignment, buat yang baru
-- Jika sudah ada, update role_id-nya menjadi Owner

-- Cari user_id untuk Glen
-- Ganti 'glen@example.com' dengan email user Glen yang sebenarnya
WITH user_glen AS (
    SELECT id FROM users WHERE email = 'glen@example.com' LIMIT 1
),
business_allnimall AS (
    SELECT id FROM businesses WHERE name = 'Allnimall Pet Shop' LIMIT 1
),
store_toko AS (
    SELECT id FROM stores WHERE name = 'Toko' LIMIT 1
),
role_owner AS (
    SELECT id FROM roles WHERE name = 'Owner' LIMIT 1
)
-- Update role assignment jika sudah ada
UPDATE role_assignments 
SET role_id = (SELECT id FROM role_owner)
WHERE user_id = (SELECT id FROM user_glen)
AND business_id = (SELECT id FROM business_allnimall)
AND store_id = (SELECT id FROM store_toko);

-- 4. Jika belum ada role assignment, buat yang baru
-- Uncomment script di bawah jika user Glen belum punya role assignment
/*
INSERT INTO role_assignments (user_id, business_id, store_id, role_id)
SELECT 
    u.id as user_id,
    b.id as business_id,
    s.id as store_id,
    r.id as role_id
FROM users u
CROSS JOIN businesses b
CROSS JOIN stores s
CROSS JOIN roles r
WHERE u.email = 'glen@example.com'
AND r.name = 'Owner'
AND b.name = 'Allnimall Pet Shop'
AND s.name = 'Toko'
AND NOT EXISTS (
    SELECT 1 FROM role_assignments ra 
    WHERE ra.user_id = u.id 
    AND ra.business_id = b.id 
    AND ra.store_id = s.id
);
*/

-- 5. Verifikasi hasil
SELECT '=== FINAL ROLE ASSIGNMENTS ===' as info;
SELECT 
    ra.id,
    ra.user_id,
    ra.business_id,
    ra.store_id,
    ra.role_id,
    r.name as role_name,
    u.email as user_email,
    b.name as business_name,
    s.name as store_name
FROM role_assignments ra
LEFT JOIN roles r ON ra.role_id = r.id
LEFT JOIN users u ON ra.user_id = u.id
LEFT JOIN businesses b ON ra.business_id = b.id
LEFT JOIN stores s ON ra.store_id = s.id
WHERE u.email = 'glen@example.com';
