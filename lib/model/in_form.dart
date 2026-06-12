enum InFormPeriod { rollingThreeMonths, currentSeason, allTime }

extension InFormPeriodValue on InFormPeriod {
  String get wire => switch (this) {
        InFormPeriod.rollingThreeMonths => 'rolling_3_months',
        InFormPeriod.currentSeason => 'current_season',
        InFormPeriod.allTime => 'all_time',
      };

  String get label => switch (this) {
        InFormPeriod.rollingThreeMonths => '3 måneder',
        InFormPeriod.currentSeason => 'Sæson',
        InFormPeriod.allTime => 'Alle',
      };
}

const inFormPositions = <String>[
  'goalkeeper',
  'centre_back',
  'back_wingback',
  'defensive_midfield',
  'midfield',
  'attacking_midfield',
  'wing',
  'striker',
];

String inFormPositionLabel(String? position) => switch (position) {
      'goalkeeper' => 'Målmand',
      'centre_back' => 'Stopper',
      'back_wingback' => 'Back / wingback',
      'defensive_midfield' => 'Defensiv midtbane',
      'midfield' => 'Midtbane',
      'attacking_midfield' => 'Offensiv midtbane',
      'wing' => 'Wing',
      'striker' => 'Angriber',
      _ => 'Alle positioner',
    };

class InFormLeaderboardRow {
  final int rank;
  final int userId;
  final String userName;
  final String? position;
  final int rankChange;
  final double latestRound;
  final double pointsToFirst;
  final double total;

  const InFormLeaderboardRow({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.position,
    required this.rankChange,
    required this.latestRound,
    required this.pointsToFirst,
    required this.total,
  });

