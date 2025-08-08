-- ========================================
-- SCHEMA DATABASE OURBIT POS
-- ========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- TABEL MASTER
-- ========================================

-- business_online_settings
CREATE TABLE public.business_online_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    subdomain VARCHAR NOT NULL,
    contact_email VARCHAR NOT NULL,
    description TEXT,
    facebook_url TEXT,
    instagram_url TEXT,
    twitter_url TEXT,
    stock_tracking INTEGER NOT NULL,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id)
);

-- businesses
CREATE TABLE public.businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name VARCHAR NOT NULL,
    code VARCHAR UNIQUE,
    description TEXT
);

-- categories
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id)
);

-- cities
CREATE TABLE public.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name VARCHAR NOT NULL,
    province_id UUID NOT NULL,
    FOREIGN KEY (province_id) REFERENCES public.provinces(id)
);

-- countries
CREATE TABLE public.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name VARCHAR NOT NULL
);

-- inventory_transactions
CREATE TABLE public.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    product_id UUID NOT NULL,
    store_id UUID NOT NULL,
    type INTEGER NOT NULL,
    quantity NUMERIC NOT NULL,
    reference VARCHAR,
    note TEXT,
    previous_qty NUMERIC,
    new_qty NUMERIC,
    batch_number VARCHAR,
    expiry_date DATE,
    unit_cost NUMERIC,
    total_cost NUMERIC,
    FOREIGN KEY (product_id) REFERENCES public.products(id),
    FOREIGN KEY (store_id) REFERENCES public.stores(id)
);

-- options
CREATE TABLE public.options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    type TEXT NOT NULL,
    name TEXT NOT NULL,
    key TEXT NOT NULL,
    value TEXT NOT NULL
);

-- ========================================
-- DATA TABEL OPTIONS (MASTER DATA)
-- ========================================

-- Business Age Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('business_age', 'Business Age', '1', 'Kurang dari 1 tahun'),
-- ('business_age', 'Business Age', '2', '1 – 3 tahun'),
-- ('business_age', 'Business Age', '3', '3 – 5 tahun'),
-- ('business_age', 'Business Age', '4', '5 – 10 tahun'),
-- ('business_age', 'Business Age', '5', 'Lebih dari 10 tahun');

-- Business Field Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('business_field', 'Business Field', '1', 'Kelontong / Grocery'),
-- ('business_field', 'Business Field', '2', 'Elektronik'),
-- ('business_field', 'Business Field', '3', 'Fashion / Pakaian & Aksesoris'),
-- ('business_field', 'Business Field', '4', 'Makanan & Minuman'),
-- ('business_field', 'Business Field', '5', 'Kecantikan & Perawatan'),
-- ('business_field', 'Business Field', '6', 'Pet Shop'),
-- ('business_field', 'Business Field', '7', 'Kesehatan & Farmasi'),
-- ('business_field', 'Business Field', '8', 'Otomotif & Bengkel'),
-- ('business_field', 'Business Field', '9', 'Perlengkapan Rumah Tangga'),
-- ('business_field', 'Business Field', '10', 'Buku & Alat Tulis'),
-- ('business_field', 'Business Field', '11', 'Souvenir & Gift'),
-- ('business_field', 'Business Field', '12', 'Olahraga & Outdoor'),
-- ('business_field', 'Business Field', '13', 'Jasa (laundry, cleaning...)'),
-- ('business_field', 'Business Field', '14', 'Optik'),
-- ('business_field', 'Business Field', '9999', 'Lain-lain');

-- Currency Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('currency', 'Kurs Mata Uang', '1', 'Indonesian Rupiah (Rp)'),
-- ('currency', 'Kurs Mata Uang', '2', 'US Dollar ($)'),
-- ('currency', 'Kurs Mata Uang', '3', 'Euro (€)'),
-- ('currency', 'Kurs Mata Uang', '4', 'Singapore Dollar (S$)'),
-- ('currency', 'Kurs Mata Uang', '5', 'Malaysian Ringgit (RM)'),
-- ('currency', 'Kurs Mata Uang', '6', 'Japanese Yen (¥)'),
-- ('currency', 'Kurs Mata Uang', '7', 'British Pound Sterling (£)');

-- Inventory Transaction Type Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('inventory_transaction_type', 'Inventory Transaction Type', '1', 'Pembelian'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '2', 'Penjualan'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '3', 'Penyesuaian'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '4', 'Transfer'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '5', 'Produksi'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '6', 'Kerusakan'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '7', 'Retur'),
-- ('inventory_transaction_type', 'Inventory Transaction Type', '8', 'Stock Opname');

