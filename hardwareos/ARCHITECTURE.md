# HardwareOS - Complete SaaS Architecture Guide

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Multi-Tenant Design](#multi-tenant-design)
3. [Technology Stack Decisions](#technology-stack-decisions)
4. [Flutter Project Structure](#flutter-project-structure)
5. [Clean Architecture Implementation](#clean-architecture-implementation)
6. [Package Dependencies](#package-dependencies)
7. [Supabase Integration](#supabase-integration)
8. [Offline-First Architecture](#offline-first-architecture)
9. [Security Strategy](#security-strategy)
10. [Development Setup (Ubuntu + 4GB RAM)](#development-setup)

---

## Architecture Overview

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Flutter Web (PWA)                           │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │   │
│  │  │   Features  │  │   Widgets   │  │    Pages    │   │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘   │   │
│  │  ┌─────────────────────────────────────────────────┐  │   │
│  │  │          Riverpod State Management              │  │   │
│  │  └─────────────────────────────────────────────────┘  │   │
│  │  ┌─────────────────────────────────────────────────┐  │   │
│  │  │       Drift (SQLite) - Offline Database         │  │   │
│  │  └─────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ Sync Queue
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND LAYER (Supabase)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Supabase Auth (PostgREST)               │   │
│  │         JWT-based Authentication & RLS               │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              PostgreSQL Database                     │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │  Multi-Tenant Tables with tenant_id            │ │   │
│  │  │  Row-Level Security Policies                   │ │   │
│  │  │  Audit Logs & Sync Queue                       │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

1. **Single Codebase, Multi-Tenant**: One deployment serves all customers
2. **Data Isolation**: Every query scoped by `tenant_id`
3. **Offline-First**: Local SQLite cache with background sync
4. **Low-Resource Optimized**: Minimal dependencies, efficient builds
5. **Zero-Cost Stack**: All free tiers until revenue justifies upgrade

---

## Multi-Tenant Design

### Tenant Isolation Strategy

#### Level 1: Database Isolation (Primary)
- Every table has `tenant_id` column
- Row-Level Security (RLS) policies enforce isolation
- Application cannot bypass database-level security

#### Level 2: Application Isolation (Defense in Depth)
- All repository queries include `tenant_id` filter
- User's current tenant stored in provider state
- Middleware validates tenant access on every request

#### Level 3: JWT Claims (Authentication)
- Supabase JWT includes `tenant_id` claim
- Validated on every API call
- Automatically injected into PostgreSQL session

### Tenant Data Model

```dart
// Every business data model includes:
class BaseModel {
  final String id;
  final String tenantId; // ← Critical for isolation
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
}
```

### Tenant Customization

Each tenant can customize:
- Store name & logo
- Brand colors (primary/secondary)
- Receipt footer text
- Invoice terms
- Warehouse/branch names
- User roles & permissions

---

## Technology Stack Decisions

### Why Flutter Web?

✅ **Pros:**
- Single codebase for web + mobile (future Android/iOS)
- Excellent PWA support with offline capability
- Fast development velocity
- Hot reload for rapid iteration
- Rich widget library for enterprise UI

❌ **Cons (Mitigated):**
- Larger bundle size → Use HTML renderer, lazy loading
- SEO limitations → Not critical for B2B SaaS

### Why Supabase?

✅ **Pros:**
- Free tier: 500MB database, 50K MAU, 5GB bandwidth
- Built-in authentication
- Real-time subscriptions
- PostgreSQL with RLS (critical for multi-tenant)
- Auto-generated APIs (no backend code needed initially)
- Philippine-friendly latency (Singapore region)

❌ **Cons:**
- Vendor lock-in → Mitigate with clean repository pattern
- Rate limits on free tier → Sufficient for MVP

### Why Riverpod?

✅ **Pros:**
- Compile-time safety
- No boilerplate (vs Bloc)
- Easy testing
- Dependency injection built-in
- Low memory footprint

### Why Drift (SQLite)?

✅ **Pros:**
- Pure Dart (no native dependencies)
- Type-safe SQL
- Migration support
- Works on web (via sql.js)
- Perfect for offline caching

### Why NOT Other Options?

| Technology | Reason to Avoid |
|------------|-----------------|
| AWS | Too expensive, complex for MVP |
| Firebase | No relational DB, weak multi-tenant support |
| Docker/K8s | Overkill, RAM-heavy, adds complexity |
| Electron | Desktop not needed, web PWA sufficient |
| Angular/React | Flutter faster for solo dev, unified mobile/web |

---

## Flutter Project Structure

### Clean Architecture Folder Layout

```
hardwareos/
├── lib/
│   ├── core/                          # Shared infrastructure
│   │   ├── constants/
│   │   │   ├── app_constants.dart     # App-wide constants
│   │   │   ├── asset_constants.dart   # Image/font paths
│   │   │   └── route_constants.dart   # Route names
│   │   ├── errors/
│   │   │   ├── exceptions.dart        # Custom exceptions
│   │   │   └── failures.dart          # Functional error handling
│   │   ├── network/
│   │   │   ├── supabase_client.dart   # Supabase wrapper
│   │   │   ├── api_service.dart       # REST API calls
│   │   │   └── network_info.dart      # Connectivity check
│   │   ├── router/
│   │   │   └── app_router.dart        # GoRouter configuration
│   │   ├── theme/
│   │   │   ├── app_theme.dart         # ThemeData
│   │   │   ├── app_colors.dart        # Color palette
│   │   │   └── app_typography.dart    # Text styles
│   │   └── utils/
│   │       ├── date_formatter.dart    # Date utilities
│   │       ├── currency_formatter.dart # PHP formatting
│   │       └── validators.dart        # Form validation
│   │
│   ├── features/                      # Feature modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── tenant_user_model.dart
│   │   │   │   └── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── user.dart
│   │   │   │   │   └── tenant_user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in.dart
│   │   │   │       ├── sign_up.dart
│   │   │   │       └── sign_out.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── signup_page.dart
│   │   │       │   └── tenant_selection_page.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── tenant_selector.dart
│   │   │
│   │   ├── tenants/                   # Multi-tenant management
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── inventory/                 # Inventory module
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   │   ├── product_model.dart
│   │   │   │   │   ├── category_model.dart
│   │   │   │   │   └── stock_model.dart
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── product.dart
│   │   │   │   │   ├── category.dart
│   │   │   │   │   └── stock.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_products.dart
│   │   │   │       ├── create_product.dart
│   │   │   │       ├── update_product.dart
│   │   │   │       ├── delete_product.dart
│   │   │   │       ├── get_low_stock.dart
│   │   │   │       └── record_stock_movement.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       │   ├── products_list_page.dart
│   │   │       │   ├── product_form_page.dart
│   │   │       │   ├── categories_page.dart
│   │   │       │   └── stock_adjustment_page.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── procurement/               # Procurement module
│   │   ├── sales/                     # Sales & quotations
│   │   ├── warehouse/                 # Warehouse operations
│   │   └── dashboard/                 # Analytics dashboard
│   │
│   ├── models/                        # Shared models
│   ├── repositories/                  # Shared repositories
│   ├── services/                      # Business logic services
│   │   ├── sync_service.dart          # Offline sync orchestration
│   │   ├── notification_service.dart  # Push notifications
│   │   └── report_service.dart        # PDF generation
│   │
│   └── main.dart                      # Entry point
│
├── test/                              # Test files
│   ├── core/
│   ├── features/
│   └── fixtures/
│
├── web/                               # Web-specific files
│   ├── index.html
│   ├── manifest.json
│   └── icons/
│
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linter rules
└── README.md
```

### File Placement Rules

1. **Feature-first organization**: Each feature is self-contained
2. **Layer separation**: `data` ↔ `domain` ↔ `presentation`
3. **Dependency rule**: Outer layers depend on inner layers, never reverse
4. **Shared code in `core/`**: Only put truly shared utilities here

---

## Clean Architecture Implementation

### Layer Responsibilities

#### Domain Layer (Innermost)
- **Entities**: Pure business objects (no dependencies)
- **Repositories**: Abstract interfaces (abstract classes)
- **Use Cases**: Single-responsibility business logic

```dart
// lib/features/inventory/domain/entities/product.dart
class Product {
  final String id;
  final String tenantId;
  final String sku;
  final String name;
  final Decimal costPrice;
  final Decimal sellingPrice;
  final int reorderPoint;
  final bool isActive;
  
  // Business logic methods
  bool get isLowStock => currentStock <= reorderPoint;
}

// lib/features/inventory/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAll();
  Future<Either<Failure, Product>> getById(String id);
  Future<Either<Failure, Product>> create(Product product);
  Future<Either<Failure, Product>> update(Product product);
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, List<Product>>> getLowStock();
}

// lib/features/inventory/domain/usecases/get_products.dart
class GetProducts {
  final ProductRepository repository;
  
  GetProducts(this.repository);
  
  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getAll();
  }
}
```

#### Data Layer (Outer)
- **Models**: Extend entities with serialization logic
- **Data Sources**: Remote (Supabase) and Local (Drift)
- **Repositories**: Implement domain repository interfaces

```dart
// lib/features/inventory/data/models/product_model.dart
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.tenantId,
    required super.sku,
    required super.name,
    required super.costPrice,
    required super.sellingPrice,
    required super.reorderPoint,
    required super.isActive,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      tenantId: json['tenant_id'],
      sku: json['sku'],
      name: json['name'],
      costPrice: Decimal.parse(json['cost_price']),
      sellingPrice: Decimal.parse(json['selling_price']),
      reorderPoint: json['reorder_point'],
      isActive: json['is_active'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'sku': sku,
      'name': name,
      'cost_price': costPrice.toString(),
      'selling_price': sellingPrice.toString(),
      'reorder_point': reorderPoint,
      'is_active': isActive,
    };
  }
}

// lib/features/inventory/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, List<Product>>> getAll() async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts();
        // Cache to local DB
        await localDataSource.cacheProducts(products);
        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Fallback to local cache
      final products = await localDataSource.getCachedProducts();
      return Right(products);
    }
  }
}
```

#### Presentation Layer (Outer)
- **Providers**: Riverpod state management
- **Pages**: Full-screen views
- **Widgets**: Reusable components

```dart
// lib/features/inventory/presentation/providers/product_provider.dart
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.watch(getProductsUseCaseProvider));
});

class ProductNotifier extends StateNotifier<ProductState> {
  final GetProducts getProducts;
  
  ProductNotifier(this.getProducts) : super(ProductInitial()) {
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    state = ProductLoading();
    final result = await getProducts();
    result.fold(
      (failure) => state = ProductError(failure.message),
      (products) => state = ProductLoaded(products),
    );
  }
}
```

---

## Package Dependencies

### Minimal Production-Ready `pubspec.yaml`

```yaml
name: hardwareos
description: Multi-tenant SaaS for hardware stores and construction suppliers
version: 1.0.0+1
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Routing
  go_router: ^13.0.0
  
  # Backend
  supabase_flutter: ^2.3.0
  
  # Local Database (Offline)
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.18
  
  # Functional Programming (Error Handling)
  dartz: ^0.10.1
  
  # JSON Serialization
  json_annotation: ^4.8.1
  
  # HTTP Client
  http: ^1.2.0
  
  # Connectivity Check
  connectivity_plus: ^5.0.2
  
  # Secure Storage (for tokens)
  flutter_secure_storage: ^9.0.0
  
  # Date/Time Utilities
  intl: ^0.19.0
  
  # Decimal Math (for money)
  decimal: ^2.3.3
  
  # UUID Generation
  uuid: ^4.3.3
  
  # Input Validation
  equatable: ^2.0.5
  
  # UI Components (Minimal)
  flutter_animate: ^4.4.0  # Lightweight animations
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Code Generation
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  drift_dev: ^2.15.0
  mockito: ^5.4.4
  mocktail: ^1.0.2

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### Package Justification

| Package | Purpose | Why This One? |
|---------|---------|---------------|
| `flutter_riverpod` | State management | Compile-safe, low boilerplate |
| `go_router` | Navigation | Declarative, type-safe routing |
| `supabase_flutter` | Backend | Official SDK, RLS support |
| `drift` | Local DB | Type-safe SQL, web support |
| `dartz` | FP | Either type for error handling |
| `decimal` | Money math | Precise decimal arithmetic |
| `connectivity_plus` | Network | Detect online/offline |

### Packages to AVOID (RAM Optimization)

❌ **Heavy packages not included:**
- `bloc` / `flutter_bloc` → More boilerplate than Riverpod
- `provider` → Less safe than Riverpod
- `get_it` → Riverpod handles DI
- `dio` → `http` package sufficient for MVP
- `hive` → Drift better for relational data
- `firebase_*` → Using Supabase instead
- `syncfusion_flutter_*` → Too heavy, use charts later
- `pdf` → Generate reports server-side initially

---

## Supabase Integration

### Project Setup Steps

1. **Create Supabase Project**
   ```
   - Go to https://supabase.com
   - Sign up (free)
   - Create new project: "HardwareOS"
   - Region: Singapore (closest to Philippines)
   - Database password: Save securely
   ```

2. **Run Database Schema**
   ```sql
   -- In Supabase SQL Editor
   -- Copy entire contents of database/schema.sql
   -- Execute (takes ~5 seconds)
   ```

3. **Configure Authentication**
   ```
   - Go to Authentication → Providers
   - Enable Email provider
   - Disable email confirmation (for MVP)
   - Set site URL: http://localhost:61234
   ```

4. **Set Up Row-Level Security**
   ```sql
   -- Already in schema.sql, but verify:
   -- All tables should have ENABLE ROW LEVEL SECURITY
   -- Policies should reference get_current_tenant_id()
   ```

5. **Get API Credentials**
   ```
   - Go to Settings → API
   - Copy:
     - Project URL: https://xxxxx.supabase.co
     - Anon/Public Key: eyJhbG...
   ```

### Flutter Supabase Client

```dart
// lib/core/network/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();
  factory SupabaseClient() => _instance;
  SupabaseClient._internal();
  
  late final Supabase supabase;
  
  void initialize() {
    supabase = Supabase.instance.connect(
      'YOUR_SUPABASE_URL',
      'YOUR_SUPABASE_ANON_KEY',
    );
  }
  
  SupabaseClient get instance => supabase;
  
  // Helper to set tenant context for RLS
  Future<void> setTenantContext(String tenantId) async {
    // This sets the tenant_id in the session for RLS policies
    await supabase.rpc('set_current_tenant_id', params: {'tenant_id': tenantId});
  }
}
```

### Environment Configuration

```dart
// lib/core/constants/env_constants.dart
class EnvConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://default.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'default-key',
  );
}
```

Run with environment variables:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbG...
```

---

## Offline-First Architecture

### Sync Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    OFFLINE SYNC FLOW                     │
└─────────────────────────────────────────────────────────┘

User Action (Offline)
       ↓
┌─────────────────┐
│ Update Local DB │ ← Drift (SQLite)
└─────────────────┘
       ↓
┌─────────────────┐
│ Add to Sync     │ ← sync_queue table
│     Queue       │
└─────────────────┘
       ↓
[Wait for Connection]
       ↓
┌─────────────────┐
│ Sync Service    │ ← Background process
│     Detects     │
│   Connectivity  │
└─────────────────┘
       ↓
┌─────────────────┐
│ Process Queue   │ ← One by one
│   (Retry Logic) │
└─────────────────┘
       ↓
┌─────────────────┐
│ Supabase API    │ ← POST/PUT/DELETE
└─────────────────┘
       ↓
┌─────────────────┐
│ Mark as Synced  │ ← Update sync_queue
│   or Failed     │
└─────────────────┘
```

### Sync Service Implementation

```dart
// lib/services/sync_service.dart
class SyncService {
  final SyncQueueRepository syncQueueRepo;
  final NetworkInfo networkInfo;
  
  StreamSubscription? connectivitySubscription;
  
  void initialize() {
    // Listen to connectivity changes
    connectivitySubscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        _processSyncQueue();
      }
    });
  }
  
  Future<void> _processSyncQueue() async {
    final pendingItems = await syncQueueRepo.getPending();
    
    for (final item in pendingItems) {
      try {
        await _syncItem(item);
        await syncQueueRepo.markAsCompleted(item.id);
      } catch (e) {
        await syncQueueRepo.incrementRetry(item.id);
      }
    }
  }
  
  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case 'INSERT':
        await _performInsert(item);
        break;
      case 'UPDATE':
        await _performUpdate(item);
        break;
      case 'DELETE':
        await _performDelete(item);
        break;
    }
  }
}
```

### Drift Database Schema (Local)

```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Products,
  Categories,
  StockLevels,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations
      },
    );
  }
}

