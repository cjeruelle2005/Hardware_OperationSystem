# 🚀 HardwareOS - Project Summary & Getting Started

## What is HardwareOS?

**HardwareOS** is a production-ready, multi-tenant SaaS platform designed for:
- Hardware stores in the Philippines
- Construction suppliers
- Warehouses and distributors
- Building material suppliers

It provides complete operational infrastructure for:
- Inventory management with real-time stock tracking
- Procurement workflows (PR → PO → Receiving)
- Sales & quotations for contractors
- Warehouse operations and stock movements
- Business analytics and reporting

---

## 🎯 Key Features

### Multi-Tenant Architecture
- **One platform, many businesses**: Each tenant has isolated data
- **Customizable branding**: Logo, colors, receipt footers per tenant
- **Role-based access**: Owner, Manager, Sales, Warehouse staff
- **Complete data isolation**: Businesses never see each other's data

### Offline-First Design
- Works with weak or no internet connection
- Local SQLite database (Drift)
- Automatic background sync when online
- Queue-based operation recovery

### Low-Resource Optimized
- Built for 4GB RAM development machines
- Flutter Web with HTML renderer
- Minimal dependencies
- VS Code only (no Android Studio)

### Zero-Cost Stack
- All free tiers until revenue justifies upgrade
- Supabase Free Tier (500MB DB, 50K MAU)
- Cloudflare Pages (free hosting)
- Open-source tools only

---

## 📁 Project Structure

```
hardwareos/
├── README.md                 # Quick overview
├── ARCHITECTURE.md           # Detailed architecture guide
├── SETUP_GUIDE.md            # Ubuntu setup instructions
├── pubspec.yaml              # Dependencies
├── analysis_options.yaml     # Linter rules
│
├── database/
│   └── schema.sql            # Complete PostgreSQL schema
│
├── lib/
│   ├── main.dart             # Entry point
│   │
│   ├── core/                 # Shared infrastructure
│   │   ├── constants/        # App constants
│   │   ├── errors/           # Exceptions & failures
│   │   ├── network/          # Supabase, connectivity
│   │   ├── router/           # GoRouter config
│   │   ├── theme/            # Colors, typography, theme
│   │   └── utils/            # Utilities
│   │
│   └── features/             # Feature modules
│       ├── auth/             # Authentication
│       ├── tenants/          # Multi-tenant management
│       ├── inventory/        # Products, categories, stock
│       ├── procurement/      # Purchase orders, suppliers
│       ├── sales/            # Quotations, invoices
│       ├── warehouse/        # Stock movements, transfers
│       └── dashboard/        # Analytics
│
├── assets/                   # Images, fonts, icons
├── web/                      # Web-specific files
└── test/                     # Test files
```

---

## 🛠️ Technology Stack

| Component | Technology | Why? |
|-----------|-----------|------|
| Frontend | Flutter Web | Single codebase, PWA support |
| Backend | Supabase | PostgreSQL + Auth + RLS |
| State Management | Riverpod | Compile-safe, low boilerplate |
| Routing | GoRouter | Type-safe, declarative |
| Local DB | Drift | Type-safe SQL, offline support |
| Error Handling | Dartz | Either type for FP |
| Hosting | Cloudflare Pages | Free, fast, global CDN |

---

## 🏗️ Database Schema

The PostgreSQL schema includes **23 tables** organized into modules:

### Core Tables
- `tenants` - Business organizations
- `users` - Application users
- `tenant_users` - User-tenant-role mapping

### Inventory Module
- `categories` - Product categories (hierarchical)
- `products` - Product catalog with SKU/barcode
- `warehouses` - Warehouse locations
- `warehouse_locations` - Bin/shelf/rack positions
- `inventory_stock` - Current stock levels
- `stock_movements` - Audit trail of all changes

### Procurement Module
- `suppliers` - Supplier records
- `purchase_requests` - Internal purchase requests
- `purchase_request_items` - PR line items
- `purchase_orders` - Official purchase orders
- `purchase_order_items` - PO line items
- `goods_receipts` - Receiving documents
- `goods_receipt_items` - Received items

### Sales Module
- `customers` - Customer records
- `quotations` - Price quotations
- `quotation_items` - Quotation line items
- `sales_orders` - Confirmed sales
- `sales_order_items` - Sales line items

### Audit & Sync
- `audit_logs` - Complete activity tracking
- `sync_queue` - Offline sync operations

### Security
- Row-Level Security (RLS) on all tables
- Tenant isolation enforced at database level
- Comprehensive audit trails

---

## 🔐 Multi-Tenant Security

### Three-Layer Isolation

1. **Database Level (Primary)**
   - Every table has `tenant_id` column
   - RLS policies filter by tenant automatically
   - Cannot bypass even with direct SQL

2. **Application Level (Defense)**
   - All queries include tenant_id filter
   - Tenant context stored in Riverpod state
   - Middleware validates access

3. **Authentication Level**
   - JWT tokens contain user info
   - Session management via Supabase Auth
   - Secure token storage

---

## 👥 User Roles

| Role | Permissions |
|------|-------------|
| **Owner** | Full access to all modules and settings |
| **Manager** | Procurement, inventory oversight, reports |
| **Sales** | Quotations, sales, customer management |
| **Warehouse** | Stock receiving, movements, adjustments |
| **Viewer** | Read-only access to reports |

---

## 🎨 Design System

