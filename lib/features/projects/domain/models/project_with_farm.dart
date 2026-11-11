import '../../../../data/database/app_database.dart';

/// Presentation domain aggregate bundling a [Project] with its associated [Farm].
class ProjectWithFarm {
  final Project project;
  final Farm? farm;

  const ProjectWithFarm({required this.project, this.farm});

  String get displayName => project.name;
  String get farmName => farm?.name ?? 'Unassigned Farm';
  String get locationSummary => farm != null
      ? '${farm!.location} • ${farm!.region}'
      : 'Location unrecorded';
}