@TableIndex(name: 'products_tenant_idx', columns: {#tenantId})
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  RealColumn get costPrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get reorderPoint => integer()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
```

---

## Security Strategy

### Multi-Layer Security

#### 1. Authentication (Supabase Auth)
- Email/password with bcrypt hashing
- JWT tokens (1 hour expiry)
- Refresh tokens (7 days)
- Password reset via email

#### 2. Authorization (RBAC + RLS)
```sql
-- Role-based access control in RLS policies
CREATE POLICY owner_full_access ON products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenant_users tu
            WHERE tu.tenant_id = products.tenant_id
            AND tu.user_id = auth.uid()
            AND tu.role = 'owner'
        )
    );

CREATE POLICY manager_read_only ON products
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tenant_users tu
            WHERE tu.tenant_id = products.tenant_id
            AND tu.user_id = auth.uid()
            AND tu.role IN ('owner', 'manager')
        )
    );
```

#### 3. Data Isolation (Tenant Scoping)
- Every query filtered by `tenant_id`
- RLS prevents cross-tenant access
- Application layer enforces same rule

#### 4. Audit Logging
```dart
// Every mutation creates audit log
class AuditLog {
  final String userId;
  final String action; // CREATE, UPDATE, DELETE
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String ipAddress;
  final DateTime timestamp;
}
```

#### 5. Input Validation
- Server-side validation (PostgreSQL constraints)
- Client-side validation (form validators)
- SQL injection prevention (parameterized queries)

---

## Development Setup (Ubuntu + 4GB RAM)

### Step 1: Install Flutter SDK (Optimized)

```bash
# Navigate to home directory
cd ~

