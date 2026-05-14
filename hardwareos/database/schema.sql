-- ==================================================
-- HardwareOS - Multi-Tenant PostgreSQL Schema
-- ==================================================
-- Designed for: Supabase (PostgreSQL 15+)
-- Architecture: Row-Level Security (RLS) for tenant isolation
-- Purpose: Production-ready SaaS database schema
-- ==================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==================================================
-- CORE TABLES
-- ==================================================

-- 1. TENANTS TABLE
-- Each row represents one business/organization
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL, -- For subdomain routing
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'trial')),
    
    -- Branding & Customization
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#FF6B35', -- Industrial orange
    secondary_color VARCHAR(7) DEFAULT '#2C2C2C', -- Dark gray
    
    -- Business Information
    business_type VARCHAR(50), -- hardware_store, construction_supplier, warehouse, distributor
    tax_id VARCHAR(50),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    
    -- Receipt/Invoice Customization
    receipt_footer TEXT,
    invoice_terms TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ -- Soft delete support
);

CREATE INDEX idx_tenants_slug ON tenants(slug);
CREATE INDEX idx_tenants_status ON tenants(status);

-- 2. USERS TABLE
-- Extends Supabase auth.users with application-specific data
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);

-- 3. TENANT_USERS TABLE (Junction Table)
-- Maps users to tenants with roles
CREATE TABLE tenant_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('owner', 'manager', 'sales', 'warehouse', 'viewer')),
    
    -- Permissions override (optional JSON for granular permissions)
    permissions JSONB DEFAULT '{}',
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
    invited_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(tenant_id, user_id)
);

CREATE INDEX idx_tenant_users_tenant ON tenant_users(tenant_id);
CREATE INDEX idx_tenant_users_user ON tenant_users(user_id);
CREATE INDEX idx_tenant_users_role ON tenant_users(role);

-- ==================================================
-- INVENTORY MODULE
-- ==================================================

-- 4. CATEGORIES TABLE
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    UNIQUE(tenant_id, slug)
);

CREATE INDEX idx_categories_tenant ON categories(tenant_id);
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- 5. PRODUCTS TABLE
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    
    -- Product Identification
    sku VARCHAR(100) NOT NULL, -- Stock Keeping Unit
    barcode VARCHAR(100), -- UPC/EAN/ISBN
    name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    model VARCHAR(100),
    
    -- Pricing
    cost_price DECIMAL(15,2) DEFAULT 0,
    selling_price DECIMAL(15,2) DEFAULT 0,
    retail_price DECIMAL(15,2) DEFAULT 0,
    wholesale_price DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'PHP',
    
    -- Inventory Control
    unit_of_measure VARCHAR(50) DEFAULT 'piece', -- piece, box, kg, meter, etc.
    reorder_point INTEGER DEFAULT 0,
    reorder_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 0,
    max_stock_level INTEGER,
    
    -- Physical Properties
    weight DECIMAL(10,3),
    length DECIMAL(10,3),
    width DECIMAL(10,3),
    height DECIMAL(10,3),
    dimension_unit VARCHAR(10) DEFAULT 'cm',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_taxable BOOLEAN DEFAULT true,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    
    -- Metadata
    images JSONB DEFAULT '[]',
    attributes JSONB DEFAULT '{}',
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_sku ON products(tenant_id, sku);
CREATE INDEX idx_products_barcode ON products(tenant_id, barcode);
CREATE INDEX idx_products_active ON products(tenant_id, is_active);

-- 6. WAREHOUSES TABLE
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type VARCHAR(50) DEFAULT 'main' CHECK (type IN ('main', 'branch', 'retail', 'overflow')),
    
    -- Location
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    
    -- Configuration
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    UNIQUE(tenant_id, code)
);

CREATE INDEX idx_warehouses_tenant ON warehouses(tenant_id);
CREATE INDEX idx_warehouses_active ON warehouses(tenant_id, is_active);

-- 7. WAREHOUSE_LOCATIONS TABLE (Bin/Shelf/Rack)
CREATE TABLE warehouse_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Location Hierarchy
    zone VARCHAR(50), -- Zone A, B, C
    aisle VARCHAR(50), -- Aisle 1, 2, 3
    rack VARCHAR(50), -- Rack A, B, C
    shelf VARCHAR(50), -- Shelf 1, 2, 3
    bin VARCHAR(50), -- Bin 1, 2, 3
    
    -- Combined location code for quick scanning
    location_code VARCHAR(100) NOT NULL,
    
    -- Capacity
    capacity INTEGER,
    current_volume DECIMAL(10,2),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(warehouse_id, location_code)
);

