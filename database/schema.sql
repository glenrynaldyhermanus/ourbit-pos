-- ========================================
-- SCHEMA DDL SNAPSHOT (common, ourbit)
-- Refreshed via Supabase MCP on 2025-08-16
-- ========================================

-- Required extensions (idempotent)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- SCHEMA: common
-- ========================================

CREATE SCHEMA IF NOT EXISTS common;

-- Tables (common)
CREATE TABLE common.businesses (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name character varying(150) NOT NULL,
  code character varying(50),
  description text,
  business_age text
);

CREATE TABLE common.cities (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name character varying(100) NOT NULL,
  province_id uuid NOT NULL
);

CREATE TABLE common.countries (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name character varying(100) NOT NULL
);

CREATE TABLE common.options (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  type text NOT NULL,
  name text NOT NULL,
  key text NOT NULL,
  value text NOT NULL
);

CREATE TABLE common.provinces (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name character varying(100) NOT NULL,
  country_id uuid NOT NULL
);

CREATE TABLE common.role_assignments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  user_id uuid NOT NULL,
  business_id uuid NOT NULL,
  role_id uuid NOT NULL,
  store_id uuid NOT NULL
);

CREATE TABLE common.roles (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name character varying(50) NOT NULL
);

CREATE TABLE common.stores (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  country_id uuid NOT NULL,
  province_id uuid NOT NULL,
  city_id uuid NOT NULL,
  name character varying(150) NOT NULL,
  address text NOT NULL,
  latitude numeric(10,6),
  longitude numeric(10,6),
  phone_country_code character varying(10) DEFAULT '+62'::character varying NOT NULL,
  phone_number character varying(20) NOT NULL,
  phone_verified boolean DEFAULT false NOT NULL,
  business_field text NOT NULL,
  business_description text,
  stock_setting text NOT NULL,
  currency text NOT NULL,
  default_tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
  motto text,
  is_branch boolean DEFAULT true NOT NULL,
  is_online_delivery_active boolean DEFAULT false,
  is_verified boolean DEFAULT false NOT NULL,
  zip_code character varying
);

CREATE TABLE common.users (
  id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  name text,
  email text NOT NULL,
  phone text
);

-- ========================================
-- HELP CENTER / SUPPORT TICKETS (multi-app)
-- Schema: common
-- ========================================

CREATE TABLE IF NOT EXISTS common.support_tickets (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamptz,
  updated_by uuid,
  deleted_at timestamptz,
  deleted_by uuid,

  -- Scope opsional (boleh NULL untuk apps publik)
  business_id uuid,

  -- Pelapor
  requester_user_id uuid NOT NULL,

  -- Identitas aplikasi & status (dinamis via common.options)
  app text NOT NULL,
  status text NOT NULL,

  -- Informasi tambahan (opsional)
  app_version text,
  platform text,
  environment text,

  -- Konten tiket
  subject text NOT NULL,
  category text NOT NULL,
  description text NOT NULL,

  -- Data fleksibel
  meta jsonb
);

ALTER TABLE common.support_tickets
  ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);

ALTER TABLE common.support_tickets
  ADD CONSTRAINT support_tickets_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES common.businesses(id)
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE common.support_tickets
  ADD CONSTRAINT support_tickets_requester_user_id_fkey
  FOREIGN KEY (requester_user_id) REFERENCES common.users(id)
  ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_support_tickets_app_status
  ON common.support_tickets (app, status);

CREATE INDEX IF NOT EXISTS idx_support_tickets_requester
  ON common.support_tickets (requester_user_id);

CREATE INDEX IF NOT EXISTS idx_support_tickets_business
  ON common.support_tickets (business_id);

-- Seed options (aman dari duplikasi)
-- Apps
INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_app', 'Ourbit Kasir (Desktop)', 'ourbit_pos_desktop', 'ourbit_pos_desktop'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_app' AND key = 'ourbit_pos_desktop'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_app', 'Ourbit Kasir (Mobile)', 'ourbit_pos_mobile', 'ourbit_pos_mobile'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_app' AND key = 'ourbit_pos_mobile'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_app', 'Ourbit Kasir (Web)', 'ourbit_pos_web', 'ourbit_pos_web'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_app' AND key = 'ourbit_pos_web'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_app', 'Ourank Website', 'ourank_website', 'ourank_website'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_app' AND key = 'ourank_website'
);

-- Status
INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_status', 'Open', 'open', 'open'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_status' AND key = 'open'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_status', 'Requested', 'requested', 'requested'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_status' AND key = 'requested'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-000000000000', 'support_ticket_status', 'Under Review', 'under_review', 'under_review'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_status' AND key = 'under_review'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-000000000000', 'support_ticket_status', 'In Progress', 'in_progress', 'in_progress'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_status' AND key = 'in_progress'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_status', 'Done', 'done', 'done'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_status' AND key = 'done'
);

-- Kategori
INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_category', 'Keluhan', 'keluhan', 'keluhan'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_category' AND key = 'keluhan'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_category', 'Bug', 'bug', 'bug'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_category' AND key = 'bug'
);

INSERT INTO common.options (id, created_at, created_by, type, name, key, value)
SELECT gen_random_uuid(), now(), '00000000-0000-0000-0000-000000000000', 'support_ticket_category', 'Request Fitur', 'feature_request', 'feature_request'
WHERE NOT EXISTS (
  SELECT 1 FROM common.options WHERE type = 'support_ticket_category' AND key = 'feature_request'
);

CREATE TABLE common.webhook_events (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  provider text NOT NULL,
  event_id text NOT NULL,
  raw_json jsonb,
  processed_at timestamp with time zone,
  status text DEFAULT 'received'::text NOT NULL
);

-- ========================================
-- HELP CENTER / FAQ (multi-app)
-- Schema: common
-- ========================================

CREATE TABLE IF NOT EXISTS common.support_faq_categories (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamptz,
  updated_by uuid,
  deleted_at timestamptz,
  deleted_by uuid,

  business_id uuid,
  name text NOT NULL,
  display_order int DEFAULT 0 NOT NULL
);

ALTER TABLE common.support_faq_categories
  ADD CONSTRAINT support_faq_categories_pkey PRIMARY KEY (id);

ALTER TABLE common.support_faq_categories
  ADD CONSTRAINT support_faq_categories_business_id_fkey
  FOREIGN KEY (business_id) REFERENCES common.businesses(id)
  ON UPDATE CASCADE ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_support_faq_categories_business
  ON common.support_faq_categories (business_id, display_order);

CREATE TABLE IF NOT EXISTS common.support_faqs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamptz,
  updated_by uuid,
  deleted_at timestamptz,
  deleted_by uuid,

  category_id uuid NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  tags text[],
  is_active boolean DEFAULT true NOT NULL,
  display_order int DEFAULT 0 NOT NULL
);