-- Inventory Valuation Method Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('inventory_valuation_method', 'Inventory Valuation Method', '1', 'Default'),
-- ('inventory_valuation_method', 'Inventory Valuation Method', '2', 'FIFO'),
-- ('inventory_valuation_method', 'Inventory Valuation Method', '3', 'LIFO'),
-- ('inventory_valuation_method', 'Inventory Valuation Method', '4', 'Average');

-- Online Store Mode Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('online_store_mode', 'Online Store Mode', '1', 'Catalog'),
-- ('online_store_mode', 'Online Store Mode', '2', 'Catalog & Order'),
-- ('online_store_mode', 'Online Store Mode', '3', 'Disabled');

-- Product Type Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('product_type', 'Product Type', '1', 'Barang'),
-- ('product_type', 'Product Type', '2', 'Jasa'),
-- ('product_type', 'Product Type', '3', 'Kelas/Jadwal');

-- Stock Opname Session Status Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('stock_opname_session_status', 'Stock Opname Session Status', '1', 'Open'),
-- ('stock_opname_session_status', 'Stock Opname Session Status', '2', 'Counted'),
-- ('stock_opname_session_status', 'Stock Opname Session Status', '3', 'Adjusted'),
-- ('stock_opname_session_status', 'Stock Opname Session Status', '4', 'Closed');

-- Stock Opname Status Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('stock_opname_status', 'Stock Opname Status', '1', 'Draft'),
-- ('stock_opname_status', 'Stock Opname Status', '2', 'Sedang Berlangsung'),
-- ('stock_opname_status', 'Stock Opname Status', '3', 'Selesai'),
-- ('stock_opname_status', 'Stock Opname Status', '4', 'Dibatalkan');

-- Stock Tracking Mode Options
-- INSERT INTO options (type, name, key, value) VALUES
-- ('stock_tracking_mode', 'Stock Tracking Mode', '1', 'Physical'),
-- ('stock_tracking_mode', 'Stock Tracking Mode', '2', 'Booking');

-- products
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    category_id UUID,
    store_id UUID NOT NULL,
    type TEXT NOT NULL,
    auto_sku BOOLEAN NOT NULL DEFAULT true,
    code VARCHAR UNIQUE,
    purchase_price NUMERIC NOT NULL DEFAULT 0,
    selling_price NUMERIC NOT NULL DEFAULT 0,
    stock INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER NOT NULL DEFAULT 0,
    unit VARCHAR,
    weight_grams INTEGER NOT NULL DEFAULT 0,
    discount_type INTEGER NOT NULL DEFAULT 1,
    discount_value NUMERIC NOT NULL DEFAULT 0,
    description TEXT,
    rack_location VARCHAR,
    image_url TEXT,
    name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (category_id) REFERENCES public.categories(id),
    FOREIGN KEY (store_id) REFERENCES public.stores(id)
);

-- provinces
CREATE TABLE public.provinces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name VARCHAR NOT NULL,
    country_id UUID NOT NULL,
    FOREIGN KEY (country_id) REFERENCES public.countries(id)
);

-- role_assignments
CREATE TABLE public.role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    user_id UUID NOT NULL,
    business_id UUID NOT NULL,
    role_id UUID NOT NULL,
    store_id UUID NOT NULL,
    FOREIGN KEY (user_id) REFERENCES public.users(id),
    FOREIGN KEY (business_id) REFERENCES public.businesses(id),
    FOREIGN KEY (role_id) REFERENCES public.roles(id),
    FOREIGN KEY (store_id) REFERENCES public.stores(id)
);

-- roles
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name VARCHAR NOT NULL
);

-- stock_opname_items
CREATE TABLE public.stock_opname_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    session_id UUID NOT NULL,
    product_id UUID NOT NULL,
    expected_qty NUMERIC NOT NULL,
    actual_qty NUMERIC NOT NULL,
    qty_variance NUMERIC GENERATED ALWAYS AS (actual_qty - expected_qty) STORED,
    note TEXT,
    FOREIGN KEY (session_id) REFERENCES public.stock_opname_sessions(id),
    FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- stock_opname_sessions
CREATE TABLE public.stock_opname_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    finished_at TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT '1',
    total_items INTEGER DEFAULT 0,
    items_counted INTEGER DEFAULT 0,
    total_variance_value NUMERIC DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id)
);

