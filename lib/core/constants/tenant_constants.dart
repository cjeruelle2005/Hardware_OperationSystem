/// Multi-tenant constants for HardwareOS
class TenantConstants {
  TenantConstants._();

  // Tenant ID Header
  static const String tenantIdHeader = 'X-Tenant-ID';
  
  // Default Tenant
  static const String defaultTenantId = 'default';
  
  // Tenant Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusSuspended = 'suspended';
  
  // User Roles
  static const String roleOwner = 'owner';
  static const String roleManager = 'manager';
  static const String roleSales = 'sales';
  static const String roleWarehouse = 'warehouse';
  
  // Permission Levels
  static const int permissionFull = 100;
  static const int permissionHigh = 75;
  static const int permissionMedium = 50;
  static const int permissionLow = 25;
  
  // Tenant Settings Keys
  static const String settingStoreName = 'store_name';
  static const String settingCompanyLogo = 'company_logo';
  static const String settingBranchName = 'branch_name';
  static const String settingWarehouseName = 'warehouse_name';
  static const String settingReceiptFooter = 'receipt_footer';
  static const String settingInvoiceBranding = 'invoice_branding';
  static const String settingColorAccent = 'color_accent';
  
  // Audit Trail Actions
  static const String actionCreate = 'CREATE';
  static const String actionUpdate = 'UPDATE';
  static const String actionDelete = 'DELETE';
  static const String actionView = 'VIEW';
  static const String actionExport = 'EXPORT';
}