ALTER TABLE common.support_faqs
  ADD CONSTRAINT support_faqs_pkey PRIMARY KEY (id);

ALTER TABLE common.support_faqs
  ADD CONSTRAINT support_faqs_category_id_fkey
  FOREIGN KEY (category_id) REFERENCES common.support_faq_categories(id)
  ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_support_faqs_category
  ON common.support_faqs (category_id, is_active, display_order);

-- Seed minimal FAQ category & item (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM common.support_faq_categories WHERE name = 'Umum') THEN
    INSERT INTO common.support_faq_categories (id, name, display_order)
    VALUES (gen_random_uuid(), 'Umum', 0);
  END IF;
END $$;

DO $$
DECLARE
  cat_id uuid;
BEGIN
  SELECT id INTO cat_id FROM common.support_faq_categories WHERE name = 'Umum' LIMIT 1;
  IF cat_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM common.support_faqs WHERE title = 'Apa itu Ourbit POS?'
  ) THEN
    INSERT INTO common.support_faqs (id, category_id, title, content, display_order)
    VALUES (
      gen_random_uuid(),
      cat_id,
      'Apa itu Ourbit POS?',
      'Ourbit POS adalah sistem Point of Sale untuk memudahkan operasional toko, kasir, dan manajemen data.',
      0
    );
  END IF;
END $$;

CREATE TABLE common.zmaster (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid
);

-- Constraints (common)
ALTER TABLE common.businesses ADD CONSTRAINT businesses_code_key UNIQUE (code);
ALTER TABLE common.businesses ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);
ALTER TABLE common.cities ADD CONSTRAINT cities_pkey PRIMARY KEY (id);
ALTER TABLE common.cities ADD CONSTRAINT cities_province_id_fkey FOREIGN KEY (province_id) REFERENCES common.provinces(id) ON DELETE CASCADE;
ALTER TABLE common.countries ADD CONSTRAINT countries_pkey PRIMARY KEY (id);
ALTER TABLE common.options ADD CONSTRAINT options_pkey PRIMARY KEY (id);
ALTER TABLE common.provinces ADD CONSTRAINT province_pkey PRIMARY KEY (id);
ALTER TABLE common.provinces ADD CONSTRAINT provinces_country_id_fkey FOREIGN KEY (country_id) REFERENCES common.countries(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.role_assignments ADD CONSTRAINT role_assignments_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.role_assignments ADD CONSTRAINT users_businesses_pkey PRIMARY KEY (id);
ALTER TABLE common.role_assignments ADD CONSTRAINT users_businesses_roles_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.role_assignments ADD CONSTRAINT users_businesses_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES common.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.role_assignments ADD CONSTRAINT users_businesses_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES common.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.roles ADD CONSTRAINT roles_pkey PRIMARY KEY (id);
ALTER TABLE common.stores ADD CONSTRAINT stores_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.stores ADD CONSTRAINT stores_city_id_fkey FOREIGN KEY (city_id) REFERENCES common.cities(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.stores ADD CONSTRAINT stores_country_id_fkey FOREIGN KEY (country_id) REFERENCES common.countries(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.stores ADD CONSTRAINT stores_pkey PRIMARY KEY (id);
ALTER TABLE common.stores ADD CONSTRAINT stores_province_id_fkey FOREIGN KEY (province_id) REFERENCES common.provinces(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.users ADD CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE common.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE common.webhook_events ADD CONSTRAINT webhook_events_event_unique UNIQUE (provider, event_id);
ALTER TABLE common.webhook_events ADD CONSTRAINT webhook_events_pkey PRIMARY KEY (id);
ALTER TABLE common.zmaster ADD CONSTRAINT zmaster_pkey PRIMARY KEY (id);

-- Indexes (common)
CREATE INDEX idx_stores_business_id ON common.stores USING btree (business_id);
CREATE INDEX idx_stores_business_online ON common.stores USING btree (business_id, is_online_delivery_active);
CREATE UNIQUE INDEX businesses_code_key ON common.businesses USING btree (code);
CREATE UNIQUE INDEX webhook_events_event_unique ON common.webhook_events USING btree (provider, event_id);

-- ========================================
-- SCHEMA: ourbit
-- ========================================

CREATE SCHEMA IF NOT EXISTS ourbit;

-- Tables (ourbit)
CREATE TABLE ourbit.analytics_events (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  store_id uuid NOT NULL,
  session_id text,
  type text NOT NULL,
  meta_json jsonb
);

CREATE TABLE ourbit.business_online_settings (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  subdomain character varying(100) NOT NULL,
  contact_email character varying(255) NOT NULL,
  description text,
  facebook_url text,
  instagram_url text,
  twitter_url text,
  stock_tracking integer NOT NULL,
  default_online_store_id uuid,
  display_name text,
  avatar_url text,
  banner_url text,
  theme_json jsonb,
  socials_json jsonb
);

CREATE TABLE ourbit.cart_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  cart_id uuid NOT NULL,
  product_id uuid NOT NULL,
  variant_id uuid,
  qty integer DEFAULT 1 NOT NULL,
  price_snapshot numeric DEFAULT 0 NOT NULL,
  name_snapshot text,
  variant_snapshot text,
  weight_grams_snapshot integer DEFAULT 0
);

CREATE TABLE ourbit.carts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  session_id text NOT NULL,
  user_id uuid
);

CREATE TABLE ourbit.categories (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  name character varying(100) NOT NULL
);

CREATE TABLE ourbit.customer_loyalty_memberships (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  customer_id uuid NOT NULL,
  loyalty_program_id uuid NOT NULL,
  current_points integer DEFAULT 0 NOT NULL,
  total_points_earned integer DEFAULT 0 NOT NULL,
  total_points_redeemed integer DEFAULT 0 NOT NULL,
  joined_date timestamp with time zone DEFAULT now() NOT NULL,
  is_active boolean DEFAULT true NOT NULL
);

CREATE TABLE ourbit.customers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  name character varying NOT NULL,
  code character varying,
  email character varying,
  phone character varying,
  address text,
  city_id uuid,
  province_id uuid,
  country_id uuid,
  tax_number character varying,
  customer_type character varying DEFAULT 'retail'::character varying,
  credit_limit numeric DEFAULT 0,
  payment_terms integer DEFAULT 0,
  is_active boolean DEFAULT true NOT NULL,
  notes text,
  auth_user_id uuid,
  customer_source character varying DEFAULT 'offline'::character varying,
  is_verified boolean DEFAULT false,
  verification_code character varying,
  total_orders integer DEFAULT 0,
  total_spent numeric DEFAULT 0,
  loyalty_points integer DEFAULT 0,
  last_order_date timestamp with time zone
);

CREATE TABLE ourbit.discounts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  name character varying NOT NULL,
  code character varying,
  type character varying DEFAULT 'percentage'::character varying NOT NULL,
  value numeric DEFAULT 0 NOT NULL,
  min_purchase_amount numeric DEFAULT 0,
  max_discount_amount numeric,
  is_active boolean DEFAULT true NOT NULL,
  start_date timestamp with time zone,
  end_date timestamp with time zone,
  usage_limit integer,
  used_count integer DEFAULT 0,
  description text,
  notes text
);

