import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'route_guards.dart';
import 'scaffold_with_nav_bar.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/farms/farms.dart';
import '../../features/projects/projects.dart';
import '../../features/budgets/budgets.dart';
import '../../features/expenses/expenses.dart';
import '../../features/activities/activities.dart';
import '../../features/harvests/harvests.dart';
import '../../features/buyers/buyers.dart';
import '../../features/sales/sales.dart';
import '../../features/payments/payments.dart';
import '../../features/reports/reports.dart';
import '../../features/settings/settings.dart';
import '../../features/authentication/authentication.dart';
import '../../features/backup/backup.dart';
import '../../features/audit/audit.dart';
import '../../features/onboarding/onboarding.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Execute security and onboarding guards
      return appRouteRedirect(state, ref);
    },
    routes: [
      // 5-Tab Persistent Stateful Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 2: Projects Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                builder: (context, state) => const ProjectsScreen(),
              ),
            ],
          ),

          // Branch 3: Transactions Ledger
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),

          // Branch 4: Reports & Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Branch 5: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Project Sub-Routes (Covering full screen)
      GoRoute(
        path: AppRoutes.projectComparison,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProjectComparisonScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProject,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final farmId = state.uri.queryParameters['farmId'];
          return CreateProjectScreen(initialFarmId: farmId);
        },
      ),
      GoRoute(
        path: AppRoutes.editProject,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return CreateProjectScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.projectDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),

      // Farm Management Routes
      GoRoute(
        path: AppRoutes.farms,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FarmsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createFarm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FarmFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final farmId = state.pathParameters['farmId'] ?? '';
          return FarmDetailScreen(farmId: farmId);
        },
      ),
      GoRoute(
        path: AppRoutes.editFarm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final farmId = state.pathParameters['farmId'] ?? '';
          return FarmFormScreen(farmId: farmId);
        },
      ),

      // Budget Taxonomy Management Route
      GoRoute(
        path: AppRoutes.budgetCategories,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BudgetCategoriesScreen(),
      ),

      // Security & PIN Lock Settings Route
      GoRoute(
        path: AppRoutes.securitySettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),

      // Local Database Backup & Restore Route
      GoRoute(
        path: AppRoutes.backup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BackupScreen(),
      ),

      // Immutable Audit Trail Route (Milestone 9.3)
      GoRoute(
        path: AppRoutes.auditLogs,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuditLogScreen(),
      ),

      // Quick Transaction Entry Routes
      GoRoute(
        path: AppRoutes.addExpense,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId =
              state.uri.queryParameters['projectId'] ??
              (state.extra is String ? state.extra as String : null);
          return AddExpenseScreen(initialProjectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.addSale,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          String? projectId = query['projectId'];
          String? harvestId = query['harvestId'];
          String? buyerId = query['buyerId'];
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            projectId ??= extra['projectId'] as String?;
            harvestId ??= extra['harvestId'] as String?;
            buyerId ??= extra['buyerId'] as String?;
          } else if (state.extra is String) {
            projectId ??= state.extra as String;
          }
          return RecordSaleScreen(
            initialProjectId: projectId,
            initialHarvestId: harvestId,
            initialBuyerId: buyerId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addPayment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final querySaleId = state.uri.queryParameters['saleId'];
          String? saleId = querySaleId;
          SaleWithDetails? sale;
          if (state.extra is SaleWithDetails) {
            sale = state.extra as SaleWithDetails;
            saleId = sale.sale.id;
          } else if (state.extra is String) {
            saleId = state.extra as String;
          }
          return RecordPaymentScreen(initialSale: sale, initialSaleId: saleId);
        },
      ),
      GoRoute(
        path: AppRoutes.addActivity,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId =
              state.uri.queryParameters['projectId'] ??
              (state.extra is String ? state.extra as String : null);
          return RecordActivityScreen(initialProjectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.addHarvest,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId =
              state.uri.queryParameters['projectId'] ??
              (state.extra is String ? state.extra as String : null);
          return RecordHarvestScreen(initialProjectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.buyers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BuyersDirectoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.buyerDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final buyerId = state.pathParameters['buyerId'] ?? '';
          return BuyerDetailScreen(buyerId: buyerId);
        },
      ),
      GoRoute(
        path: AppRoutes.pdfReportPreview,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return PdfReportPreviewScreen(projectId: projectId);
        },
      ),

      // Security Lock & Onboarding Fullscreen Routes
      GoRoute(
        path: AppRoutes.lock,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});
