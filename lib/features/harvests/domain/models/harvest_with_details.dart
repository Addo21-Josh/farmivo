import 'package:farmivo/core/extensions/date_time_extensions.dart';
import 'package:farmivo/data/database/app_database.dart';
import 'package:farmivo/features/harvests/domain/models/harvest_grade.dart';

/// Projection uniting a physical [Harvest] batch with its parent [Project].
class HarvestWithDetails {
  final Harvest harvest;
  final Project? project;

  const HarvestWithDetails({required this.harvest, this.project});

  String get id => harvest.id;
  String get projectId => harvest.projectId;
  String get batchNumber => harvest.batchNumber;
  int get harvestDateTimestamp => harvest.harvestDate;
  DateTime get harvestDate =>
      DateTime.fromMillisecondsSinceEpoch(harvest.harvestDate);
  String get productName => harvest.productName;
  double get quantity => harvest.quantity;
  String get unit => harvest.unit;
  String? get gradeCode => harvest.grade;
  String? get storageLocation => harvest.storageLocation;
  String? get notes => harvest.notes;
  String? get photoPath => harvest.photoPath;
  bool get isDeleted => harvest.isDeleted;
  int get createdAt => harvest.createdAt;
  int get updatedAt => harvest.updatedAt;

  /// Parsed typed [HarvestGrade] domain enum.
  HarvestGrade get grade => HarvestGrade.fromCode(harvest.grade);

  /// Clean formatted quantity string (e.g., '120 Bags' or '12.5 kg').
  String get formattedQuantity {
    final cleanQty = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$cleanQty $unit';
  }

  /// Clean display date formatted for UI.
  String get formattedDate => harvestDate.toDisplayDate();

  /// Associated project name or fallback.
  String get projectName => project?.name ?? 'Unknown Project';

  /// Associated commodity or fallback.
  String get commodity => project?.commodity ?? '';
}