CREATE TABLE ourbit.expenses (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  category character varying NOT NULL,
  subcategory character varying,
  description text NOT NULL,
  amount numeric NOT NULL,
  expense_date date DEFAULT CURRENT_DATE NOT NULL,
  payment_method_id uuid,
  is_paid boolean DEFAULT false NOT NULL,
  paid_at timestamp with time zone,
  paid_by uuid,
  receipt_url text,
  notes text
);

CREATE TABLE ourbit.financial_transactions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  transaction_date timestamp with time zone DEFAULT now() NOT NULL,
  transaction_type character varying NOT NULL,
  category character varying NOT NULL,
  subcategory character varying,
  description text NOT NULL,
  amount numeric NOT NULL,
  payment_method_id uuid,
  account character varying,
  reference_number character varying,
  status character varying DEFAULT 'completed'::character varying NOT NULL,
  notes text
);

CREATE TABLE ourbit.inventory_transactions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  product_id uuid NOT NULL,
  store_id uuid NOT NULL,
  type integer NOT NULL,
  quantity numeric(12,2) NOT NULL,
  reference character varying(100),
  note text,
  previous_qty numeric,
  new_qty numeric,
  batch_number character varying,
  expiry_date date,
  unit_cost numeric,
  total_cost numeric
);

CREATE TABLE ourbit.kyc_documents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  kyc_submission_id uuid NOT NULL,
  type text NOT NULL,
  file_url text NOT NULL,
  verified_at timestamp with time zone
);

CREATE TABLE ourbit.kyc_submissions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid,
  store_id uuid,
  status text DEFAULT 'pending'::text NOT NULL,
  reason text
);

CREATE TABLE ourbit.loyalty_programs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  name character varying NOT NULL,
  code character varying,
  min_points integer DEFAULT 0 NOT NULL,
  discount_percentage numeric DEFAULT 0 NOT NULL,
  discount_amount numeric DEFAULT 0,
  is_active boolean DEFAULT true NOT NULL,
  start_date timestamp with time zone,
  end_date timestamp with time zone,
  description text,
  terms_conditions text
);

CREATE TABLE ourbit.notifications (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  store_id uuid NOT NULL,
  sale_id uuid,
  channel text NOT NULL,
  template text NOT NULL,
  recipient text NOT NULL,
  payload_json jsonb,
  status text DEFAULT 'pending'::text NOT NULL,
  error text,
  sent_at timestamp with time zone
);

CREATE TABLE ourbit.order_shipments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  sale_id uuid NOT NULL,
  provider text,
  service text,
  cost numeric,
  etd text,
  tracking_number text,
  status text,
  raw_json jsonb
);

CREATE TABLE ourbit.payables (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  supplier_id uuid NOT NULL,
  purchase_id uuid,
  reference_number character varying NOT NULL,
  transaction_date timestamp with time zone DEFAULT now() NOT NULL,
  due_date timestamp with time zone NOT NULL,
  original_amount numeric NOT NULL,
  paid_amount numeric DEFAULT 0 NOT NULL,
  remaining_amount numeric GENERATED ALWAYS AS IDENTITY,
  status character varying DEFAULT 'pending'::character varying NOT NULL,
  notes text
);

CREATE TABLE ourbit.payment_methods (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  payment_type_id uuid NOT NULL,
  code text NOT NULL,
  name text NOT NULL
);

CREATE TABLE ourbit.payment_types (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  code text NOT NULL,
  name text NOT NULL
);

CREATE TABLE ourbit.payments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  sale_id uuid NOT NULL,
  provider text NOT NULL,
  provider_ref text NOT NULL,
  amount numeric NOT NULL,
  status text NOT NULL,
  raw_json jsonb
);

CREATE TABLE ourbit.product_images (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  product_id uuid NOT NULL,
  url text NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL
);

CREATE TABLE ourbit.product_variants (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  product_id uuid NOT NULL,
  name text NOT NULL,
  sku text,
  price_override numeric,
  stock integer,
  weight_grams integer,
  is_active boolean DEFAULT true NOT NULL
);

CREATE TABLE ourbit.products (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  category_id uuid,
  store_id uuid NOT NULL,
  type text NOT NULL,
  auto_sku boolean DEFAULT true NOT NULL,
  code character varying(50),
  purchase_price numeric(12,2) DEFAULT 0 NOT NULL,
  selling_price numeric(12,2) DEFAULT 0 NOT NULL,
  stock integer DEFAULT 0 NOT NULL,
  min_stock integer DEFAULT 0 NOT NULL,
  unit character varying(20),
  weight_grams integer DEFAULT 0 NOT NULL,
  discount_type integer DEFAULT 1 NOT NULL,
  discount_value numeric(12,2) DEFAULT 0 NOT NULL,
  description text,
  rack_location character varying(100),
  image_url text,
  name text NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  availability_status text DEFAULT 'available'::text NOT NULL,
  is_pinned boolean DEFAULT false NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL
);

CREATE TABLE ourbit.profit_loss_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  period_start date NOT NULL,
  period_end date NOT NULL,
  category character varying NOT NULL,
  subcategory character varying NOT NULL,
  description text NOT NULL,
  amount numeric NOT NULL,
  percentage_of_revenue numeric,
  notes text
);

CREATE TABLE ourbit.purchases (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  supplier_id uuid NOT NULL,
  purchase_number character varying NOT NULL,
  purchase_date timestamp with time zone DEFAULT now() NOT NULL,
  due_date timestamp with time zone,
  subtotal numeric DEFAULT 0 NOT NULL,
  discount_amount numeric DEFAULT 0 NOT NULL,
  tax_amount numeric DEFAULT 0 NOT NULL,
  total_amount numeric DEFAULT 0 NOT NULL,
  payment_method_id uuid,
  payment_terms integer DEFAULT 0,
  status character varying DEFAULT 'pending'::character varying NOT NULL,
  received_by uuid,
  received_by_name text,
  received_at timestamp with time zone,
  notes text
);

CREATE TABLE ourbit.purchases_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  purchase_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity numeric NOT NULL,
  unit_price numeric NOT NULL,
  discount_amount numeric DEFAULT 0 NOT NULL,
  tax_amount numeric DEFAULT 0 NOT NULL,
  total_amount numeric NOT NULL,
  received_qty numeric DEFAULT 0
);