CREATE INDEX idx_locations_warehouse ON warehouse_locations(warehouse_id);
CREATE INDEX idx_locations_tenant ON warehouse_locations(tenant_id);
CREATE INDEX idx_locations_code ON warehouse_locations(location_code);

-- 8. INVENTORY_STOCK TABLE (Current Stock Levels)
CREATE TABLE inventory_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    
    -- Quantities
    quantity_on_hand INTEGER DEFAULT 0,
    quantity_available INTEGER DEFAULT 0, -- on_hand - reserved
    quantity_reserved INTEGER DEFAULT 0,
    quantity_incoming INTEGER DEFAULT 0, -- From purchase orders
    
    -- Valuation
    average_cost DECIMAL(15,2) DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    
    -- Last counted
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES users(id),
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(tenant_id, product_id, warehouse_id, location_id)
);

CREATE INDEX idx_stock_tenant ON inventory_stock(tenant_id);
CREATE INDEX idx_stock_product ON inventory_stock(product_id);
CREATE INDEX idx_stock_warehouse ON inventory_stock(warehouse_id);
CREATE INDEX idx_stock_location ON inventory_stock(location_id);

-- 9. STOCK_MOVEMENTS TABLE (Audit Trail for All Stock Changes)
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
    location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    
    -- Movement Details
    movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN (
        'receive', 'issue', 'transfer', 'adjustment', 
        'sale', 'return', 'damage', 'write_off', 'count'
    )),
    reference_type VARCHAR(50), -- purchase_order, sales_order, transfer_order, adjustment
    reference_id UUID, -- ID of the referencing document
    
    -- Quantities
    quantity_before INTEGER NOT NULL,
    quantity_change INTEGER NOT NULL,
    quantity_after INTEGER NOT NULL,
    
    -- Reason
    reason_code VARCHAR(50),
    reason_notes TEXT,
    
    -- Cost Impact
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    
    -- Audit
    performed_at TIMESTAMPTZ DEFAULT NOW(),
    performed_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_movements_tenant ON stock_movements(tenant_id);
CREATE INDEX idx_movements_product ON stock_movements(product_id);
CREATE INDEX idx_movements_warehouse ON stock_movements(warehouse_id);
CREATE INDEX idx_movements_type ON stock_movements(movement_type);
CREATE INDEX idx_movements_reference ON stock_movements(reference_type, reference_id);
CREATE INDEX idx_movements_date ON stock_movements(performed_at);

-- ==================================================
-- PROCUREMENT MODULE
-- ==================================================

-- 10. SUPPLIERS TABLE
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Basic Info
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    contact_person VARCHAR(255),
    
    -- Contact Details
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    fax VARCHAR(20),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    
    -- Financial
    tax_id VARCHAR(50),
    payment_terms VARCHAR(100), -- Net 30, COD, etc.
    currency VARCHAR(3) DEFAULT 'PHP',
    credit_limit DECIMAL(15,2),
    
    -- Rating & Performance
    rating DECIMAL(3,2) DEFAULT 0,
    performance_notes TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    UNIQUE(tenant_id, code)
);

CREATE INDEX idx_suppliers_tenant ON suppliers(tenant_id);
CREATE INDEX idx_suppliers_active ON suppliers(tenant_id, is_active);

-- 11. PURCHASE_REQUESTS TABLE
CREATE TABLE purchase_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Document Info
    pr_number VARCHAR(50) NOT NULL,
    requested_date DATE NOT NULL DEFAULT CURRENT_DATE,
    required_date DATE,
    
    -- Requester
    requested_by UUID REFERENCES users(id),
    department VARCHAR(100),
    
    -- Status
    status VARCHAR(30) DEFAULT 'draft' CHECK (status IN (
        'draft', 'submitted', 'approved', 'rejected', 'converted', 'cancelled'
    )),
    
    -- Approval
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Notes
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pr_tenant ON purchase_requests(tenant_id);
CREATE INDEX idx_pr_number ON purchase_requests(tenant_id, pr_number);
CREATE INDEX idx_pr_status ON purchase_requests(status);
CREATE INDEX idx_pr_date ON purchase_requests(requested_date);

