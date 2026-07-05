class DbuStandings {
  final int? poolId;
  final int? currentTeamId;
  final List<DbuStandingRow> rows;

  const DbuStandings({
    this.poolId,
    this.currentTeamId,
    this.rows = const [],
  });

  factory DbuStandings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DbuStandings();

    return DbuStandings(
      poolId: json['poolId'],
      currentTeamId: json['currentTeamId'],
      rows: (json['rows'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DbuStandingRow.fromJson)
          .toList(),
    );
  }
}

class DbuStandingRow {
  final int position;
  final int dbuTeamId;
  final String teamName;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final String? boundaryAfter;

  const DbuStandingRow({
    required this.position,
    required this.dbuTeamId,
    required this.teamName,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    this.boundaryAfter,
  });

  factory DbuStandingRow.fromJson(Map<String, dynamic> json) {
    return DbuStandingRow(
      position: json['position'] ?? 0,
      dbuTeamId: json['dbuTeamId'] ?? 0,
      teamName: json['teamName'] ?? '',
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      goalsFor: json['goalsFor'] ?? 0,
      goalsAgainst: json['goalsAgainst'] ?? 0,
      points: json['points'] ?? 0,
      boundaryAfter: json['boundaryAfter'],
    );
  }
}