CREATE TABLE ourbit.receivables (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  customer_id uuid NOT NULL,
  sale_id uuid,
  reference_number character varying NOT NULL,
  transaction_date timestamp with time zone DEFAULT now() NOT NULL,
  due_date timestamp with time zone NOT NULL,
  original_amount numeric NOT NULL,
  paid_amount numeric DEFAULT 0 NOT NULL,
  remaining_amount numeric GENERATED ALWAYS AS IDENTITY,
  status character varying DEFAULT 'pending'::character varying NOT NULL,
  notes text
);

CREATE TABLE ourbit.sales (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  customer_id uuid,
  sale_number character varying NOT NULL,
  sale_date timestamp with time zone DEFAULT now() NOT NULL,
  subtotal numeric DEFAULT 0 NOT NULL,
  discount_amount numeric DEFAULT 0 NOT NULL,
  tax_amount numeric DEFAULT 0 NOT NULL,
  total_amount numeric DEFAULT 0 NOT NULL,
  payment_method_id uuid,
  status character varying DEFAULT 'completed'::character varying NOT NULL,
  notes text,
  cashier_id uuid,
  warehouse_id uuid,
  customer_name character varying,
  customer_phone character varying,
  customer_email character varying,
  sale_source character varying DEFAULT 'offline'::character varying,
  delivery_address text,
  delivery_fee numeric DEFAULT 0,
  estimated_delivery_time timestamp with time zone,
  actual_delivery_time timestamp with time zone,
  tracking_number character varying,
  courier_name character varying,
  currency text DEFAULT 'IDR'::text,
  expires_at timestamp with time zone,
  promo_code text,
  fee_amount numeric DEFAULT 0 NOT NULL
);

CREATE TABLE ourbit.sales_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  sale_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity numeric NOT NULL,
  unit_price numeric NOT NULL,
  discount_amount numeric DEFAULT 0 NOT NULL,
  tax_amount numeric DEFAULT 0 NOT NULL,
  total_amount numeric NOT NULL,
  variant_id uuid,
  name_snapshot text,
  variant_snapshot text,
  weight_grams_snapshot integer DEFAULT 0
);

CREATE TABLE ourbit.shipping_integrations (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  store_id uuid NOT NULL,
  provider text NOT NULL,
  api_key_masked text,
  active boolean DEFAULT false NOT NULL
);

CREATE TABLE ourbit.shipping_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  name text NOT NULL,
  amount numeric DEFAULT 0 NOT NULL,
  region text,
  is_active boolean DEFAULT true NOT NULL
);

CREATE TABLE ourbit.stock_opname_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  session_id uuid NOT NULL,
  product_id uuid NOT NULL,
  expected_qty numeric(12,2) NOT NULL,
  actual_qty numeric(12,2) NOT NULL,
  qty_variance numeric(12,2) GENERATED ALWAYS AS IDENTITY,
  note text
);

CREATE TABLE ourbit.stock_opname_sessions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  started_at timestamp with time zone DEFAULT now(),
  finished_at timestamp with time zone,
  status text DEFAULT '1'::text NOT NULL,
  total_items integer DEFAULT 0,
  items_counted integer DEFAULT 0,
  total_variance_value numeric DEFAULT 0,
  notes text
);

CREATE TABLE ourbit.store_carts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity smallint DEFAULT '1'::smallint NOT NULL
);

CREATE TABLE ourbit.store_payment_methods (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  is_active boolean DEFAULT true NOT NULL
);

CREATE TABLE ourbit.store_platform_settings (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  store_id uuid NOT NULL,
  fee_type text DEFAULT 'percent'::text NOT NULL,
  fee_value numeric DEFAULT 0 NOT NULL,
  tax_rate numeric DEFAULT 0 NOT NULL
);

CREATE TABLE ourbit.suppliers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  name character varying NOT NULL,
  code character varying,
  contact_person character varying,
  email character varying,
  phone character varying,
  address text,
  city_id uuid,
  province_id uuid,
  country_id uuid,
  tax_number character varying,
  bank_name character varying,
  bank_account_number character varying,
  bank_account_name character varying,
  credit_limit numeric DEFAULT 0,
  payment_terms integer DEFAULT 0,
  is_active boolean DEFAULT true NOT NULL,
  notes text
);

CREATE TABLE ourbit.warehouses (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  business_id uuid NOT NULL,
  country_id uuid NOT NULL,
  province_id uuid NOT NULL,
  city_id uuid NOT NULL,
  name character varying NOT NULL,
  address text NOT NULL,
  latitude numeric,
  longitude numeric,
  phone_country_code character varying DEFAULT '+62'::character varying NOT NULL,
  phone_number character varying NOT NULL,
  warehouse_type character varying DEFAULT 'distribution'::character varying NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  notes text,
  is_online_delivery_active boolean DEFAULT false
);

