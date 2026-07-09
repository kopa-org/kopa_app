class DbuStandings {
  final int? poolId;
  final int? currentTeamId;
  final String? seriesName;
  final List<DbuStandingRow> rows;

  const DbuStandings({
    this.poolId,
    this.currentTeamId,
    this.seriesName,
    this.rows = const [],
  });

  factory DbuStandings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DbuStandings();

    final poolTeams = (json['poolTeams'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    final logoUrlsByTeamId = <int, String?>{
      for (final team in poolTeams)
        if (_asInt(team['dbu_team_id'] ?? team['dbuTeamId']) case final int id)
          id: team['logo_url'] as String? ?? team['logoUrl'] as String?,
    };

    return DbuStandings(
      poolId: json['poolId'],
      currentTeamId: json['currentTeamId'],
      seriesName: json['seriesName'] ?? json['series_name'],
      rows: (json['rows'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => DbuStandingRow.fromJson({
              ...row,
              'logoUrl': row['logoUrl'] ??
                  row['logo_url'] ??
                  logoUrlsByTeamId[_asInt(row['dbuTeamId'])],
            }),
          )
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
  final String? logoUrl;

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
    this.logoUrl,
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
      logoUrl: json['logoUrl'] as String?,
    );
  }
}

int? _asInt(Object? value) => switch (value) {
      int value => value,
      String value => int.tryParse(value),
      _ => null,
    };