-- 12. PURCHASE_REQUEST_ITEMS TABLE
CREATE TABLE purchase_request_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_request_id UUID NOT NULL REFERENCES purchase_requests(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    -- Quantities
    quantity_requested INTEGER NOT NULL,
    quantity_approved INTEGER,
    
    -- Pricing Estimate
    estimated_unit_cost DECIMAL(15,2),
    estimated_total DECIMAL(15,2),
    
    -- Notes
    notes TEXT,
    
    -- Conversion tracking
    converted_quantity INTEGER DEFAULT 0,
    po_item_id UUID, -- Reference to purchase order item
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pr_items_pr ON purchase_request_items(purchase_request_id);
CREATE INDEX idx_pr_items_product ON purchase_request_items(product_id);

-- 13. PURCHASE_ORDERS TABLE
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
    
    -- Document Info
    po_number VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    
    -- Source
    purchase_request_id UUID REFERENCES purchase_requests(id),
    
    -- Shipping
    shipping_address TEXT,
    shipping_method VARCHAR(100),
    freight_terms VARCHAR(100),
    
    -- Financial
    currency VARCHAR(3) DEFAULT 'PHP',
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(30) DEFAULT 'draft' CHECK (status IN (
        'draft', 'submitted', 'confirmed', 'partially_received', 
        'completed', 'cancelled'
    )),
    
    -- Approval
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    
    -- Notes
    internal_notes TEXT,
    supplier_notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_po_tenant ON purchase_orders(tenant_id);
CREATE INDEX idx_po_number ON purchase_orders(tenant_id, po_number);
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_status ON purchase_orders(status);
CREATE INDEX idx_po_date ON purchase_orders(order_date);

-- 14. PURCHASE_ORDER_ITEMS TABLE
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    -- Quantities
    quantity_ordered INTEGER NOT NULL,
    quantity_received INTEGER DEFAULT 0,
    quantity_rejected INTEGER DEFAULT 0,
    
    -- Pricing
    unit_cost DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Delivery
    expected_delivery_date DATE,
    
    -- Warehouse assignment
    warehouse_id UUID REFERENCES warehouses(id),
    location_id UUID REFERENCES warehouse_locations(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_po_items_po ON purchase_order_items(purchase_order_id);
CREATE INDEX idx_po_items_product ON purchase_order_items(product_id);

-- 15. GOODS_RECEIPTS TABLE (Receiving Documents)
CREATE TABLE goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id),
    
    -- Document Info
    gr_number VARCHAR(50) NOT NULL,
    receipt_date TIMESTAMPTZ DEFAULT NOW(),
    
    -- Supplier Info (snapshot)
    supplier_id UUID REFERENCES suppliers(id),
    
    -- Warehouse
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    
    -- Status
    status VARCHAR(30) DEFAULT 'draft' CHECK (status IN (
        'draft', 'partial', 'completed', 'cancelled'
    )),
    
    -- Quality Check
    inspection_status VARCHAR(30) DEFAULT 'pending' CHECK (inspection_status IN (
        'pending', 'passed', 'failed', 'conditional'
    )),
    inspection_notes TEXT,
    inspected_by UUID REFERENCES users(id),
    
    -- Notes
    carrier VARCHAR(100),
    tracking_number VARCHAR(100),
    delivery_receipt_number VARCHAR(100),
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_gr_tenant ON goods_receipts(tenant_id);
CREATE INDEX idx_gr_number ON goods_receipts(tenant_id, gr_number);
CREATE INDEX idx_gr_po ON goods_receipts(purchase_order_id);
CREATE INDEX idx_gr_date ON goods_receipts(receipt_date);

-- 16. GOODS_RECEIPT_ITEMS TABLE
CREATE TABLE goods_receipt_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goods_receipt_id UUID NOT NULL REFERENCES goods_receipts(id) ON DELETE CASCADE,
    purchase_order_item_id UUID REFERENCES purchase_order_items(id),
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Quantities
    quantity_expected INTEGER NOT NULL,
    quantity_received INTEGER NOT NULL,
    quantity_rejected INTEGER DEFAULT 0,
    rejected_reason TEXT,
    
    -- Location
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    location_id UUID REFERENCES warehouse_locations(id),
    
    -- Batch/Lot tracking (optional)
    batch_number VARCHAR(100),
    lot_number VARCHAR(100),
    serial_numbers JSONB DEFAULT '[]',
    expiry_date DATE,
    
    -- Cost
    unit_cost DECIMAL(15,2),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_gr_items_gr ON goods_receipt_items(goods_receipt_id);
CREATE INDEX idx_gr_items_product ON goods_receipt_items(product_id);

-- ==================================================
-- SALES & QUOTATIONS MODULE
-- ==================================================

-- 17. CUSTOMERS TABLE
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Basic Info
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type VARCHAR(50) DEFAULT 'retail' CHECK (type IN ('retail', 'wholesale', 'contractor', 'company')),
    
    -- Contact
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    
    -- Address
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_city VARCHAR(100),
    billing_province VARCHAR(100),
    billing_postal_code VARCHAR(20),
    
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_province VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    
    -- Financial
    tax_id VARCHAR(50),
    payment_terms VARCHAR(100),
    currency VARCHAR(3) DEFAULT 'PHP',
    credit_limit DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2) DEFAULT 0,
    
    -- Pricing
    price_level VARCHAR(50) DEFAULT 'retail' CHECK (price_level IN ('retail', 'wholesale', 'contractor')),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    UNIQUE(tenant_id, code)
);

