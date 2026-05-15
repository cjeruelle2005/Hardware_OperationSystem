-- ================================================================
-- HardwareOS - Multi-Tenant Database Schema
-- PostgreSQL for Supabase
-- ================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
-- 1. TENANTS TABLE (Multi-Tenant Core)
-- ================================================================
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL, -- For subdomain/URL
    business_type VARCHAR(50), -- 'hardware', 'construction', 'warehouse', etc.
    
    -- Branding
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#FF6B35', -- Orange default
    secondary_color VARCHAR(7) DEFAULT '#2D3748', -- Dark gray
    
    -- Contact Info
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    tin VARCHAR(20), -- Tax Identification Number (Philippines)
    
    -- Settings
    currency VARCHAR(3) DEFAULT 'PHP',
    timezone VARCHAR(50) DEFAULT 'Asia/Manila',
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tenants_slug ON tenants(slug);
CREATE INDEX idx_tenants_active ON tenants(is_active);

-- ================================================================
-- 2. USERS TABLE (Authentication)
-- ================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Auth (managed by Supabase Auth, but we store reference)
    auth_id UUID UNIQUE NOT NULL, -- Links to Supabase Auth users
    
    -- Profile
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    
    -- Role
    role VARCHAR(50) NOT NULL, -- 'owner', 'manager', 'sales', 'warehouse'
    
    -- Permissions (JSON for flexibility)
    permissions JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_auth ON users(auth_id);

-- ================================================================
-- 3. INVENTORY CATEGORIES
-- ================================================================
CREATE TABLE inventory_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES inventory_categories(id) ON DELETE SET NULL,
    
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    description TEXT,
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_categories_tenant ON inventory_categories(tenant_id);
CREATE INDEX idx_categories_parent ON inventory_categories(parent_id);

-- ================================================================
-- 4. PRODUCTS (Core Inventory Items)
-- ================================================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES inventory_categories(id) ON DELETE SET NULL,
    
    -- Identification
    sku VARCHAR(100) NOT NULL, -- Stock Keeping Unit
    barcode VARCHAR(100),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Pricing
    cost_price DECIMAL(12,2) DEFAULT 0,
    selling_price DECIMAL(12,2) DEFAULT 0,
    wholesale_price DECIMAL(12,2),
    retail_price DECIMAL(12,2),
    
    -- Stock Management
    current_stock INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 10, -- Reorder point
    max_stock_level INTEGER,
    unit_of_measure VARCHAR(20) DEFAULT 'piece', -- piece, box, kg, etc.
    
    -- Physical Attributes
    weight DECIMAL(10,3),
    dimensions JSONB, -- {length, width, height}
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_low_stock BOOLEAN DEFAULT false,
    
    -- Metadata
    images JSONB DEFAULT '[]',
    tags TEXT[],
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_products_sku_tenant ON products(tenant_id, sku);
CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_low_stock ON products(tenant_id, is_low_stock) WHERE is_low_stock = true;

-- ================================================================
-- 5. WAREHOUSES / LOCATIONS
-- ================================================================
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    address TEXT,
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_warehouses_tenant ON warehouses(tenant_id);

-- Warehouse Locations/Bins (sub-locations within warehouse)
CREATE TABLE warehouse_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL, -- e.g., "A-01-02" (Aisle-Shelf-Bin)
    zone VARCHAR(50),
    aisle VARCHAR(50),
    shelf VARCHAR(50),
    bin VARCHAR(50),
    
    capacity INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_locations_warehouse ON warehouse_locations(warehouse_id);
CREATE INDEX idx_locations_tenant ON warehouse_locations(tenant_id);

-- ================================================================
-- 6. STOCK LEVELS (Per Product Per Location)
-- ================================================================
CREATE TABLE stock_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL,
    location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    
    quantity INTEGER DEFAULT 0,
    reserved_quantity INTEGER DEFAULT 0,
    available_quantity INTEGER GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    
    last_counted_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(product_id, warehouse_id, location_id)
);