-- Constraints (ourbit)
ALTER TABLE ourbit.analytics_events ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.analytics_events ADD CONSTRAINT analytics_events_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.analytics_events ADD CONSTRAINT analytics_type_check CHECK ((type = ANY (ARRAY['page_view'::text, 'link_click'::text, 'add_to_cart'::text, 'checkout_start'::text, 'purchase'::text])));
ALTER TABLE ourbit.business_online_settings ADD CONSTRAINT bos_subdomain_format_check CHECK ((((subdomain)::text = lower((subdomain)::text)) AND ((subdomain)::text ~ '^[a-z0-9-]+$'::text) AND ((length((subdomain)::text) >= 3) AND (length((subdomain)::text) <= 63))));
ALTER TABLE ourbit.business_online_settings ADD CONSTRAINT business_online_settings_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.business_online_settings ADD CONSTRAINT business_online_settings_default_online_store_id_fkey FOREIGN KEY (default_online_store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.business_online_settings ADD CONSTRAINT business_online_settings_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.business_online_settings ADD CONSTRAINT business_online_settings_subdomain_unique UNIQUE (subdomain);
ALTER TABLE ourbit.cart_items ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES ourbit.carts(id) ON DELETE CASCADE;
ALTER TABLE ourbit.cart_items ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.cart_items ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id);
ALTER TABLE ourbit.cart_items ADD CONSTRAINT cart_items_qty_check CHECK ((qty > 0));
ALTER TABLE ourbit.cart_items ADD CONSTRAINT cart_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES ourbit.product_variants(id);
ALTER TABLE ourbit.carts ADD CONSTRAINT carts_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.carts ADD CONSTRAINT carts_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.carts ADD CONSTRAINT carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES common.users(id);
ALTER TABLE ourbit.categories ADD CONSTRAINT categories_business_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.categories ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.customer_loyalty_memberships ADD CONSTRAINT customer_loyalty_memberships_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES ourbit.customers(id);
ALTER TABLE ourbit.customer_loyalty_memberships ADD CONSTRAINT customer_loyalty_memberships_loyalty_program_id_fkey FOREIGN KEY (loyalty_program_id) REFERENCES ourbit.loyalty_programs(id);
ALTER TABLE ourbit.customer_loyalty_memberships ADD CONSTRAINT customer_loyalty_memberships_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_city_id_fkey FOREIGN KEY (city_id) REFERENCES common.cities(id);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_country_id_fkey FOREIGN KEY (country_id) REFERENCES common.countries(id);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_email_unique UNIQUE (email);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_phone_unique UNIQUE (phone);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.customers ADD CONSTRAINT customers_province_id_fkey FOREIGN KEY (province_id) REFERENCES common.provinces(id);
ALTER TABLE ourbit.discounts ADD CONSTRAINT discounts_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.discounts ADD CONSTRAINT discounts_code_key UNIQUE (code);
ALTER TABLE ourbit.discounts ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.expenses ADD CONSTRAINT expenses_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES common.users(id);
ALTER TABLE ourbit.expenses ADD CONSTRAINT expenses_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES ourbit.payment_methods(id);
ALTER TABLE ourbit.expenses ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.expenses ADD CONSTRAINT expenses_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.financial_transactions ADD CONSTRAINT financial_transactions_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES ourbit.payment_methods(id);
ALTER TABLE ourbit.financial_transactions ADD CONSTRAINT financial_transactions_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.financial_transactions ADD CONSTRAINT financial_transactions_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.inventory_transactions ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.inventory_transactions ADD CONSTRAINT inventory_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.inventory_transactions ADD CONSTRAINT inventory_transactions_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.kyc_documents ADD CONSTRAINT kyc_documents_kyc_submission_id_fkey FOREIGN KEY (kyc_submission_id) REFERENCES ourbit.kyc_submissions(id);
ALTER TABLE ourbit.kyc_documents ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.kyc_submissions ADD CONSTRAINT kyc_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])));
ALTER TABLE ourbit.kyc_submissions ADD CONSTRAINT kyc_submissions_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.kyc_submissions ADD CONSTRAINT kyc_submissions_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.kyc_submissions ADD CONSTRAINT kyc_submissions_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.loyalty_programs ADD CONSTRAINT loyalty_programs_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.loyalty_programs ADD CONSTRAINT loyalty_programs_code_key UNIQUE (code);
ALTER TABLE ourbit.loyalty_programs ADD CONSTRAINT loyalty_programs_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.notifications ADD CONSTRAINT notifications_channel_check CHECK ((channel = ANY (ARRAY['email'::text, 'whatsapp'::text])));
ALTER TABLE ourbit.notifications ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.notifications ADD CONSTRAINT notifications_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES ourbit.sales(id);
ALTER TABLE ourbit.notifications ADD CONSTRAINT notifications_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'sent'::text, 'failed'::text])));
ALTER TABLE ourbit.notifications ADD CONSTRAINT notifications_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.order_shipments ADD CONSTRAINT order_shipments_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.order_shipments ADD CONSTRAINT order_shipments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES ourbit.sales(id);
ALTER TABLE ourbit.payables ADD CONSTRAINT payables_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.payables ADD CONSTRAINT payables_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES ourbit.purchases(id);
ALTER TABLE ourbit.payables ADD CONSTRAINT payables_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.payables ADD CONSTRAINT payables_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES ourbit.suppliers(id);
ALTER TABLE ourbit.payment_methods ADD CONSTRAINT payment_methods_payment_type_id_fkey FOREIGN KEY (payment_type_id) REFERENCES ourbit.payment_types(id);
ALTER TABLE ourbit.payment_methods ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.payment_types ADD CONSTRAINT payment_types_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.payments ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.payments ADD CONSTRAINT payments_provider_ref_unique UNIQUE (provider_ref);
ALTER TABLE ourbit.payments ADD CONSTRAINT payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES ourbit.sales(id);
ALTER TABLE ourbit.payments ADD CONSTRAINT payments_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'settlement'::text, 'expire'::text, 'deny'::text, 'cancel'::text])));
ALTER TABLE ourbit.product_images ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.product_images ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id);
ALTER TABLE ourbit.product_variants ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.product_variants ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id);
ALTER TABLE ourbit.products ADD CONSTRAINT products_availability_status_check CHECK ((availability_status = ANY (ARRAY['available'::text, 'out_of_stock'::text, 'preorder'::text])));
ALTER TABLE ourbit.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES ourbit.categories(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.products ADD CONSTRAINT products_code_key UNIQUE (code);
ALTER TABLE ourbit.products ADD CONSTRAINT products_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.products ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.profit_loss_items ADD CONSTRAINT profit_loss_items_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.profit_loss_items ADD CONSTRAINT profit_loss_items_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.purchases ADD CONSTRAINT purchases_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES ourbit.payment_methods(id);
ALTER TABLE ourbit.purchases ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.purchases ADD CONSTRAINT purchases_received_by_fkey FOREIGN KEY (received_by) REFERENCES common.users(id);
ALTER TABLE ourbit.purchases ADD CONSTRAINT purchases_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.purchases ADD CONSTRAINT purchases_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES ourbit.suppliers(id);
ALTER TABLE ourbit.purchases_items ADD CONSTRAINT purchases_items_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.purchases_items ADD CONSTRAINT purchases_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id);
ALTER TABLE ourbit.purchases_items ADD CONSTRAINT purchases_items_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES ourbit.purchases(id);
ALTER TABLE ourbit.receivables ADD CONSTRAINT receivables_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES ourbit.customers(id);
ALTER TABLE ourbit.receivables ADD CONSTRAINT receivables_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.receivables ADD CONSTRAINT receivables_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES ourbit.sales(id);
ALTER TABLE ourbit.receivables ADD CONSTRAINT receivables_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES common.users(id);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES ourbit.customers(id);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES ourbit.payment_methods(id);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_sale_number_unique UNIQUE (sale_number);
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_status_check_full CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'paid'::character varying, 'processing'::character varying, 'fulfilled'::character varying, 'cancelled'::character varying, 'refunded'::character varying, 'completed'::character varying])::text[])));
ALTER TABLE ourbit.sales ADD CONSTRAINT sales_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.sales_items ADD CONSTRAINT sales_items_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.sales_items ADD CONSTRAINT sales_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id);
ALTER TABLE ourbit.sales_items ADD CONSTRAINT sales_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES ourbit.sales(id);
ALTER TABLE ourbit.sales_items ADD CONSTRAINT sales_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES ourbit.product_variants(id);
ALTER TABLE ourbit.shipping_integrations ADD CONSTRAINT shipping_integrations_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.shipping_integrations ADD CONSTRAINT shipping_integrations_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.shipping_rates ADD CONSTRAINT shipping_rates_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.shipping_rates ADD CONSTRAINT shipping_rates_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.stock_opname_items ADD CONSTRAINT stock_opname_items_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.stock_opname_items ADD CONSTRAINT stock_opname_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.stock_opname_items ADD CONSTRAINT stock_opname_items_session_id_fkey FOREIGN KEY (session_id) REFERENCES ourbit.stock_opname_sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.stock_opname_sessions ADD CONSTRAINT stock_opname_sessions_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.stock_opname_sessions ADD CONSTRAINT stock_opname_sessions_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.store_carts ADD CONSTRAINT store_carts_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.store_carts ADD CONSTRAINT store_carts_product_id_fkey FOREIGN KEY (product_id) REFERENCES ourbit.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.store_carts ADD CONSTRAINT store_carts_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ourbit.store_payment_methods ADD CONSTRAINT store_payment_methods_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES ourbit.payment_methods(id);
ALTER TABLE ourbit.store_payment_methods ADD CONSTRAINT store_payment_methods_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.store_payment_methods ADD CONSTRAINT store_payment_methods_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.store_platform_settings ADD CONSTRAINT store_platform_fee_type_check CHECK ((fee_type = ANY (ARRAY['percent'::text, 'amount'::text])));
ALTER TABLE ourbit.store_platform_settings ADD CONSTRAINT store_platform_settings_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.store_platform_settings ADD CONSTRAINT store_platform_settings_store_id_fkey FOREIGN KEY (store_id) REFERENCES common.stores(id);
ALTER TABLE ourbit.store_platform_settings ADD CONSTRAINT store_platform_settings_store_id_key UNIQUE (store_id);
ALTER TABLE ourbit.suppliers ADD CONSTRAINT suppliers_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.suppliers ADD CONSTRAINT suppliers_city_id_fkey FOREIGN KEY (city_id) REFERENCES common.cities(id);
ALTER TABLE ourbit.suppliers ADD CONSTRAINT suppliers_country_id_fkey FOREIGN KEY (country_id) REFERENCES common.countries(id);
ALTER TABLE ourbit.suppliers ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.suppliers ADD CONSTRAINT suppliers_province_id_fkey FOREIGN KEY (province_id) REFERENCES common.provinces(id);