# Download Flutter (stable version, optimized for low RAM)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz -O flutter.tar.xz

# Extract (this takes a few minutes)
tar xf flutter.tar.xz

# Remove archive to save space
rm flutter.tar.xz

# Add Flutter to PATH
echo '' >> ~/.bashrc
echo '# Flutter SDK' >> ~/.bashrc
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
echo 'export PUB_CACHE="$HOME/.pub-cache"' >> ~/.bashrc

# Apply changes
source ~/.bashrc

# Verify installation
flutter --version

# Run doctor (fix any reported issues)
flutter doctor
```

### Step 2: Configure Flutter for Low RAM

```bash
# Disable analytics (saves resources)
flutter config --disable-analytics

# Enable web support
flutter config --enable-web

# Set compiler optimizations for low RAM
export FLUTTER_WEB_USE_SKIA=false

# Limit concurrent compilation jobs
export DART_VM_OPTIONS="--max-old-space-size=2048"
```

### Step 3: Install VS Code Extensions

Open VS Code and install these extensions (minimal set):

1. **Dart** (by Dart Code) - Required
2. **Flutter** (by Dart Code) - Required
3. **GitLens** - Git integration
4. **Error Lens** - Inline error display
5. **Pubspec Assist** - Dependency management

DO NOT install:
- Android Studio extensions
- Emulator extensions
- Heavy theme extensions

### Step 4: Clone and Setup Project

```bash
cd /workspace/hardwareos

