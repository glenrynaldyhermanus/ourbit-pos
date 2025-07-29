-- ========================================
-- TABEL TAMBAHAN UNTUK MANAGEMENT SYSTEM
-- ========================================

-- discounts (diskon dan promo)
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
    type VARCHAR NOT NULL DEFAULT 'percentage', -- 'percentage', 'fixed', 'bogo'
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

-- expenses (biaya operasional)
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID,
    store_id UUID NOT NULL,
    category VARCHAR NOT NULL, -- 'operational', 'marketing', 'utilities', 'salary', 'rent', 'other'
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

-- loyalty_programs (program loyalitas)
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

-- customer_loyalty_memberships (keanggotaan customer di program loyalitas)
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

-- Enable RLS on new tables
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