class AppFeatureFlags {
  final bool showStatistics;
  final bool showFineBox;

  const AppFeatureFlags({
    this.showStatistics = false,
    this.showFineBox = false,
  });

  factory AppFeatureFlags.fromJson(Map<String, dynamic> json) {
    return AppFeatureFlags(
      showStatistics: json['statistics'] == true,
      showFineBox: json['fine_box'] == true,
    );
  }
}
