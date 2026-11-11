/// Declares all typed route paths and route names across Farmivo.
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String projects = '/projects';
  static const String projectComparison = '/projects/compare';
  static const String projectDetails = '/projects/:projectId';
  static const String createProject = '/projects/create';
  static const String editProject = '/projects/:projectId/edit';

  static const String farms = '/farms';
  static const String createFarm = '/farms/create';
  static const String farmDetails = '/farms/:farmId';
  static const String editFarm = '/farms/:farmId/edit';

  static const String transactions = '/transactions';
  static const String addExpense = '/transactions/expense/add';
  static const String addSale = '/transactions/sale/add';
  static const String addPayment = '/transactions/payment/add';

  static const String addActivity = '/activities/add';
  static const String addHarvest = '/harvests/add';

  static const String buyers = '/buyers';
  static const String buyerDetails = '/buyers/:buyerId';

  static const String reports = '/reports';
  static const String pdfReportPreview = '/reports/pdf-preview/:projectId';
  static const String settings = '/settings';
  static const String budgetCategories = '/settings/budget-categories';
  static const String securitySettings = '/settings/security';
  static const String backup = '/settings/backup';
  static const String auditLogs = '/settings/audit-logs';

  static const String lock = '/lock';
  static const String onboarding = '/onboarding';
}