-- ========================================
-- ourbit.purchases: denormalized name sync
-- ========================================
CREATE OR REPLACE FUNCTION ourbit.fn_sync_purchases_received_by_name()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.received_by IS NOT NULL THEN
    SELECT u.name INTO NEW.received_by_name FROM common.users u WHERE u.id = NEW.received_by;
  ELSE
    NEW.received_by_name := NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_purchases_received_by_name_ins ON ourbit.purchases;
CREATE TRIGGER trg_sync_purchases_received_by_name_ins
BEFORE INSERT ON ourbit.purchases
FOR EACH ROW
EXECUTE FUNCTION ourbit.fn_sync_purchases_received_by_name();

DROP TRIGGER IF EXISTS trg_sync_purchases_received_by_name_upd ON ourbit.purchases;
CREATE TRIGGER trg_sync_purchases_received_by_name_upd
BEFORE UPDATE OF received_by ON ourbit.purchases
FOR EACH ROW
EXECUTE FUNCTION ourbit.fn_sync_purchases_received_by_name();
ALTER TABLE ourbit.warehouses ADD CONSTRAINT warehouses_business_id_fkey FOREIGN KEY (business_id) REFERENCES common.businesses(id);
ALTER TABLE ourbit.warehouses ADD CONSTRAINT warehouses_city_id_fkey FOREIGN KEY (city_id) REFERENCES common.cities(id);
ALTER TABLE ourbit.warehouses ADD CONSTRAINT warehouses_country_id_fkey FOREIGN KEY (country_id) REFERENCES common.countries(id);
ALTER TABLE ourbit.warehouses ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);
ALTER TABLE ourbit.warehouses ADD CONSTRAINT warehouses_province_id_fkey FOREIGN KEY (province_id) REFERENCES common.provinces(id);

-- Indexes (ourbit)
CREATE INDEX idx_analytics_store_session_created_at ON ourbit.analytics_events USING btree (store_id, session_id, created_at);
CREATE INDEX idx_analytics_store_type ON ourbit.analytics_events USING btree (store_id, type);
CREATE INDEX idx_bos_business_id ON ourbit.business_online_settings USING btree (business_id);
CREATE INDEX idx_bos_default_store ON ourbit.business_online_settings USING btree (default_online_store_id);
CREATE INDEX idx_carts_store_session ON ourbit.carts USING btree (store_id, session_id);
CREATE INDEX idx_categories_business ON ourbit.categories USING btree (business_id);
CREATE INDEX idx_customer_loyalty_memberships_customer_id ON ourbit.customer_loyalty_memberships USING btree (customer_id);
CREATE INDEX idx_customer_loyalty_memberships_is_active ON ourbit.customer_loyalty_memberships USING btree (is_active);
CREATE INDEX idx_customer_loyalty_memberships_loyalty_program_id ON ourbit.customer_loyalty_memberships USING btree (loyalty_program_id);
CREATE INDEX idx_discounts_business_id ON ourbit.discounts USING btree (business_id);
CREATE INDEX idx_discounts_end_date ON ourbit.discounts USING btree (end_date);
CREATE INDEX idx_discounts_is_active ON ourbit.discounts USING btree (is_active);
CREATE INDEX idx_expenses_category ON ourbit.expenses USING btree (category);
CREATE INDEX idx_expenses_expense_date ON ourbit.expenses USING btree (expense_date);
CREATE INDEX idx_expenses_is_paid ON ourbit.expenses USING btree (is_paid);
CREATE INDEX idx_expenses_store_id ON ourbit.expenses USING btree (store_id);
CREATE INDEX idx_inventory_transactions_created_at ON ourbit.inventory_transactions USING btree (created_at DESC);
CREATE INDEX idx_inventory_transactions_product_store ON ourbit.inventory_transactions USING btree (product_id, store_id);
CREATE INDEX idx_inventory_transactions_type ON ourbit.inventory_transactions USING btree (type);
CREATE INDEX idx_loyalty_programs_business_id ON ourbit.loyalty_programs USING btree (business_id);
CREATE INDEX idx_loyalty_programs_is_active ON ourbit.loyalty_programs USING btree (is_active);
CREATE INDEX idx_notifications_store_status ON ourbit.notifications USING btree (store_id, status);
CREATE INDEX idx_payments_sale_id ON ourbit.payments USING btree (sale_id);
CREATE INDEX idx_product_images_product_id ON ourbit.product_images USING btree (product_id);
CREATE INDEX idx_product_variants_product_id ON ourbit.product_variants USING btree (product_id);
CREATE INDEX idx_products_active ON ourbit.products USING btree (is_active) WHERE (is_active = true);
CREATE INDEX idx_products_availability ON ourbit.products USING btree (availability_status);
CREATE INDEX idx_products_stock_status ON ourbit.products USING btree (store_id) WHERE (stock <= min_stock);
CREATE INDEX idx_products_store_active ON ourbit.products USING btree (store_id, is_active);
CREATE INDEX idx_products_store_category ON ourbit.products USING btree (store_id, category_id);
CREATE INDEX idx_sales_items_sale ON ourbit.sales_items USING btree (sale_id);
CREATE INDEX idx_sales_status_date ON ourbit.sales USING btree (status, sale_date);
CREATE INDEX idx_shipping_rates_store_active ON ourbit.shipping_rates USING btree (store_id, is_active);
CREATE INDEX idx_stock_opname_items_session ON ourbit.stock_opname_items USING btree (session_id);
CREATE INDEX idx_stock_opname_sessions_store_status ON ourbit.stock_opname_sessions USING btree (store_id, status);
CREATE UNIQUE INDEX business_online_settings_subdomain_unique ON ourbit.business_online_settings USING btree (subdomain);
CREATE UNIQUE INDEX customers_email_unique ON ourbit.customers USING btree (email);
CREATE UNIQUE INDEX customers_phone_unique ON ourbit.customers USING btree (phone);
CREATE UNIQUE INDEX discounts_code_key ON ourbit.discounts USING btree (code);
CREATE UNIQUE INDEX idx_bos_subdomain ON ourbit.business_online_settings USING btree (subdomain);
CREATE UNIQUE INDEX loyalty_programs_code_key ON ourbit.loyalty_programs USING btree (code);
CREATE UNIQUE INDEX payments_provider_ref_unique ON ourbit.payments USING btree (provider_ref);
CREATE UNIQUE INDEX products_code_key ON ourbit.products USING btree (code);
CREATE UNIQUE INDEX sales_sale_number_unique ON ourbit.sales USING btree (sale_number);
CREATE UNIQUE INDEX store_platform_settings_store_id_key ON ourbit.store_platform_settings USING btree (store_id);
CREATE UNIQUE INDEX uniq_cart_items_cart_product_variant ON ourbit.cart_items USING btree (cart_id, product_id, COALESCE(variant_id, '00000000-0000-0000-0000-000000000000'::uuid));


