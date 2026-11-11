import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/money/money.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/money_display.dart';
import '../../../activities/activities.dart';
import '../../domain/models/project_metrics.dart';

/// Sub-navigation tab presenting agronomic field operations, casual labour,
/// and linked financial ledger tracking.
class ProjectActivitiesTab extends ConsumerWidget {
  final Project project;
  final ProjectMetrics metrics;

  const ProjectActivitiesTab({
    super.key,
    required this.project,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final activitiesAsync = ref.watch(
      projectActivitiesWithDetailsProvider(project.id),
    );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 60),
      children: [
        // 1. Activities Summary Card
        activitiesAsync.maybeWhen(
          data: (activities) {
            int totalWorkers = 0;
            BigInt totalCostMinor = BigInt.zero;
            for (final act in activities) {
              totalWorkers += act.labourCount;
              totalCostMinor += BigInt.from(act.costMinor);
            }
            final totalCost = Money(totalCostMinor, currency: project.currency);

            return AppCard(
              title: 'Agronomic Operations',
              subtitle: 'Field operations & casual labour logs',
              leadingIcon: const Icon(Icons.agriculture_outlined),
              trailingAction: FilledButton.icon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () => context.push(
                  '${AppRoutes.addActivity}?projectId=${project.id}',
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Activity'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activities.length} Operations',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalWorkers casual workers engaged',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (totalCostMinor > BigInt.zero)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Operation Costs',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            MoneyDisplay(
                              money: totalCost,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.healthRed,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
          orElse: () => AppCard(
            title: 'Agronomic Operations',
            subtitle: 'Field operations & casual labour logs',
            leadingIcon: const Icon(Icons.agriculture_outlined),
            child: Text('${metrics.activitiesCount} Field Activities Logged'),
          ),
        ),

        // 2. Activities Timeline Stream
        activitiesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading activities: $err'),
          ),
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.park_outlined,
                      size: 48,
                      color: theme.colorScheme.primary.withAlpha(160),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Field Activities Logged',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Document agronomic field operations, casual labour headcounts, and completion dates.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: () => context.push(
                        '${AppRoutes.addActivity}?projectId=${project.id}',
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Log Field Activity'),
                    ),
                  ],
                ),
              );
            }

            return AppCard(
              title: 'Agronomic Timeline',
              subtitle: '${activities.length} completed operations',
              leadingIcon: const Icon(Icons.history_outlined),
              child: Column(
                children: activities
                    .map((act) => ActivityTile(activity: act))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