CREATE INDEX idx_customers_tenant ON customers(tenant_id);
CREATE INDEX idx_customers_active ON customers(tenant_id, is_active);

-- 18. QUOTATIONS TABLE
CREATE TABLE quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    
    -- Document Info
    quotation_number VARCHAR(50) NOT NULL,
    quotation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_until DATE,
    
    -- Project/Job Info (for contractors)
    project_name VARCHAR(255),
    project_address TEXT,
    
    -- Financial
    currency VARCHAR(3) DEFAULT 'PHP',
    subtotal DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(30) DEFAULT 'draft' CHECK (status IN (
        'draft', 'sent', 'viewed', 'accepted', 'rejected', 
        'expired', 'converted', 'cancelled'
    )),
    
    -- Conversion
    sales_order_id UUID,
    
    -- Notes
    terms_and_conditions TEXT,
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_quotations_tenant ON quotations(tenant_id);
CREATE INDEX idx_quotations_number ON quotations(tenant_id, quotation_number);
CREATE INDEX idx_quotations_customer ON quotations(customer_id);
CREATE INDEX idx_quotations_status ON quotations(status);
CREATE INDEX idx_quotations_date ON quotations(quotation_date);

-- 19. QUOTATION_ITEMS TABLE
CREATE TABLE quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    
    -- Allow non-inventory items
    description TEXT NOT NULL,
    
    -- Quantities
    quantity DECIMAL(10,2) NOT NULL,
    unit_of_measure VARCHAR(50) DEFAULT 'piece',
    
    -- Pricing
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Notes
    notes TEXT,
    
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_q_items_quotation ON quotation_items(quotation_id);
CREATE INDEX idx_q_items_product ON quotation_items(product_id);

-- 20. SALES_ORDERS TABLE
CREATE TABLE sales_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id),
    
    -- Document Info
    so_number VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    required_date DATE,
    
    -- Source
    quotation_id UUID REFERENCES quotations(id),
    
    -- Warehouse
    warehouse_id UUID REFERENCES warehouses(id),
    
    -- Financial
    currency VARCHAR(3) DEFAULT 'PHP',
    subtotal DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Payment
    payment_status VARCHAR(30) DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'partial', 'paid', 'refunded', 'cancelled'
    )),
    
    -- Fulfillment
    fulfillment_status VARCHAR(30) DEFAULT 'pending' CHECK (fulfillment_status IN (
        'pending', 'partially_fulfilled', 'fulfilled', 'cancelled'
    )),
    
    -- Notes
    internal_notes TEXT,
    customer_notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_so_tenant ON sales_orders(tenant_id);
CREATE INDEX idx_so_number ON sales_orders(tenant_id, so_number);
CREATE INDEX idx_so_customer ON sales_orders(customer_id);
CREATE INDEX idx_so_status ON sales_orders(fulfillment_status);

