class AppFeatureFlags {
  final bool showStatistics;
  final bool showFineBox;
  final bool maintenanceMode;
  final bool updateRequired;
  final int minimumRequiredBuildNumber;
  final int? currentBuildNumber;

  const AppFeatureFlags({
    this.showStatistics = false,
    this.showFineBox = false,
    this.maintenanceMode = false,
    this.updateRequired = false,
    this.minimumRequiredBuildNumber = 0,
    this.currentBuildNumber,
  });

  factory AppFeatureFlags.fromJson(
    Map<String, dynamic> json, {
    int? currentBuildNumber,
  }) {
    final minimumRequiredBuildNumber =
        _intFromJson(json['minimum_required_build_number']) ?? 0;
    final serverRequiresUpdate = json['update_required'] == true;
    final buildRequiresUpdate = currentBuildNumber != null &&
        minimumRequiredBuildNumber > 0 &&
        currentBuildNumber < minimumRequiredBuildNumber;

    return AppFeatureFlags(
      showStatistics: json['statistics'] == true,
      showFineBox: json['fine_box'] == true,
      maintenanceMode: json['maintenance'] == true,
      updateRequired: serverRequiresUpdate || buildRequiresUpdate,
      minimumRequiredBuildNumber: minimumRequiredBuildNumber,
      currentBuildNumber: currentBuildNumber,
    );
  }

  AppFeatureFlags copyWith({
    bool? showStatistics,
    bool? showFineBox,
    bool? maintenanceMode,
    bool? updateRequired,
    int? minimumRequiredBuildNumber,
    int? currentBuildNumber,
  }) {
    return AppFeatureFlags(
      showStatistics: showStatistics ?? this.showStatistics,
      showFineBox: showFineBox ?? this.showFineBox,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      updateRequired: updateRequired ?? this.updateRequired,
      minimumRequiredBuildNumber:
          minimumRequiredBuildNumber ?? this.minimumRequiredBuildNumber,
      currentBuildNumber: currentBuildNumber ?? this.currentBuildNumber,
    );
  }

  static int? _intFromJson(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