-- ========================================
-- DATA SNAPSHOT: common.options
-- Fetched via Supabase MCP on 2025-08-16
-- Total rows: 60
-- Each line below is a JSON object representing one row
-- ========================================
-- {"id":"0029ac0a-92d1-4377-9ca7-60e4fb6b36ba","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"6","value":"Japanese Yen (¥)"}
-- {"id":"1aa5fd15-daa4-4314-8c00-68ea5867d7a5","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"1","value":"Pembelian"}
-- {"id":"1e8f2ddf-052b-4f16-8ac3-c02de2be6884","created_at":"2025-05-16 03:34:14.791212+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"online_store_mode","name":"Online Store Mode","key":"1","value":"Catalog"}
-- {"id":"21c35d0c-c6a2-45bc-90fb-f93d5e394b8e","created_at":"2025-05-21 08:38:17.172882+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_valuation_method","name":"Inventory Valuation Method","key":"2","value":"FIFO"}
-- {"id":"26339113-453d-4195-b8c7-c5446d042e1d","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"13","value":"Jasa (laundry, cleaning...)"}
-- {"id":"2da46dfb-a304-4f48-9036-4f4ee0d3b957","created_at":"2025-05-16 03:34:14.791212+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"online_store_mode","name":"Online Store Mode","key":"3","value":"Disabled"}
-- {"id":"32e3a66b-c7c5-412d-8dcf-2158e3dd1475","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"4","value":"Transfer"}
-- {"id":"34b7dbed-37c4-4bcc-ac72-e00b85424f00","created_at":"2025-07-20 11:10:40.286552+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_status","name":"Stock Opname Status","key":"4","value":"Dibatalkan"}
-- {"id":"34f0ae5f-0bc8-4f4f-9f8f-de41afd18f8a","created_at":"2025-05-15 17:33:14.507196+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_session_status","name":"Stock Opname Session Status","key":"1","value":"Open"}
-- {"id":"362d4a90-48bf-4572-abe2-f849e376af3c","created_at":"2025-05-15 17:29:57.542706+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"5","value":"Adjustment"}
-- {"id":"39871ba8-f80d-452d-8182-d2edb4344fef","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"7","value":"Retur"}
-- {"id":"39b3998f-ec74-498f-8955-fea4ae03049f","created_at":"2025-05-21 08:36:02.923815+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_age","name":"Business Age","key":"5","value":"Lebih dari 10 tahun"}
-- {"id":"474e428a-d921-4098-b79e-95573c21ee4a","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"5","value":"Produksi"}
-- {"id":"559bb01d-35db-4a3b-9137-2df3be5cf178","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"11","value":"Souvenir & Gift"}
-- {"id":"59a72f9e-0898-4b17-b73b-445bf3a7dc9e","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"6","value":"Kerusakan"}
-- {"id":"5b6d19bd-e195-455c-9e80-9736555856cd","created_at":"2025-05-15 17:29:57.542706+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"4","value":"Transfer Out"}
-- {"id":"5ed9359a-85b1-43c3-ae49-77782e63486b","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"3","value":"Penyesuaian"}
-- {"id":"5faddbcc-7b91-4af4-aee7-7add06d0322c","created_at":"2025-05-15 16:34:48.327771+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"product_type","name":"Product Type","key":"2","value":"Jasa"}
-- {"id":"637dff40-85db-4004-8c16-c971095e7f6e","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"1","value":"Kelontong / Grocery"}
-- {"id":"6a12535d-fcef-40f8-924a-88496282b667","created_at":"2025-05-15 17:33:14.507196+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_session_status","name":"Stock Opname Session Status","key":"3","value":"Adjusted"}
-- {"id":"6a7af10c-d35c-44d1-8c15-173c44f89158","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"12","value":"Olahraga & Outdoor"}
-- {"id":"6d83a0bd-4966-4c0d-946e-740c4167dd82","created_at":"2025-05-15 17:29:57.542706+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"2","value":"Sale"}
-- {"id":"712cd03d-fad1-45e5-8ecd-ddd36572ed83","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"1","value":"Indonesian Rupiah (Rp)"}
-- {"id":"76a6d54f-6ea7-48d7-abe5-9c055caa6613","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"2","value":"Elektronik"}
-- {"id":"788b88c7-66ab-451c-a64d-d5eeeaf56d0f","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"5","value":"Kecantikan & Perawatan"}
-- {"id":"78cbac4d-7955-40fe-9c96-8ef248c15f66","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"10","value":"Buku & Alat Tulis"}
-- {"id":"7dd098c8-1530-43fe-84a6-30e181a4f302","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"3","value":"Euro (€)"}
-- {"id":"800254f8-d0ea-4ca2-88c8-5f53e2b78f31","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"6","value":"Pet Shop"}
-- {"id":"8a334bc2-c12c-47bd-a249-db39d91844fc","created_at":"2025-05-21 08:38:17.172882+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_valuation_method","name":"Inventory Valuation Method","key":"4","value":"Average"}
-- {"id":"8ab1b239-7b6d-43c1-b047-924408e52e0d","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"9","value":"Perlengkapan Rumah Tangga"}
-- {"id":"8d7a200d-f9fc-428b-817e-ea857a5182dc","created_at":"2025-05-15 16:33:59.211668+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"product_type","name":"Product Type","key":"1","value":"Barang"}
-- {"id":"98c34c29-b3b1-41d1-b6f2-408057c8bfb4","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"7","value":"British Pound Sterling (£)"}
-- {"id":"9d4c8a99-601e-4384-949e-bc6ad8352b9f","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"4","value":"Makanan & Minuman"}
-- {"id":"a16e0369-8808-4a5c-8be9-eab8aea0ae51","created_at":"2025-05-16 03:34:14.791212+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_tracking_mode","name":"Stock Tracking Mode","key":"2","value":"Booking"}
-- {"id":"aa2a1b16-5dfe-4d9c-aff4-12cdc55a5049","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"9999","value":"Lain-lain"}
-- {"id":"b17320d9-9f6e-407d-8438-3563b5dd9443","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"8","value":"Otomotif & Bengkel"}
-- {"id":"b71511bd-2f56-4bdf-a4f8-f1b62b7fe653","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"14","value":"Optik"}
-- {"id":"be20a01e-42c3-47f1-8298-3609aec7964d","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"2","value":"Penjualan"}
-- {"id":"be777f4a-99c2-4297-9682-7213b530ddc2","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"4","value":"Singapore Dollar (S$)"}
-- {"id":"be96a5d2-1d47-4834-9af3-22df2b6fab0f","created_at":"2025-05-15 17:29:57.542706+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"3","value":"Transfer In"}
-- {"id":"c084b3e6-c35a-4a48-956c-48496c6a7cd3","created_at":"2025-05-21 08:36:02.923815+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_age","name":"Business Age","key":"3","value":"3 – 5 tahun"}
-- {"id":"c313a2b6-f85b-405c-8562-1eae11e95cc6","created_at":"2025-05-15 17:33:14.507196+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_session_status","name":"Stock Opname Session Status","key":"2","value":"Counted"}
-- {"id":"c5f611dd-b6c0-4bd5-9000-698cdca7c199","created_at":"2025-05-16 03:34:14.791212+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_tracking_mode","name":"Stock Tracking Mode","key":"1","value":"Physical"}
-- {"id":"cc39c4dc-660f-41b3-bb70-0eaec8d9a3e3","created_at":"2025-05-16 03:34:14.791212+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"online_store_mode","name":"Online Store Mode","key":"2","value":"Catalog & Order"}
-- {"id":"cde7ba08-fe04-407d-9e22-51e32cab4a16","created_at":"2025-05-15 17:33:14.507196+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_session_status","name":"Stock Opname Session Status","key":"4","value":"Closed"}
-- {"id":"cefc4aa9-0d31-4f44-b557-869032d6a8d5","created_at":"2025-05-21 08:36:02.923815+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_age","name":"Business Age","key":"2","value":"1 – 3 tahun"}
-- {"id":"d1d29536-138e-41a6-9590-f24847a52931","created_at":"2025-05-21 08:36:02.923815+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_age","name":"Business Age","key":"4","value":"5 – 10 tahun"}
-- {"id":"de41f14e-bb44-458f-83ba-21a0ccb23d7a","created_at":"2025-05-21 08:38:17.172882+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_valuation_method","name":"Inventory Valuation Method","key":"1","value":"Default"}
-- {"id":"df7af1f8-d9b4-45c9-827b-da65676dc893","created_at":"2025-05-15 16:35:07.116252+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"product_type","name":"Product Type","key":"3","value":"Kelas/Jadwal"}
-- {"id":"dfa19504-fff1-4bcc-b7a4-707b594e9f6f","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"5","value":"Malaysian Ringgit (RM)"}
-- {"id":"e4d86e82-39d9-4039-9440-37a37d24f8b3","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"3","value":"Fashion / Pakaian & Aksesoris"}
-- {"id":"e54055f4-e5f8-4a65-96ae-708759bc1ce9","created_at":"2025-05-21 08:36:02.923815+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_age","name":"Business Age","key":"1","value":"Kurang dari 1 tahun"}
-- {"id":"e54e2e96-69ce-4e12-ae6d-de0d6dbfadd2","created_at":"2025-05-21 08:38:17.172882+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_valuation_method","name":"Inventory Valuation Method","key":"3","value":"LIFO"}
-- {"id":"e85ca74e-ef15-48a2-99da-4d099ffbd92f","created_at":"2025-05-21 07:49:23.889324+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"business_field","name":"Business Field","key":"7","value":"Kesehatan & Farmasi"}
-- {"id":"ea7e80bd-e00c-4c2d-884d-9f1c91fe2316","created_at":"2025-05-21 08:41:06.315063+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"currency","name":"Kurs Mata Uang","key":"2","value":"US Dollar ($)"}
-- {"id":"ea9e96f6-3eba-4ac9-9e23-2bcec60fc983","created_at":"2025-05-15 17:29:57.542706+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"1","value":"Purchase"}
-- {"id":"eabdf506-251a-4cd9-8929-8177da0f6232","created_at":"2025-07-20 11:10:40.286552+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_status","name":"Stock Opname Status","key":"3","value":"Selesai"}
-- {"id":"ebd9a45c-3084-4bd3-986c-c24ff9ee1fd3","created_at":"2025-07-20 11:10:40.286552+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_status","name":"Stock Opname Status","key":"1","value":"Draft"}
-- {"id":"f3c7da31-1deb-448b-8d48-db97b7f37bd8","created_at":"2025-07-20 11:10:08.84082+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"inventory_transaction_type","name":"Inventory Transaction Type","key":"8","value":"Stock Opname"}
-- {"id":"fe1655e5-b685-4b8f-a384-b2a074f8a5e4","created_at":"2025-07-20 11:10:40.286552+00","created_by":"00000000-0000-0000-0000-000000000000","updated_at":null,"updated_by":null,"deleted_at":null,"deleted_by":null,"type":"stock_opname_status","name":"Stock Opname Status","key":"2","value":"Sedang Berlangsung"}