-- 21. SALES_ORDER_ITEMS TABLE
CREATE TABLE sales_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_order_id UUID NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Quantities
    quantity_ordered DECIMAL(10,2) NOT NULL,
    quantity_fulfilled DECIMAL(10,2) DEFAULT 0,
    
    -- Pricing
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Fulfillment
    warehouse_id UUID REFERENCES warehouses(id),
    location_id UUID REFERENCES warehouse_locations(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_so_items_so ON sales_order_items(sales_order_id);
CREATE INDEX idx_so_items_product ON sales_order_items(product_id);

-- ==================================================
-- AUDIT & SYNC TABLES
-- ==================================================

-- 22. AUDIT_LOGS TABLE (Comprehensive Activity Tracking)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    
    -- Actor
    user_id UUID REFERENCES users(id),
    user_email VARCHAR(255),
    
    -- Action
    action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE, LOGIN, LOGOUT, etc.
    entity_type VARCHAR(100) NOT NULL, -- table name
    entity_id UUID,
    
    -- Changes
    old_values JSONB,
    new_values JSONB,
    
    -- Context
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(100),
    
    -- Timestamp
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_tenant ON audit_logs(tenant_id);
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_date ON audit_logs(created_at);

-- 23. SYNC_QUEUE TABLE (For Offline Sync Operations)
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    
    -- Operation
    operation VARCHAR(20) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    
    -- Payload
    payload JSONB NOT NULL,
    
    -- Status
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN (
        'pending', 'processing', 'completed', 'failed'
    )),
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Timestamps
    queued_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    
    -- Device info for conflict resolution
    device_id VARCHAR(100),
    local_timestamp TIMESTAMPTZ
);

CREATE INDEX idx_sync_tenant ON sync_queue(tenant_id);
CREATE INDEX idx_sync_status ON sync_queue(status);
CREATE INDEX idx_sync_queued ON sync_queue(queued_at);

-- ==================================================
-- VIEWS FOR ANALYTICS
-- ==================================================

-- Low Stock Products View
CREATE OR REPLACE VIEW low_stock_products AS
SELECT 
    p.id,
    p.tenant_id,
    p.sku,
    p.name,
    p.reorder_point,
    SUM(s.quantity_available) as total_available
FROM products p
JOIN inventory_stock s ON p.id = s.product_id
WHERE p.is_active = true
GROUP BY p.id, p.tenant_id, p.sku, p.name, p.reorder_point
HAVING SUM(s.quantity_available) <= p.reorder_point;

-- Fast Moving Products View (Last 30 Days)
CREATE OR REPLACE VIEW fast_moving_products AS
SELECT 
    p.id,
    p.tenant_id,
    p.sku,
    p.name,
    COUNT(sm.id) as movement_count,
    SUM(sm.quantity_change) as total_sold
FROM products p
JOIN stock_movements sm ON p.id = sm.product_id
WHERE sm.movement_type = 'sale'
    AND sm.performed_at >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.tenant_id, p.sku, p.name
ORDER BY total_sold DESC
LIMIT 100;

-- Procurement Status View
CREATE OR REPLACE VIEW procurement_status AS
SELECT 
    po.id,
    po.tenant_id,
    po.po_number,
    s.name as supplier_name,
    po.status,
    po.total_amount,
    po.expected_delivery_date,
    COUNT(poi.id) as total_items,
    SUM(poi.quantity_received) as total_received
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.id
LEFT JOIN purchase_order_items poi ON po.id = poi.purchase_order_id
GROUP BY po.id, po.tenant_id, po.po_number, s.name, po.status, 
         po.total_amount, po.expected_delivery_date;

-- ==================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==================================================

-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_request_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipt_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotation_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

-- Function to get current tenant_id from JWT
CREATE OR REPLACE FUNCTION get_current_tenant_id() RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tenants: Users can only see their own tenant
CREATE POLICY tenant_isolation ON tenants
    FOR ALL USING (id = get_current_tenant_id());

-- All other tables: Filter by tenant_id
-- Generic policy template (apply to each table)
-- Example for products:
CREATE POLICY products_tenant_isolation ON products
    FOR ALL USING (tenant_id = get_current_tenant_id());

-- Repeat similar policies for all tenant-scoped tables...
-- (In production, generate these programmatically or use a loop)

-- ==================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ==================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==================================================
-- INITIAL DATA SEEDING (Optional)
-- ==================================================

-- Create a default super admin tenant user function
CREATE OR REPLACE FUNCTION create_tenant_owner(
    p_tenant_name VARCHAR,
    p_tenant_slug VARCHAR,
    p_user_email VARCHAR,
    p_user_name VARCHAR
) RETURNS UUID AS $$
DECLARE
    v_tenant_id UUID;
    v_user_id UUID;
BEGIN
    -- Create tenant
    INSERT INTO tenants (name, slug, status)
    VALUES (p_tenant_name, p_tenant_slug, 'active')
    RETURNING id INTO v_tenant_id;
    
    -- Note: User creation requires auth.users insertion
    -- This should be done via Supabase Auth API, not directly
    
    RETURN v_tenant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==================================================
-- END OF SCHEMA
-- ==================================================