CREATE INDEX idx_stock_product ON stock_levels(product_id);
CREATE INDEX idx_stock_warehouse ON stock_levels(warehouse_id);
CREATE INDEX idx_stock_tenant ON stock_levels(tenant_id);

-- ================================================================
-- 7. STOCK MOVEMENTS (Audit Trail)
-- ================================================================
CREATE TYPE movement_type AS ENUM (
    'RECEIVE',      -- Stock received from supplier
    'SALE',         -- Stock sold
    'TRANSFER_IN',  -- Transfer from another warehouse
    'TRANSFER_OUT', -- Transfer to another warehouse
    'ADJUSTMENT',   -- Manual adjustment
    'RETURN',       -- Customer return
    'DAMAGE',       -- Damaged/lost stock
    'AUDIT'         -- Stock count adjustment
);

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    movement_type movement_type NOT NULL,
    quantity INTEGER NOT NULL,
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    
    -- References
    warehouse_id UUID REFERENCES warehouses(id),
    location_id UUID REFERENCES warehouse_locations(id),
    
    -- Related Documents
    reference_type VARCHAR(50), -- 'PO', 'SO', 'TRANSFER', 'ADJUSTMENT'
    reference_id UUID,
    
    -- Actor
    performed_by UUID REFERENCES users(id),
    
    -- Notes
    notes TEXT,
    reason VARCHAR(255),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_movements_product ON stock_movements(product_id);
CREATE INDEX idx_movements_tenant ON stock_movements(tenant_id);
CREATE INDEX idx_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_movements_date ON stock_movements(created_at DESC);
CREATE INDEX idx_movements_reference ON stock_movements(reference_type, reference_id);

-- ================================================================
-- 8. SUPPLIERS (Procurement)
-- ================================================================
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Company Info
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    
    -- Contact Details
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    fax VARCHAR(20),
    
    -- Address
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(10),
    country VARCHAR(100) DEFAULT 'Philippines',
    
    -- Business Details
    tin VARCHAR(20),
    business_permit_no VARCHAR(50),
    
    -- Payment Terms
    payment_terms_days INTEGER DEFAULT 0,
    credit_limit DECIMAL(12,2),
    
    -- Rating
    rating DECIMAL(3,2), -- 0.00 to 5.00
    is_preferred BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_suppliers_tenant ON suppliers(tenant_id);
CREATE INDEX idx_suppliers_active ON suppliers(is_active);

-- ================================================================
-- 9. PURCHASE ORDERS (Procurement)
-- ================================================================
CREATE TYPE po_status AS ENUM (
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'SENT',
    'PARTIALLY_RECEIVED',
    'COMPLETED',
    'CANCELLED'
);

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    
    po_number VARCHAR(50) NOT NULL,
    
    -- Dates
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    
    -- Financials
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    
    -- Status
    status po_status DEFAULT 'DRAFT',
    
    -- Shipping
    delivery_address TEXT,
    shipping_notes TEXT,
    
    -- Approval
    requested_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_po_number_tenant ON purchase_orders(tenant_id, po_number);
CREATE INDEX idx_po_tenant ON purchase_orders(tenant_id);
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_status ON purchase_orders(status);

-- Purchase Order Items
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    quantity_ordered INTEGER NOT NULL,
    quantity_received INTEGER DEFAULT 0,
    
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_po_items_po ON purchase_order_items(po_id);
CREATE INDEX idx_po_items_product ON purchase_order_items(product_id);

-- ================================================================
-- 10. CUSTOMERS (Sales & Quotations)
-- ================================================================
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Type
    customer_type VARCHAR(20) DEFAULT 'retail', -- 'retail', 'wholesale', 'contractor'
    
    -- Personal/Business Info
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company_name VARCHAR(255),
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    
    -- Address
    billing_address TEXT,
    shipping_address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    
    -- Credit
    credit_limit DECIMAL(12,2),
    payment_terms_days INTEGER DEFAULT 0,
    
    -- TIN for BIR requirements (Philippines)
    tin VARCHAR(20),
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_customers_tenant ON customers(tenant_id);
CREATE INDEX idx_customers_type ON customers(customer_type);