### Colors
- **Primary**: Industrial Orange (#FF6B35)
- **Secondary**: Dark Gray (#2C2C2C)
- **Neutral**: Gray scale (50-900)
- **Semantic**: Success (green), Warning (amber), Error (red), Info (blue)

### Typography
- **Font Family**: Inter (clean, professional)
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)
- **Scale**: Display → Headline → Title → Body → Label → Caption

### UI Principles
- Industrial, minimal, professional
- Operational speed over animations
- High contrast for readability
- Consistent 8px grid system

---

## 🚀 Quick Start

### Prerequisites
- Ubuntu Linux
- 4GB RAM minimum
- VS Code installed
- Git installed

### Step 1: Install Flutter

```bash
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz
rm flutter_linux_3.24.0-stable.tar.xz
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

### Step 2: Setup Project

```bash
cd /workspace/hardwareos
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Setup Supabase

1. Create account at https://supabase.com
2. Create project (Singapore region)
3. Run `database/schema.sql` in SQL Editor
4. Copy API credentials

### Step 4: Run Development Server

```bash
flutter run -d chrome --web-renderer html
```

---

## 📦 Available Commands

```bash
# Get dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run development server
flutter run -d chrome --web-renderer html

# Run tests
flutter test

# Build for production
flutter build web --release --web-renderer html

# Clean build artifacts
flutter clean

# Check for issues
flutter doctor
```

---

## 📈 Development Roadmap

### Phase 1: Foundation (Current)
- ✅ Project structure
- ✅ Database schema
- ✅ Theme system
- ✅ Router configuration
- ✅ Error handling
- ⏳ Authentication module
- ⏳ Tenant management

### Phase 2: Core Modules
- ⏳ Inventory management
- ⏳ Procurement workflows
- ⏳ Sales & quotations
- ⏳ Warehouse operations

### Phase 3: Advanced Features
- ⏳ Dashboard analytics
- ⏳ Offline sync
- ⏳ Reports & exports
- ⏳ Barcode scanning

### Phase 4: Production
- ⏳ Deployment automation
- ⏳ Monitoring & logging
- ⏳ Performance optimization
- ⏳ Security hardening

---

## 📚 Documentation

- **README.md** - Quick overview
- **ARCHITECTURE.md** - Detailed architecture (1000+ lines)
- **SETUP_GUIDE.md** - Ubuntu setup instructions
- **database/schema.sql** - Complete database schema with comments

---

## 🔧 Development Guidelines

### Code Style
- Follow Dart style guide
- Use `const` constructors where possible
- Prefer single quotes
- Organize imports (sort_pub_dependencies)
- Avoid print statements (use logging service)

### Architecture Rules
1. Domain layer has no dependencies
2. Data layer implements domain interfaces
3. Presentation layer depends on domain only
4. No circular dependencies
5. Use Either type for error handling

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/module-name

# Commit frequently
git add .
git commit -m "feat: implement feature X"

# Push and create PR
git push -u origin feature/module-name
```

### Commit Message Format
```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Maintenance tasks
```

---

## 🎯 Success Metrics

### MVP Goals
- [ ] User can sign up and create tenant
- [ ] User can add products with SKU
- [ ] User can record stock movements
- [ ] User can create purchase orders
- [ ] User can generate quotations
- [ ] App works offline
- [ ] Data syncs when online

### Performance Targets
- Initial load < 3 seconds
- Hot reload < 1 second
- Bundle size < 5MB
- RAM usage < 500MB (browser)

---

## 💰 Cost Breakdown (₱0 Budget)

| Service | Free Tier | Paid Upgrade |
|---------|-----------|--------------|
| Supabase | 500MB DB, 50K MAU | ₱1,200/mo (Pro) |
| Cloudflare Pages | Unlimited sites | Included |
| GitHub | Unlimited repos | Included |
| Flutter | Open source | Free |
| VS Code | Free | Free |

**Total Monthly Cost: ₱0** until you have paying customers

---

## 🤝 Contributing

This is currently a solo-developer project. Future contributors should:

1. Fork the repository
2. Create feature branch
3. Follow existing patterns
4. Write tests for new features
5. Update documentation
6. Create pull request

---

## 📞 Support & Resources

### Documentation
- Flutter: https://docs.flutter.dev
- Supabase: https://supabase.com/docs
- Riverpod: https://riverpod.dev
- GoRouter: https://pub.dev/packages/go_router

### Communities
- Flutter Philippines (Facebook)
- r/FlutterDev (Reddit)
- Supabase Discord

---

## 📄 License

Proprietary - All Rights Reserved

This is commercial software intended for SaaS business.
Do not distribute or copy without permission.

---

## 🙏 Acknowledgments

Built with ❤️ for Philippine hardware stores and construction suppliers.

Special thanks to:
- Flutter team for amazing framework
- Supabase team for backend infrastructure
- Riverpod team for state management
- Open-source community

---

## 🚀 Let's Build!

You now have everything you need to start building HardwareOS.

**Next Steps:**
1. Read SETUP_GUIDE.md for environment setup
2. Read ARCHITECTURE.md for deep dive
3. Start with authentication module
4. Build one feature at a time
5. Test thoroughly
6. Deploy early, iterate often

**Remember:** This is a marathon, not a sprint. Focus on building value for your users, and the business will follow.

Good luck! 🎉

---

*Last Updated: May 2024*
*Version: 1.0.0*
