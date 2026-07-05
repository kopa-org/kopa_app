class PlayerPlusEntitlement {
  final bool active;
  final String status;
  final String source;
  final String provider;
  final DateTime? expiresAt;

  PlayerPlusEntitlement({
    required this.active,
    required this.status,
    required this.source,
    required this.provider,
    this.expiresAt,
  });

  factory PlayerPlusEntitlement.fromJson(Map<String, dynamic> json) {
    return PlayerPlusEntitlement(
      active: json['active'] ?? false,
      status: json['status'] ?? 'inactive',
      source: json['source'] ?? 'disabled',
      provider: json['provider'] ?? 'disabled',
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.tryParse(json['expires_at']),
    );
  }
}

class PlayerPlusTeamContext {
  final String? clubName;
  final String? dbuTeamLabel;
  final int? dbuTeamId;
  final int? dbuPoolId;
  final String? season;
  final String? region;
  final String? seriesName;
  final DateTime? dbuSyncedAt;
  final Map<String, dynamic>? standings;
  final List<Map<String, dynamic>> poolTeams;

  PlayerPlusTeamContext({
    this.clubName,
    this.dbuTeamLabel,
    this.dbuTeamId,
    this.dbuPoolId,
    this.season,
    this.region,
    this.seriesName,
    this.dbuSyncedAt,
    this.standings,
    this.poolTeams = const [],
  });

  factory PlayerPlusTeamContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PlayerPlusTeamContext();

    return PlayerPlusTeamContext(
      clubName: json['club_name'],
      dbuTeamLabel: json['dbu_team_label'],
      dbuTeamId: json['dbu_team_id'],
      dbuPoolId: json['dbu_pool_id'],
      season: json['season'],
      region: json['region'],
      seriesName: json['series_name'],
      dbuSyncedAt: json['dbu_synced_at'] == null
          ? null
          : DateTime.tryParse(json['dbu_synced_at']),
      standings: json['standings'] as Map<String, dynamic>?,
      poolTeams: (json['pool_teams'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }
}

class PlayerPlusOverview {
  final PlayerPlusEntitlement entitlement;
  final bool locked;
  final List<String> categories;
  final List<String> scopes;
  final PlayerPlusTeamContext dbuContext;

  PlayerPlusOverview({
    required this.entitlement,
    required this.locked,
    required this.categories,
    required this.scopes,
    required this.dbuContext,
  });

  factory PlayerPlusOverview.fromJson(Map<String, dynamic> json) {
    final preview = json['preview'] as Map<String, dynamic>? ?? {};

    return PlayerPlusOverview(
      entitlement: PlayerPlusEntitlement.fromJson(json['entitlement']),
      locked: json['locked'] ?? true,
      categories:
          List<String>.from(json['categories'] ?? preview['categories'] ?? []),
      scopes: List<String>.from(json['scopes'] ?? preview['scopes'] ?? []),
      dbuContext: PlayerPlusTeamContext.fromJson(json['dbu_context']),
    );
  }
}

class PlayerPlusLeaderboardRow {
  final int rank;
  final int userId;
  final String userName;
  final int teamId;
  final String teamTitle;
  final String? seriesName;
  final num value;

  PlayerPlusLeaderboardRow({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.teamId,
    required this.teamTitle,
    this.seriesName,
    required this.value,
  });

  factory PlayerPlusLeaderboardRow.fromJson(Map<String, dynamic> json) {
    return PlayerPlusLeaderboardRow(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Ukendt',
      teamId: json['team_id'] ?? 0,
      teamTitle: json['team_title'] ?? '',
      seriesName: json['series_name'],
      value: json['value'] ?? 0,
    );
  }
}

class PlayerPlusLeaderboard {
  final PlayerPlusEntitlement entitlement;
  final bool locked;
  final String? scope;
  final String? category;
  final List<PlayerPlusLeaderboardRow> rows;

  PlayerPlusLeaderboard({
    required this.entitlement,
    required this.locked,
    this.scope,
    this.category,
    required this.rows,
  });

  factory PlayerPlusLeaderboard.fromJson(Map<String, dynamic> json) {
    return PlayerPlusLeaderboard(
      entitlement: PlayerPlusEntitlement.fromJson(json['entitlement']),
      locked: json['locked'] ?? true,
      scope: json['scope'],
      category: json['category'],
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((row) => PlayerPlusLeaderboardRow.fromJson(row))
          .toList(),
    );
  }
}