-- stores
CREATE TABLE public.stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    country_id UUID NOT NULL,
    province_id UUID NOT NULL,
    city_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    address TEXT NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    phone_country_code VARCHAR NOT NULL DEFAULT '+62',
    phone_number VARCHAR NOT NULL,
    phone_verified BOOLEAN NOT NULL DEFAULT false,
    business_field TEXT NOT NULL,
    business_description TEXT,
    stock_setting TEXT NOT NULL,
    currency TEXT NOT NULL,
    default_tax_rate NUMERIC NOT NULL DEFAULT 0,
    motto TEXT,
    is_branch BOOLEAN NOT NULL DEFAULT true,
    is_online_delivery_active BOOLEAN DEFAULT false,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id),
    FOREIGN KEY (country_id) REFERENCES public.countries(id),
    FOREIGN KEY (province_id) REFERENCES public.provinces(id),
    FOREIGN KEY (city_id) REFERENCES public.cities(id)
);

-- warehouses
CREATE TABLE public.warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    country_id UUID NOT NULL,
    province_id UUID NOT NULL,
    city_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    address TEXT NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    phone_country_code VARCHAR NOT NULL DEFAULT '+62',
    phone_number VARCHAR NOT NULL,
    warehouse_type VARCHAR NOT NULL DEFAULT 'distribution',
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_online_delivery_active BOOLEAN DEFAULT false,
    notes TEXT,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id),
    FOREIGN KEY (country_id) REFERENCES public.countries(id),
    FOREIGN KEY (province_id) REFERENCES public.provinces(id),
    FOREIGN KEY (city_id) REFERENCES public.cities(id)
);

-- users
CREATE TABLE public.users (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    name TEXT,
    email TEXT NOT NULL,
    phone TEXT,
    FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- store_carts
CREATE TABLE public.store_carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 1,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- suppliers
CREATE TABLE public.suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    code VARCHAR,
    contact_person VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    address TEXT,
    city_id UUID,
    province_id UUID,
    country_id UUID,
    tax_number VARCHAR,
    bank_name VARCHAR,
    bank_account_number VARCHAR,
    bank_account_name VARCHAR,
    credit_limit NUMERIC DEFAULT 0,
    payment_terms INTEGER DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id),
    FOREIGN KEY (city_id) REFERENCES public.cities(id),
    FOREIGN KEY (province_id) REFERENCES public.provinces(id),
    FOREIGN KEY (country_id) REFERENCES public.countries(id)
);

-- customers
CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    code VARCHAR,
    email VARCHAR,
    phone VARCHAR,
    address TEXT,
    city_id UUID,
    province_id UUID,
    country_id UUID,
    tax_number VARCHAR,
    customer_type VARCHAR DEFAULT 'retail',
    credit_limit NUMERIC DEFAULT 0,
    payment_terms INTEGER DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    -- Hybrid approach fields
    auth_user_id UUID,
    customer_source VARCHAR DEFAULT 'offline',
    is_verified BOOLEAN DEFAULT false,
    verification_code VARCHAR,
    total_orders INTEGER DEFAULT 0,
    total_spent NUMERIC DEFAULT 0,
    loyalty_points INTEGER DEFAULT 0,
    last_order_date TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id),
    FOREIGN KEY (city_id) REFERENCES public.cities(id),
    FOREIGN KEY (province_id) REFERENCES public.provinces(id),
    FOREIGN KEY (country_id) REFERENCES public.countries(id),
    FOREIGN KEY (auth_user_id) REFERENCES auth.users(id)
);

-- zmaster (placeholder table)
CREATE TABLE public.zmaster (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID
);

-- payment_types
CREATE TABLE public.payment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    code TEXT NOT NULL,
    name TEXT NOT NULL
);

-- payment_methods
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    payment_type_id UUID NOT NULL,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (payment_type_id) REFERENCES public.payment_types(id)
);

-- store_payment_methods
CREATE TABLE public.store_payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id)
);

-- ========================================
-- TABEL UNTUK LAPORAN
-- ========================================

-- sales
CREATE TABLE public.sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID,
    warehouse_id UUID,
    customer_id UUID,
    customer_name VARCHAR,
    customer_phone VARCHAR,
    customer_email VARCHAR,
    sale_number VARCHAR NOT NULL,
    sale_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    subtotal NUMERIC NOT NULL DEFAULT 0,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    tax_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL DEFAULT 0,
    payment_method_id UUID,
    status VARCHAR NOT NULL DEFAULT 'completed',
    notes TEXT,
    cashier_id UUID,
    sale_source VARCHAR DEFAULT 'offline',
    delivery_address TEXT,
    delivery_fee NUMERIC DEFAULT 0,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    tracking_number VARCHAR,
    courier_name VARCHAR,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
    FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id),
    FOREIGN KEY (cashier_id) REFERENCES public.users(id)
);