-- ================================================================
-- 11. QUOTATIONS
-- ================================================================
CREATE TYPE quotation_status AS ENUM (
    'DRAFT',
    'SENT',
    'VIEWED',
    'ACCEPTED',
    'REJECTED',
    'EXPIRED',
    'CONVERTED_TO_invoice'
);

CREATE TABLE quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    
    quotation_number VARCHAR(50) NOT NULL,
    
    -- Dates
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_until DATE,
    
    -- Financials
    subtotal DECIMAL(12,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0,
    
    -- Status
    status quotation_status DEFAULT 'DRAFT',
    
    -- Notes
    terms_and_conditions TEXT,
    notes TEXT,
    
    -- Tracking
    sent_at TIMESTAMPTZ,
    viewed_at TIMESTAMPTZ,
    
    created_by UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_quotation_number_tenant ON quotations(tenant_id, quotation_number);
CREATE INDEX idx_quotations_tenant ON quotations(tenant_id);
CREATE INDEX idx_quotations_customer ON quotations(customer_id);
CREATE INDEX idx_quotations_status ON quotations(status);

-- Quotation Items
CREATE TABLE quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    subtotal DECIMAL(12,2) NOT NULL,
    
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_quotation_items_quotation ON quotation_items(quotation_id);
CREATE INDEX idx_quotation_items_product ON quotation_items(product_id);

-- ================================================================
-- 12. ROW LEVEL SECURITY (Multi-Tenant Isolation)
-- ================================================================

-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotation_items ENABLE ROW LEVEL SECURITY;

-- Create a function to get current user's tenant_id
CREATE OR REPLACE FUNCTION get_current_tenant_id()
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policy: Users can only access data from their own tenant
-- Note: In Supabase, you'll typically use JWT claims instead
-- This is a template - adjust based on your Supabase auth setup

-- Example policy for products table
CREATE POLICY tenant_isolation_products ON products
    FOR ALL
    USING (tenant_id = get_current_tenant_id());

-- Repeat similar policies for all tables...
-- (For brevity, showing one example. Apply to all tenant-scoped tables)

-- ================================================================
-- 13. TRIGGERS FOR AUTOMATIC UPDATES
-- ================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
CREATE TRIGGER update_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update low_stock flag
CREATE OR REPLACE FUNCTION check_low_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.current_stock <= NEW.min_stock_level THEN
        NEW.is_low_stock = true;
    ELSE
        NEW.is_low_stock = false;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_check_low_stock
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION check_low_stock();

-- ================================================================
-- 14. VIEWS FOR ANALYTICS
-- ================================================================

-- Low Stock Products View
CREATE VIEW v_low_stock_products AS
SELECT 
    p.id,
    p.sku,
    p.name,
    p.current_stock,
    p.min_stock_level,
    p.category_id,
    t.name as tenant_name
FROM products p
JOIN tenants t ON p.tenant_id = t.id
WHERE p.current_stock <= p.min_stock_level
  AND p.is_active = true;

-- Inventory Value by Category
CREATE VIEW v_inventory_value_by_category AS
SELECT 
    c.name as category_name,
    COUNT(p.id) as product_count,
    SUM(p.current_stock * p.cost_price) as total_value
FROM products p
LEFT JOIN inventory_categories c ON p.category_id = c.id
WHERE p.is_active = true
GROUP BY c.id, c.name;

-- Stock Movement Summary (Last 30 Days)
CREATE VIEW v_stock_movement_summary AS
SELECT 
    product_id,
    movement_type,
    COUNT(*) as movement_count,
    SUM(quantity) as total_quantity,
    DATE_TRUNC('day', created_at) as movement_date
FROM stock_movements
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY product_id, movement_type, DATE_TRUNC('day', created_at);

-- ================================================================
-- 15. INITIAL DATA (Optional Seed Data)
-- ================================================================

-- You can add seed data here for testing
-- INSERT INTO tenants (name, slug, business_type) VALUES 
--     ('Sample Hardware Store', 'sample-hardware', 'hardware');

-- ================================================================
-- END OF SCHEMA
-- ================================================================