  factory InFormLeaderboardRow.fromJson(Map<String, dynamic> json) {
    return InFormLeaderboardRow(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Ukendt',
      position: json['position'],
      rankChange: json['rank_change'] ?? 0,
      latestRound: (json['latest_round'] as num? ?? 0).toDouble(),
      pointsToFirst: (json['points_to_first'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }
}

class InFormLeaderboard {
  final String period;
  final String? position;
  final List<InFormLeaderboardRow> rows;

  const InFormLeaderboard({
    required this.period,
    required this.position,
    required this.rows,
  });

  factory InFormLeaderboard.fromJson(Map<String, dynamic> json) {
    return InFormLeaderboard(
      period: json['period'] ?? 'rolling_3_months',
      position: json['position'],
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((row) =>
              InFormLeaderboardRow.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InFormScoreEntry {
  final int id;
  final int? eventId;
  final String rule;
  final String description;
  final double value;
  final DateTime awardedOn;

  const InFormScoreEntry({
    required this.id,
    required this.eventId,
    required this.rule,
    required this.description,
    required this.value,
    required this.awardedOn,
  });

  factory InFormScoreEntry.fromJson(Map<String, dynamic> json) {
    return InFormScoreEntry(
      id: json['id'] ?? 0,
      eventId: json['event_id'],
      rule: json['rule'] ?? '',
      description: json['description'] ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      awardedOn: DateTime.parse(json['awarded_on']),
    );
  }
}

class InFormPlayerBreakdown {
  final int userId;
  final String period;
  final double total;
  final List<InFormScoreEntry> entries;

  const InFormPlayerBreakdown({
    required this.userId,
    required this.period,
    required this.total,
    required this.entries,
  });

  factory InFormPlayerBreakdown.fromJson(Map<String, dynamic> json) {
    return InFormPlayerBreakdown(
      userId: json['user_id'] ?? 0,
      period: json['period'] ?? 'rolling_3_months',
      total: (json['total'] as num? ?? 0).toDouble(),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((entry) =>
              InFormScoreEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InFormPerformance {
  final int userId;
  final String? position;
  final bool played;
  final bool fullMatch;
  final bool captain;
  final bool excusedAbsence;
  final bool expected;
  final int goals;
  final int assists;
  final int ownGoals;
  final int decisiveGoals;
  final int yellowCards;
  final int secondYellowCards;
  final int redCards;
  final int penaltiesMissed;
  final int penaltiesSaved;
  final int motmVotes;
  final bool motm;
  final int setPieceGoals;

  const InFormPerformance({
    required this.userId,
    this.position,
    this.played = false,
    this.fullMatch = false,
    this.captain = false,
    this.excusedAbsence = false,
    this.expected = false,
    this.goals = 0,
    this.assists = 0,
    this.ownGoals = 0,
    this.decisiveGoals = 0,
    this.yellowCards = 0,
    this.secondYellowCards = 0,
    this.redCards = 0,
    this.penaltiesMissed = 0,
    this.penaltiesSaved = 0,
    this.motmVotes = 0,
    this.motm = false,
    this.setPieceGoals = 0,
  });

  factory InFormPerformance.fromJson(Map<String, dynamic> json) {
    return InFormPerformance(
      userId: json['user_id'] ?? 0,
      position: json['position'],
      played: json['played'] ?? false,
      fullMatch: json['full_match'] ?? false,
      captain: json['captain'] ?? false,
      excusedAbsence: json['excused_absence'] ?? false,
      expected: json['expected'] ?? false,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      ownGoals: json['own_goals'] ?? 0,
      decisiveGoals: json['decisive_goals'] ?? 0,
      yellowCards: json['yellow_cards'] ?? 0,
      secondYellowCards: json['second_yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
      penaltiesMissed: json['penalties_missed'] ?? 0,
      penaltiesSaved: json['penalties_saved'] ?? 0,
      motmVotes: json['motm_votes'] ?? 0,
      motm: json['motm'] ?? false,
      setPieceGoals: json['set_piece_goals'] ?? 0,
    );
  }

  InFormPerformance copyWith({
    String? position,
    bool? played,
    bool? fullMatch,
    bool? captain,
    bool? excusedAbsence,
    bool? expected,
    int? goals,
    int? assists,
    int? ownGoals,
    int? decisiveGoals,
    int? yellowCards,
    int? secondYellowCards,
    int? redCards,
    int? penaltiesMissed,
    int? penaltiesSaved,
    int? motmVotes,
    bool? motm,
    int? setPieceGoals,
  }) {
    return InFormPerformance(
      userId: userId,
      position: position ?? this.position,
      played: played ?? this.played,
      fullMatch: fullMatch ?? this.fullMatch,
      captain: captain ?? this.captain,
      excusedAbsence: excusedAbsence ?? this.excusedAbsence,
      expected: expected ?? this.expected,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      ownGoals: ownGoals ?? this.ownGoals,
      decisiveGoals: decisiveGoals ?? this.decisiveGoals,
      yellowCards: yellowCards ?? this.yellowCards,
      secondYellowCards: secondYellowCards ?? this.secondYellowCards,
      redCards: redCards ?? this.redCards,
      penaltiesMissed: penaltiesMissed ?? this.penaltiesMissed,
      penaltiesSaved: penaltiesSaved ?? this.penaltiesSaved,
      motmVotes: motmVotes ?? this.motmVotes,
      motm: motm ?? this.motm,
      setPieceGoals: setPieceGoals ?? this.setPieceGoals,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'played': played,
        'full_match': fullMatch,
        'captain': captain,
        'excused_absence': excusedAbsence,
        'expected': expected,
        'goals': goals,
        'assists': assists,
        'own_goals': ownGoals,
        'decisive_goals': decisiveGoals,
        'yellow_cards': yellowCards,
        'second_yellow_cards': secondYellowCards,
        'red_cards': redCards,
        'penalties_missed': penaltiesMissed,
        'penalties_saved': penaltiesSaved,
        'motm_votes': motmVotes,
        'motm': motm,
        'set_piece_goals': setPieceGoals,
      };
}

class InFormMatchRecord {
  final int eventId;
  final int teamId;
  final int seasonId;
  final int version;
  final bool cancelled;
  final List<InFormPerformance> performances;
  final String? editedByName;

  const InFormMatchRecord({
    required this.eventId,
    required this.teamId,
    required this.seasonId,
    required this.version,
    required this.cancelled,
    required this.performances,
    this.editedByName,
  });

  factory InFormMatchRecord.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final editedBy = json['edited_by'] as Map<String, dynamic>?;

    return InFormMatchRecord(
      eventId: json['event_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      version: json['version'] ?? 0,
      cancelled: data['cancelled'] ?? false,
      performances: (data['performances'] as List<dynamic>? ?? [])
          .map((performance) =>
              InFormPerformance.fromJson(performance as Map<String, dynamic>))
          .toList(),
      editedByName: editedBy?['name'],
    );
  }
}