-- sales_items
CREATE TABLE public.sales_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    sale_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity NUMERIC NOT NULL,
    unit_price NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    tax_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES public.sales(id),
    FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- purchases
CREATE TABLE public.purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    supplier_id UUID NOT NULL,
    purchase_number VARCHAR NOT NULL,
    purchase_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    due_date TIMESTAMP WITH TIME ZONE,
    subtotal NUMERIC NOT NULL DEFAULT 0,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    tax_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL DEFAULT 0,
    payment_method_id UUID,
    payment_terms INTEGER DEFAULT 0,
    status VARCHAR NOT NULL DEFAULT 'pending',
    received_by UUID,
    received_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
    FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id),
    FOREIGN KEY (received_by) REFERENCES public.users(id)
);

-- purchases_items
CREATE TABLE public.purchases_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    purchase_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity NUMERIC NOT NULL,
    unit_price NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    tax_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL,
    received_qty NUMERIC DEFAULT 0,
    FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
    FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- financial_transactions
CREATE TABLE public.financial_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    transaction_type VARCHAR NOT NULL,
    category VARCHAR NOT NULL,
    subcategory VARCHAR,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    payment_method_id UUID,
    account VARCHAR,
    reference_number VARCHAR,
    status VARCHAR NOT NULL DEFAULT 'completed',
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id)
);

-- receivables
CREATE TABLE public.receivables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    sale_id UUID,
    reference_number VARCHAR NOT NULL,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    original_amount NUMERIC NOT NULL,
    paid_amount NUMERIC NOT NULL DEFAULT 0,
    remaining_amount NUMERIC GENERATED ALWAYS AS (original_amount - paid_amount) STORED,
    status VARCHAR NOT NULL DEFAULT 'pending',
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    FOREIGN KEY (sale_id) REFERENCES public.sales(id)
);

-- payables
CREATE TABLE public.payables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    supplier_id UUID NOT NULL,
    purchase_id UUID,
    reference_number VARCHAR NOT NULL,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    original_amount NUMERIC NOT NULL,
    paid_amount NUMERIC NOT NULL DEFAULT 0,
    remaining_amount NUMERIC GENERATED ALWAYS AS (original_amount - paid_amount) STORED,
    status VARCHAR NOT NULL DEFAULT 'pending',
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
    FOREIGN KEY (purchase_id) REFERENCES public.purchases(id)
);

-- profit_loss_items
CREATE TABLE public.profit_loss_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    category VARCHAR NOT NULL,
    subcategory VARCHAR NOT NULL,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    percentage_of_revenue NUMERIC,
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id)
);

-- ========================================
-- TABEL TAMBAHAN UNTUK MANAGEMENT SYSTEM
-- ========================================

-- discounts
CREATE TABLE public.discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    code VARCHAR UNIQUE,
    type VARCHAR NOT NULL DEFAULT 'percentage',
    value NUMERIC NOT NULL DEFAULT 0,
    min_purchase_amount NUMERIC DEFAULT 0,
    max_discount_amount NUMERIC,
    is_active BOOLEAN NOT NULL DEFAULT true,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    description TEXT,
    notes TEXT,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id)
);

-- expenses
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    category VARCHAR NOT NULL,
    subcategory VARCHAR,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method_id UUID,
    is_paid BOOLEAN NOT NULL DEFAULT false,
    paid_at TIMESTAMP WITH TIME ZONE,
    paid_by UUID,
    receipt_url TEXT,
    notes TEXT,
    FOREIGN KEY (store_id) REFERENCES public.stores(id),
    FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id),
    FOREIGN KEY (paid_by) REFERENCES public.users(id)
);

-- loyalty_programs
CREATE TABLE public.loyalty_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    business_id UUID NOT NULL,
    name VARCHAR NOT NULL,
    code VARCHAR UNIQUE,
    min_points INTEGER NOT NULL DEFAULT 0,
    discount_percentage NUMERIC NOT NULL DEFAULT 0,
    discount_amount NUMERIC DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    description TEXT,
    terms_conditions TEXT,
    FOREIGN KEY (business_id) REFERENCES public.businesses(id)
);

-- customer_loyalty_memberships
CREATE TABLE public.customer_loyalty_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    customer_id UUID NOT NULL,
    loyalty_program_id UUID NOT NULL,
    current_points INTEGER NOT NULL DEFAULT 0,
    total_points_earned INTEGER NOT NULL DEFAULT 0,
    total_points_redeemed INTEGER NOT NULL DEFAULT 0,
    joined_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    is_active BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    FOREIGN KEY (loyalty_program_id) REFERENCES public.loyalty_programs(id)
);

