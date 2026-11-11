import 'package:flutter/material.dart';

/// Global application constants, standard units, and taxonomic enums for Farmivo.
class AppConstants {
  AppConstants._();

  static const String appName = 'Farm Project Manager';
  static const String appPackage = 'farmivo';
  static const String defaultCurrency = 'GHS';

  /// Supported primary African and international currencies
  static const List<String> supportedCurrencies = [
    'GHS', // Ghanaian Cedi
    'NGN', // Nigerian Naira
    'KES', // Kenyan Shilling
    'UGX', // Ugandan Shilling
    'TZS', // Tanzanian Shilling
    'ZAR', // South African Rand
    'XOF', // West African CFA Franc
    'XAF', // Central African CFA Franc
    'USD', // US Dollar
    'EUR', // Euro
  ];

  /// Standard Land Area Units
  static const List<String> landUnits = [
    'Acre',
    'Hectare',
    'Square Metre',
    'Plot',
  ];

  /// Standard Weight & Quantity Units
  static const List<String> weightUnits = [
    'kg',
    '50kg Bag',
    '100kg Bag',
    'Tonne',
    'Crate',
    'Gram',
  ];

  /// Standard Livestock Units
  static const List<String> livestockUnits = [
    'Bird',
    'Goat',
    'Sheep',
    'Cow',
    'Pig',
    'Rabbit',
  ];

  /// Standard Volume Units
  static const List<String> volumeUnits = ['Litre', 'Millilitre', 'Gallon'];

  /// Common West African Land Tenure Types
  static const List<String> landTenureTypes = [
    'Owned (Freehold)',
    'Family Land',
    'Rented (Short-term)',
    'Leased (Long-term)',
    'Shared / Abunu',
    'Shared / Abusa',
    'Other',
  ];

  /// 16 Administrative Regions of Ghana
  static const List<String> ghanaRegions = [
    'Ahafo',
    'Ashanti',
    'Bono',
    'Bono East',
    'Central',
    'Eastern',
    'Greater Accra',
    'Northern',
    'North East',
    'Oti',
    'Savannah',
    'Upper East',
    'Upper West',
    'Volta',
    'Western',
    'Western North',
  ];

  /// Default Crop Commodities
  static const List<String> defaultCrops = [
    'Pepper',
    'Maize',
    'Tomato',
    'Okra',
    'Cassava',
    'Yam',
    'Rice',
    'Onion',
    'Soybean',
    'Groundnut',
    'Cocoa',
    'Oil Palm',
    'Plantain',
    'Watermelon',
  ];

  /// Default Livestock Commodities
  static const List<String> defaultLivestock = [
    'Poultry (Broilers)',
    'Poultry (Layers)',
    'Goats',
    'Sheep',
    'Cattle',
    'Pigs',
    'Rabbits',
  ];

  /// Default Aquaculture Commodities
  static const List<String> defaultAquaculture = ['Tilapia', 'Catfish'];

  /// Supported Project Types
  static const List<String> projectTypes = [
    'Crop',
    'Livestock',
    'Aquaculture',
    'Custom',
  ];

  /// Typical agronomic growth cycle duration in days (used for harvest date suggestions)
  static const Map<String, int> defaultCommodityDurations = {
    'Maize': 105,
    'Pepper': 80,
    'Tomato': 80,
    'Okra': 55,
    'Cassava': 300,
    'Yam': 270,
    'Rice': 120,
    'Onion': 110,
    'Soybean': 95,
    'Groundnut': 100,
    'Cocoa': 365,
    'Oil Palm': 365,
    'Plantain': 300,
    'Watermelon': 75,
    'Poultry (Broilers)': 45,
    'Poultry (Layers)': 180,
    'Goats': 180,
    'Sheep': 180,
    'Cattle': 365,
    'Pigs': 180,
    'Rabbits': 90,
    'Tilapia': 180,
    'Catfish': 150,
  };

  /// Standard Default Budget Categories
  static const List<String> defaultBudgetCategories = [
    'Land Preparation',
    'Seeds & Seedlings',
    'Fertilizers & Nutrients',
    'Agro-Chemicals & Spraying',
    'Labour (Land & Planting)',
    'Labour (Weeding & Maintenance)',
    'Labour (Harvesting & Packing)',
    'Irrigation & Water',
    'Equipment & Machinery',
    'Logistics & Transport',
    'Storage & Packaging',
    'Utilities & Communication',
    'Security & Miscellaneous',
  ];
}

/// Project Lifecycle States as defined in PRD Section 7
enum ProjectLifecycleState {
  planning,
  active,
  production,
  harvesting,
  selling,
  completed,
  archived,
}

extension ProjectLifecycleStateX on ProjectLifecycleState {
  String get displayName {
    switch (this) {
      case ProjectLifecycleState.planning:
        return 'Planning';
      case ProjectLifecycleState.active:
        return 'Active';
      case ProjectLifecycleState.production:
        return 'Production';
      case ProjectLifecycleState.harvesting:
        return 'Harvesting';
      case ProjectLifecycleState.selling:
        return 'Selling';
      case ProjectLifecycleState.completed:
        return 'Completed';
      case ProjectLifecycleState.archived:
        return 'Archived';
    }
  }
}

/// Project Health Ratings as defined in PRD Section 27
enum ProjectHealthStatus {
  healthy, // Green (>= 80 score)
  watch, // Yellow (60 - 79 score)
  atRisk, // Red (< 60 score)
}

extension ProjectHealthStatusX on ProjectHealthStatus {
  String get label {
    switch (this) {
      case ProjectHealthStatus.healthy:
        return 'Healthy';
      case ProjectHealthStatus.watch:
        return 'Watch';
      case ProjectHealthStatus.atRisk:
        return 'At Risk';
    }
  }

  /// Standardized icon representing health state.
  IconData get icon {
    switch (this) {
      case ProjectHealthStatus.healthy:
        return Icons.check_circle_outline;
      case ProjectHealthStatus.watch:
        return Icons.warning_amber_rounded;
      case ProjectHealthStatus.atRisk:
        return Icons.error_outline_rounded;
    }
  }
}
