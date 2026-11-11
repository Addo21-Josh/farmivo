import 'package:flutter/material.dart';

/// Standard agricultural activity types tailored for West African and tropical farming.
enum ActivityType {
  landPreparation,
  planting,
  weeding,
  spraying,
  fertilizing,
  irrigation,
  feeding,
  vaccination,
  harvesting,
  maintenance;

  /// String code stored in SQLite.
  String get code {
    switch (this) {
      case ActivityType.landPreparation:
        return 'LAND_PREPARATION';
      case ActivityType.planting:
        return 'PLANTING';
      case ActivityType.weeding:
        return 'WEEDING';
      case ActivityType.spraying:
        return 'SPRAYING';
      case ActivityType.fertilizing:
        return 'FERTILIZING';
      case ActivityType.irrigation:
        return 'IRRIGATION';
      case ActivityType.feeding:
        return 'FEEDING';
      case ActivityType.vaccination:
        return 'VACCINATION';
      case ActivityType.harvesting:
        return 'HARVESTING';
      case ActivityType.maintenance:
        return 'MAINTENANCE';
    }
  }

  /// Human-readable label for UI.
  String get displayName {
    switch (this) {
      case ActivityType.landPreparation:
        return 'Land Preparation';
      case ActivityType.planting:
        return 'Planting & Sowing';
      case ActivityType.weeding:
        return 'Weeding & Slashing';
      case ActivityType.spraying:
        return 'Spraying & Crop Care';
      case ActivityType.fertilizing:
        return 'Fertilizing & Manure';
      case ActivityType.irrigation:
        return 'Irrigation & Watering';
      case ActivityType.feeding:
        return 'Feeding & Nutrition';
      case ActivityType.vaccination:
        return 'Vaccination & Health';
      case ActivityType.harvesting:
        return 'Harvesting';
      case ActivityType.maintenance:
        return 'General Maintenance';
    }
  }

  /// Visual icon for cards and lists.
  IconData get icon {
    switch (this) {
      case ActivityType.landPreparation:
        return Icons.terrain;
      case ActivityType.planting:
        return Icons.spa;
      case ActivityType.weeding:
        return Icons.content_cut;
      case ActivityType.spraying:
        return Icons.pest_control;
      case ActivityType.fertilizing:
        return Icons.eco;
      case ActivityType.irrigation:
        return Icons.water_drop;
      case ActivityType.feeding:
        return Icons.pets;
      case ActivityType.vaccination:
        return Icons.medication;
      case ActivityType.harvesting:
        return Icons.agriculture;
      case ActivityType.maintenance:
        return Icons.build;
    }
  }

  /// Common operation suggestions for rapid auto-completion in the UI.
  List<String> get suggestedTitles {
    switch (this) {
      case ActivityType.landPreparation:
        return const [
          'Tractor Ploughing',
          'Bush Clearing & De-stumping',
          'Harrowing & Levelling',
          'Bed & Ridge Construction',
        ];
      case ActivityType.planting:
        return const [
          'Direct Seed Sowing',
          'Transplanting Seedlings',
          'Nursery Seedbed Sowing',
          'Gap Filling / Supplying',
        ];
      case ActivityType.weeding:
        return const [
          'Manual Hoe Weeding',
          'Bush Slashing & Clearing',
          'Hand Pulling Weeds',
          'Inter-row Cultivation',
        ];
      case ActivityType.spraying:
        return const [
          'Pre-emergence Herbicide Spray',
          'Post-emergence Herbicide Spray',
          'Insecticide Application (Fall Armyworm)',
          'Foliar Fungicide Spray',
        ];
      case ActivityType.fertilizing:
        return const [
          'Basal Fertilizer Application (NPK)',
          'Top Dressing (Urea)',
          'Organic Poultry Manuring',
          'Foliar Liquid Micronutrients',
        ];
      case ActivityType.irrigation:
        return const [
          'Furrow Irrigation',
          'Sprinkler System Run',
          'Drip Lines Flushing & Watering',
          'Manual Water Can Pouring',
        ];
      case ActivityType.feeding:
        return const [
          'Starter Feed Distribution',
          'Grower Mash Dispensing',
          'Fish Pellets Morning Feeding',
          'Forage / Silage Feeding',
        ];
      case ActivityType.vaccination:
        return const [
          'Routine Newcastle Disease Vaccine',
          'Gumboro Disease Vaccine',
          'Deworming & Vitamin Dosing',
          'Tick & Mite Dipping',
        ];
      case ActivityType.harvesting:
        return const [
          'Maize Cob Plucking & Stacking',
          'Soybean Pod Reaping',
          'Vegetable Harvesting & Crating',
          'Cassava Tuber Uprooting',
        ];
      case ActivityType.maintenance:
        return const [
          'Farm Fence Repair & Staking',
          'Irrigation Pump Servicing',
          'Knapsack Sprayer Cleaning & Wash',
          'Storage Barn Disinfection',
        ];
    }
  }

  /// Parses a stored code string back into [ActivityType].
  static ActivityType fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    return ActivityType.values.firstWhere(
      (type) => type.code == normalized,
      orElse: () {
        // Fallback checks for legacy or alternative names
        if (normalized.contains('PLOUGH') ||
            normalized.contains('LAND') ||
            normalized.contains('CLEAR')) {
          return ActivityType.landPreparation;
        } else if (normalized.contains('PLANT') || normalized.contains('SOW')) {
          return ActivityType.planting;
        } else if (normalized.contains('WEED') ||
            normalized.contains('SLASH')) {
          return ActivityType.weeding;
        } else if (normalized.contains('SPRAY') ||
            normalized.contains('CHEM')) {
          return ActivityType.spraying;
        } else if (normalized.contains('FERT') ||
            normalized.contains('MANURE')) {
          return ActivityType.fertilizing;
        } else if (normalized.contains('IRRIG') ||
            normalized.contains('WATER')) {
          return ActivityType.irrigation;
        } else if (normalized.contains('FEED')) {
          return ActivityType.feeding;
        } else if (normalized.contains('VACC') || normalized.contains('MED')) {
          return ActivityType.vaccination;
        } else if (normalized.contains('HARVEST')) {
          return ActivityType.harvesting;
        }
        return ActivityType.maintenance;
      },
    );
  }
}