-- ========================================
-- INDEXES UNTUK PERFORMANCE
-- ========================================

-- Indexes untuk discounts
CREATE INDEX idx_discounts_business_id ON public.discounts(business_id);
CREATE INDEX idx_discounts_is_active ON public.discounts(is_active);
CREATE INDEX idx_discounts_end_date ON public.discounts(end_date);

-- Indexes untuk expenses
CREATE INDEX idx_expenses_store_id ON public.expenses(store_id);
CREATE INDEX idx_expenses_category ON public.expenses(category);
CREATE INDEX idx_expenses_expense_date ON public.expenses(expense_date);
CREATE INDEX idx_expenses_is_paid ON public.expenses(is_paid);

-- Indexes untuk loyalty_programs
CREATE INDEX idx_loyalty_programs_business_id ON public.loyalty_programs(business_id);
CREATE INDEX idx_loyalty_programs_is_active ON public.loyalty_programs(is_active);

-- Indexes untuk customer_loyalty_memberships
CREATE INDEX idx_customer_loyalty_memberships_customer_id ON public.customer_loyalty_memberships(customer_id);
CREATE INDEX idx_customer_loyalty_memberships_loyalty_program_id ON public.customer_loyalty_memberships(loyalty_program_id);
CREATE INDEX idx_customer_loyalty_memberships_is_active ON public.customer_loyalty_memberships(is_active);

-- ========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================

-- Enable RLS on tables
ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_loyalty_memberships ENABLE ROW LEVEL SECURITY;

-- Policies untuk discounts
CREATE POLICY "Users can view discounts for their business" ON public.discounts
    FOR SELECT USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert discounts for their business" ON public.discounts
    FOR INSERT WITH CHECK (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update discounts for their business" ON public.discounts
    FOR UPDATE USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete discounts for their business" ON public.discounts
    FOR DELETE USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

-- Policies untuk expenses
CREATE POLICY "Users can view expenses for their store" ON public.expenses
    FOR SELECT USING (
        store_id IN (
            SELECT store_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert expenses for their store" ON public.expenses
    FOR INSERT WITH CHECK (
        store_id IN (
            SELECT store_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update expenses for their store" ON public.expenses
    FOR UPDATE USING (
        store_id IN (
            SELECT store_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete expenses for their store" ON public.expenses
    FOR DELETE USING (
        store_id IN (
            SELECT store_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

-- Policies untuk loyalty_programs
CREATE POLICY "Users can view loyalty programs for their business" ON public.loyalty_programs
    FOR SELECT USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert loyalty programs for their business" ON public.loyalty_programs
    FOR INSERT WITH CHECK (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update loyalty programs for their business" ON public.loyalty_programs
    FOR UPDATE USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete loyalty programs for their business" ON public.loyalty_programs
    FOR DELETE USING (
        business_id IN (
            SELECT business_id FROM public.role_assignments 
            WHERE user_id = auth.uid()
        )
    );

-- Policies untuk customer_loyalty_memberships
CREATE POLICY "Users can view customer loyalty memberships for their business" ON public.customer_loyalty_memberships
    FOR SELECT USING (
        customer_id IN (
            SELECT c.id FROM public.customers c
            JOIN public.role_assignments ra ON c.business_id = ra.business_id
            WHERE ra.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert customer loyalty memberships for their business" ON public.customer_loyalty_memberships
    FOR INSERT WITH CHECK (
        customer_id IN (
            SELECT c.id FROM public.customers c
            JOIN public.role_assignments ra ON c.business_id = ra.business_id
            WHERE ra.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update customer loyalty memberships for their business" ON public.customer_loyalty_memberships
    FOR UPDATE USING (
        customer_id IN (
            SELECT c.id FROM public.customers c
            JOIN public.role_assignments ra ON c.business_id = ra.business_id
            WHERE ra.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete customer loyalty memberships for their business" ON public.customer_loyalty_memberships
    FOR DELETE USING (
        customer_id IN (
            SELECT c.id FROM public.customers c
            JOIN public.role_assignments ra ON c.business_id = ra.business_id
            WHERE ra.user_id = auth.uid()
        )
    );

-- ========================================
-- CONSTRAINTS
-- ========================================

-- Unique constraints untuk customers
ALTER TABLE public.customers ADD CONSTRAINT customers_phone_unique UNIQUE (phone);
ALTER TABLE public.customers ADD CONSTRAINT customers_email_unique UNIQUE (email);