# Initialize Flutter project (web-only for low RAM)
flutter create --org com.hardwareos --platforms web .

# Get dependencies
flutter pub get

# Run code generation (for Drift, JSON, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 5: Optimize VS Code for 4GB RAM

Create `.vscode/settings.json`:

```json
{
  "dart.previewFlutterUiGuides": false,
  "dart.previewFlutterUiGuidesCustomTracking": false,
  "dart.flutterOutline": false,
  "editor.minimap.enabled": false,
  "editor.renderWhitespace": "none",
  "workbench.list.smoothScrolling": false,
  "editor.smoothScrolling": false,
  "terminal.integrated.smoothScrolling": false,
  "git.autofetch": false,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true,
    "**/build/**": true,
    "**/.dart_tool/**": true
  }
}
```

### Step 6: Run Development Server

```bash
cd /workspace/hardwareos

# Run on Chrome (HTML renderer for low RAM)
flutter run -d chrome --web-renderer html

# Or run with specific port
flutter run -d chrome --web-renderer html --web-port 61234
```

### Step 7: Memory Optimization Tips

```bash
# Before running Flutter, close unnecessary applications

# Monitor RAM usage
htop

# If RAM is critically low, clear caches
flutter clean
flutter pub get

# Build only what you need (avoid full builds during development)
flutter run --profile  # For performance testing
flutter run --release  # Only for production builds
```

