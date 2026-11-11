import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../app/theme/app_theme_extension.dart';

/// Outdoor-friendly status badge that NEVER uses color alone to communicate state.
/// Always combines accessible background tinting with a recognizable icon and explicit label.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  /// Factory for Project Health status (Healthy, Watch, At Risk).
  factory AppStatusBadge.fromHealth(
    BuildContext context,
    ProjectHealthStatus status,
  ) {
    final colors = context.appColors;
    switch (status) {
      case ProjectHealthStatus.healthy:
        return AppStatusBadge(
          label: 'Healthy',
          icon: Icons.check_circle_outline,
          foregroundColor: colors.healthGreen,
          backgroundColor: colors.healthGreenBg,
        );
      case ProjectHealthStatus.watch:
        return AppStatusBadge(
          label: 'Watch',
          icon: Icons.warning_amber_outlined,
          foregroundColor: colors.healthYellow,
          backgroundColor: colors.healthYellowBg,
        );
      case ProjectHealthStatus.atRisk:
        return AppStatusBadge(
          label: 'At Risk',
          icon: Icons.error_outline,
          foregroundColor: colors.healthRed,
          backgroundColor: colors.healthRedBg,
        );
    }
  }

  /// Factory for Project Lifecycle status from a string representation (e.g. 'PLANNING', 'ACTIVE').
  factory AppStatusBadge.fromStatusString(BuildContext context, String status) {
    final clean = status.toUpperCase().trim();
    switch (clean) {
      case 'PLANNING':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.planning,
        );
      case 'ACTIVE':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.active,
        );
      case 'PRODUCTION':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.production,
        );
      case 'HARVESTING':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.harvesting,
        );
      case 'SELLING':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.selling,
        );
      case 'COMPLETED':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.completed,
        );
      case 'ARCHIVED':
        return AppStatusBadge.fromLifecycle(
          context,
          ProjectLifecycleState.archived,
        );
      default:
        return AppStatusBadge(
          label: status,
          icon: Icons.info_outline,
          foregroundColor: const Color(0xFF475569),
          backgroundColor: const Color(0xFFF1F5F9),
        );
    }
  }

  /// Factory for Project Lifecycle status (Planning, Active, Harvesting, etc.).
  factory AppStatusBadge.fromLifecycle(
    BuildContext context,
    ProjectLifecycleState state,
  ) {
    switch (state) {
      case ProjectLifecycleState.planning:
        return const AppStatusBadge(
          label: 'Planning',
          icon: Icons.edit_note,
          foregroundColor: Color(0xFF1D4ED8),
          backgroundColor: Color(0xFFDBEAFE),
        );
      case ProjectLifecycleState.active:
      case ProjectLifecycleState.production:
        return const AppStatusBadge(
          label: 'Active',
          icon: Icons.play_arrow,
          foregroundColor: Color(0xFF15803D),
          backgroundColor: Color(0xFFDCFCE7),
        );
      case ProjectLifecycleState.harvesting:
        return const AppStatusBadge(
          label: 'Harvesting',
          icon: Icons.agriculture,
          foregroundColor: Color(0xFFB45309),
          backgroundColor: Color(0xFFFEF3C7),
        );
      case ProjectLifecycleState.selling:
        return const AppStatusBadge(
          label: 'Selling',
          icon: Icons.storefront,
          foregroundColor: Color(0xFF7E22CE),
          backgroundColor: Color(0xFFF3E8FF),
        );
      case ProjectLifecycleState.completed:
        return const AppStatusBadge(
          label: 'Completed',
          icon: Icons.task_alt,
          foregroundColor: Color(0xFF374151),
          backgroundColor: Color(0xFFE5E7EB),
        );
      case ProjectLifecycleState.archived:
        return const AppStatusBadge(
          label: 'Archived',
          icon: Icons.archive_outlined,
          foregroundColor: Color(0xFF6B7280),
          backgroundColor: Color(0xFFF3F4F6),
        );
    }
  }

  /// Factory for Payment Receivables status (Paid, Partial, Unpaid).
  factory AppStatusBadge.fromPaymentStatus(
    BuildContext context,
    String status,
  ) {
    final colors = context.appColors;
    final normalized = status.toUpperCase().trim();
    if (normalized == 'PAID') {
      return AppStatusBadge(
        label: 'Paid',
        icon: Icons.check,
        foregroundColor: colors.cashIn,
        backgroundColor: colors.cashInBg,
      );
    } else if (normalized == 'PARTIAL') {
      return AppStatusBadge(
        label: 'Partial',
        icon: Icons.timelapse,
        foregroundColor: colors.creditPending,
        backgroundColor: colors.creditPendingBg,
      );
    } else {
      return AppStatusBadge(
        label: 'Credit / Unpaid',
        icon: Icons.schedule,
        foregroundColor: colors.cashOut,
        backgroundColor: colors.cashOutBg,
      );
    }
  }

  /// Factory for Customary Land Tenure status (Owned, Family Land, Rented, Leased, Abunu, Abusa, Other).
  factory AppStatusBadge.fromTenure(BuildContext context, String tenure) {
    final clean = tenure.toLowerCase();
    if (clean.contains('owned') || clean.contains('freehold')) {
      return const AppStatusBadge(
        label: 'Owned',
        icon: Icons.verified_user,
        foregroundColor: Color(0xFF15803D),
        backgroundColor: Color(0xFFDCFCE7),
      );
    } else if (clean.contains('family')) {
      return const AppStatusBadge(
        label: 'Family Land',
        icon: Icons.people_outline,
        foregroundColor: Color(0xFF0F766E),
        backgroundColor: Color(0xFFCCFBF1),
      );
    } else if (clean.contains('rented')) {
      return const AppStatusBadge(
        label: 'Rented',
        icon: Icons.timelapse,
        foregroundColor: Color(0xFFB45309),
        backgroundColor: Color(0xFFFEF3C7),
      );
    } else if (clean.contains('leased')) {
      return const AppStatusBadge(
        label: 'Leased',
        icon: Icons.article_outlined,
        foregroundColor: Color(0xFF1D4ED8),
        backgroundColor: Color(0xFFDBEAFE),
      );
    } else if (clean.contains('abunu')) {
      return const AppStatusBadge(
        label: 'Abunu (50/50)',
        icon: Icons.handshake_outlined,
        foregroundColor: Color(0xFF7E22CE),
        backgroundColor: Color(0xFFF3E8FF),
      );
    } else if (clean.contains('abusa')) {
      return const AppStatusBadge(
        label: 'Abusa (1/3)',
        icon: Icons.pie_chart_outline,
        foregroundColor: Color(0xFF4338CA),
        backgroundColor: Color(0xFFE0E7FF),
      );
    } else {
      return AppStatusBadge(
        label: tenure,
        icon: Icons.landscape_outlined,
        foregroundColor: const Color(0xFF475569),
        backgroundColor: const Color(0xFFF1F5F9),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: foregroundColor.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
