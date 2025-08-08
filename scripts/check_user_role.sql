-- Script untuk mengecek dan memperbaiki data role user
-- Jalankan script ini di Supabase SQL Editor

-- 1. Cek data roles yang ada
SELECT * FROM roles;

-- 2. Cek data role_assignments yang ada
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

-- 3. Cek user yang ada
SELECT * FROM users;

-- 4. Jika belum ada role "Owner", insert role tersebut
INSERT INTO roles (name) 
VALUES ('Owner') 
ON CONFLICT (name) DO NOTHING;

-- 5. Jika belum ada role "User", insert role tersebut  
INSERT INTO roles (name) 
VALUES ('User') 
ON CONFLICT (name) DO NOTHING;

-- 6. Cek apakah user Glen sudah punya role assignment
-- Ganti 'glen@example.com' dengan email user Glen yang sebenarnya
SELECT 
    ra.id,
    ra.user_id,
    ra.business_id,
    ra.store_id,
    ra.role_id,
    r.name as role_name,
    u.email as user_email
FROM role_assignments ra
LEFT JOIN roles r ON ra.role_id = r.id
LEFT JOIN users u ON ra.user_id = u.id
WHERE u.email = 'glen@example.com';

-- 7. Jika user Glen belum punya role assignment, buat role assignment untuk Owner
-- Ganti UUID di bawah dengan ID yang sesuai dari database
-- Pastikan business_id, store_id, dan role_id sesuai dengan data yang ada
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
AND b.name = 'Allnimall Pet Shop'  -- sesuaikan dengan nama business
AND s.name = 'Toko'  -- sesuaikan dengan nama store
LIMIT 1;
*/
