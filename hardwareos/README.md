# HardwareOS - Multi-Tenant SaaS Platform

## Production-Ready Inventory, Procurement & Warehouse Management SaaS

### 🏗️ Architecture Overview

HardwareOS is a **multi-tenant cloud-based SaaS platform** designed for:
- Hardware stores
- Construction suppliers  
- Warehouses
- Distributors
- Building material suppliers

### 🎯 Core Principles

- **Multi-Tenant**: One platform serves many businesses with complete data isolation
- **Offline-First**: Works with weak internet, syncs when connected
- **Low-Resource Optimized**: Built for 4GB RAM development machines
- **Zero-Cost Stack**: All free tiers and open-source tools
- **Production-Ready**: Enterprise-grade architecture from day one

### 🛠️ Technology Stack

| Component | Technology | Cost |
|-----------|-----------|------|
| Frontend | Flutter Web (PWA) | Free |
| Backend | Supabase (PostgreSQL) | Free Tier |
| Offline DB | Drift (SQLite) | Free |
| State Management | Riverpod | Free |
| Hosting | Cloudflare Pages | Free |
| Auth | Supabase Auth | Free Tier |

### 📁 Project Structure

```
hardwareos/
├── lib/
│   ├── core/                    # Core infrastructure
│   │   ├── constants/           # App-wide constants
│   │   ├── errors/              # Error handling
│   │   ├── network/             # API clients, Supabase
│   │   ├── router/              # GoRouter configuration
│   │   ├── theme/               # Design system
│   │   └── utils/               # Utilities
│   ├── features/                # Feature modules
│   │   ├── auth/                # Authentication
│   │   ├── tenants/             # Multi-tenant management
│   │   ├── inventory/           # Inventory module
│   │   ├── procurement/         # Procurement module
│   │   ├── sales/               # Sales & quotations
│   │   ├── warehouse/           # Warehouse operations
│   │   └── dashboard/           # Analytics dashboard
│   ├── models/                  # Data models
│   ├── repositories/            # Data repositories
│   ├── services/                # Business logic services
│   └── main.dart                # Entry point
├── test/                        # Test files
├── pubspec.yaml                 # Dependencies
└── README.md
```

### 🚀 Quick Start

#### Prerequisites Setup

```bash
# 1. Install Flutter SDK (optimized for low RAM)
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz
rm flutter_linux_3.24.0-stable.tar.xz

# 2. Add Flutter to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Verify installation
flutter --version
flutter doctor

# 4. Enable Flutter Web
flutter config --enable-web
```

#### Project Setup

```bash
cd /workspace/hardwareos

# Create Flutter project (web-only for low RAM)
flutter create --org com.hardwareos --platforms web .

# Install dependencies
flutter pub get

# Run development server
flutter run -d chrome --web-renderer html
```

### 📊 Database Schema

See `database/schema.sql` for complete PostgreSQL schema with:
- Multi-tenant isolation (tenant_id on every table)
- Row-Level Security policies
- Audit trails
- Optimized indexes

### 🔐 Multi-Tenant Security

- **Database Level**: Supabase RLS policies enforce tenant isolation
- **Application Level**: Every query includes tenant_id filter
- **Auth Level**: User-tenant mapping in JWT claims

### 📦 Key Features (MVP)

1. ✅ Authentication & Multi-Tenant Onboarding
2. ✅ User Roles & Permissions (Owner, Manager, Sales, Warehouse)
3. ✅ Inventory Management with SKU & Barcode
4. ✅ Procurement Workflows (PR → PO → Receiving)
5. ✅ Sales & Quotations
6. ✅ Warehouse Operations
7. ✅ Dashboard Analytics
8. ✅ Offline Capability with Sync

### 🎨 Design System

**Colors:**
- Primary: Dark Gray (#2C2C2C)
- Accent: Industrial Orange (#FF6B35)
- Background: White/Light Gray
- Text: High contrast for readability

**Principles:**
- Industrial, minimal, professional
- Operational speed over animations
- Low learning curve
- Enterprise-ready appearance

### 🚀 Deployment

```bash
# Build for production
flutter build web --release --web-renderer html

# Deploy to Cloudflare Pages (free)
npm install -g wrangler
wrangler pages deploy build/web --project-name=hardwareos
```

### 📝 License

Proprietary - All Rights Reserved

---

Built with ❤️ for Philippine hardware & construction supply businesses