### Step 8: Physical Device Testing (Optional)

If you have an Android phone:

```bash
# Enable USB debugging on phone

# Connect via USB
adb devices

# Run on physical device (more efficient than emulator)
flutter run -d <device_id>
```

### Step 9: Git Workflow

```bash
# Initialize git (already done based on workspace)
git status

# Create feature branches
git checkout -b feature/auth-module

# Commit frequently
git add .
git commit -m "feat: implement login page"

# Push to GitHub (free private repos)
git remote add origin https://github.com/yourusername/hardwareos.git
git push -u origin main
```

---

## Next Steps

After completing this setup:

1. ✅ **Module 1: Authentication** - Login, signup, tenant selection
2. ✅ **Module 2: Inventory** - Product CRUD, stock management
3. ✅ **Module 3: Procurement** - Purchase requests, orders, receiving
4. ✅ **Module 4: Sales** - Quotations, invoices
5. ✅ **Module 5: Warehouse** - Stock movements, transfers
6. ✅ **Module 6: Dashboard** - Analytics, reports
7. ✅ **Offline Sync** - Background synchronization
8. ✅ **Deployment** - Cloudflare Pages + Supabase

---

**Remember:** This is a marathon, not a sprint. Build one module at a time, test thoroughly, and iterate based on real user feedback.

Let's build something great! 🚀
