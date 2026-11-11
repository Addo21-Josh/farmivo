import 'package:flutter/material.dart';

/// Predefined standard taxonomy for agricultural budgeting in West Africa.
class BudgetCategoryPreset {
  final String name;
  final String description;
  final String iconName;
  final int displayOrder;

  const BudgetCategoryPreset({
    required this.name,
    required this.description,
    required this.iconName,
    required this.displayOrder,
  });

  static const List<BudgetCategoryPreset> standardPresets = [
    BudgetCategoryPreset(
      name: 'Land Preparation',
      description:
          'Bush clearing, tractor ploughing, harrowing, ridging, and seedbed preparation.',
      iconName: 'agriculture',
      displayOrder: 1,
    ),
    BudgetCategoryPreset(
      name: 'Seeds & Seedlings',
      description:
          'Certified seeds, hybrid seedlings, cuttings, nursery trays, and plantlets.',
      iconName: 'grass',
      displayOrder: 2,
    ),
    BudgetCategoryPreset(
      name: 'Fertilizers & Nutrients',
      description:
          'NPK, Urea, compost, organic manure, lime, and foliar crop nutrition.',
      iconName: 'science',
      displayOrder: 3,
    ),
    BudgetCategoryPreset(
      name: 'Agro-Chemicals & Spraying',
      description:
          'Selective herbicides, insecticides, fungicides, and sprayer services.',
      iconName: 'pest_control',
      displayOrder: 4,
    ),
    BudgetCategoryPreset(
      name: 'Feed & Animal Nutrition',
      description:
          'Broiler/layer mash, fish feed pellets, mineral supplements, and vet supplies.',
      iconName: 'pets',
      displayOrder: 5,
    ),
    BudgetCategoryPreset(
      name: 'Labour (Field Operations)',
      description:
          'Casual wages for planting, manual weeding, spraying, and field maintenance.',
      iconName: 'groups',
      displayOrder: 6,
    ),
    BudgetCategoryPreset(
      name: 'Labour (Harvesting & Packing)',
      description:
          'Casual workers for harvest picking, sorting, grading, and produce bagging.',
      iconName: 'handshake',
      displayOrder: 7,
    ),
    BudgetCategoryPreset(
      name: 'Equipment & Machinery',
      description:
          'Tractor rental, knapsack sprayers, tillers, tool maintenance, and equipment hire.',
      iconName: 'precision_manufacturing',
      displayOrder: 8,
    ),
    BudgetCategoryPreset(
      name: 'Irrigation & Water',
      description:
          'Water pump fuel, borehole fees, drip lines, hoses, and irrigation fittings.',
      iconName: 'water_drop',
      displayOrder: 9,
    ),
    BudgetCategoryPreset(
      name: 'Logistics & Transport',
      description:
          'Farm-gate haulage, tricycle cartage, market freight, and fuel expenses.',
      iconName: 'local_shipping',
      displayOrder: 10,
    ),
    BudgetCategoryPreset(
      name: 'Storage & Packaging',
      description:
          'Burlap sacks, produce crates, bagging twines, and warehousing storage fees.',
      iconName: 'inventory_2',
      displayOrder: 11,
    ),
    BudgetCategoryPreset(
      name: 'Utilities & Overheads',
      description:
          'Security watchmen, farm electricity, water levies, and land tenure rents.',
      iconName: 'bolt',
      displayOrder: 12,
    ),
    BudgetCategoryPreset(
      name: 'Contingency & Miscellaneous',
      description:
          'Buffer capital for unexpected price fluctuations and emergency farm repairs.',
      iconName: 'more_horiz',
      displayOrder: 13,
    ),
  ];
}

/// Helper mapping string icon keys to Material [IconData].
class BudgetCategoryIconHelper {
  BudgetCategoryIconHelper._();

  static const Map<String, IconData> availableIcons = {
    'agriculture': Icons.agriculture,
    'grass': Icons.grass,
    'science': Icons.science_outlined,
    'pest_control': Icons.pest_control_outlined,
    'pets': Icons.pets_outlined,
    'groups': Icons.groups_outlined,
    'handshake': Icons.handshake_outlined,
    'precision_manufacturing': Icons.precision_manufacturing_outlined,
    'water_drop': Icons.water_drop_outlined,
    'local_shipping': Icons.local_shipping_outlined,
    'inventory_2': Icons.inventory_2_outlined,
    'bolt': Icons.bolt_outlined,
    'more_horiz': Icons.more_horiz,
    'eco': Icons.eco_outlined,
    'construction': Icons.construction_outlined,
    'local_florist': Icons.local_florist_outlined,
    'park': Icons.park_outlined,
    'fence': Icons.fence_outlined,
    'warehouse': Icons.warehouse_outlined,
    'sell': Icons.sell_outlined,
  };

  /// Returns the matching [IconData] or a safe fallback.
  static IconData getIcon(String? iconName) {
    if (iconName == null) return Icons.category_outlined;
    return availableIcons[iconName.trim().toLowerCase()] ??
        Icons.category_outlined;
  }
}
