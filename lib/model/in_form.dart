import 'package:kopa/l10n/current_l10n.dart';

enum InFormPeriod { rollingThreeMonths, currentSeason, allTime }

extension InFormPeriodValue on InFormPeriod {
  String get wire => switch (this) {
        InFormPeriod.rollingThreeMonths => 'rolling_3_months',
        InFormPeriod.currentSeason => 'current_season',
        InFormPeriod.allTime => 'all_time',
      };

  String get label => switch (this) {
        InFormPeriod.rollingThreeMonths => currentL10n.ui3Months,
        InFormPeriod.currentSeason => currentL10n.uiSeason2,
        InFormPeriod.allTime => currentL10n.uiAll,
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
      'goalkeeper' => currentL10n.uiGoalkeeper,
      'centre_back' => currentL10n.uiCentreBack,
      'back_wingback' => currentL10n.uiBackWingback,
      'defensive_midfield' => currentL10n.uiDefensiveMidfield,
      'midfield' => currentL10n.uiMidfield,
      'attacking_midfield' => currentL10n.uiAttackingMidfield,
      'wing' => currentL10n.uiWinger,
      'striker' => currentL10n.uiStriker,
      _ => currentL10n.uiAllPositions,
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
      period: json['period'] ?? 'current_season',
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
  final String category;
  final String description;
  final double value;
  final DateTime awardedOn;

  const InFormScoreEntry({
    required this.id,
    required this.eventId,
    required this.rule,
    this.category = 'bonus',
    required this.description,
    required this.value,
    required this.awardedOn,
  });

  factory InFormScoreEntry.fromJson(Map<String, dynamic> json) {
    return InFormScoreEntry(
      id: json['id'] ?? 0,
      eventId: json['event_id'],
      rule: json['rule'] ?? '',
      category: json['category'] ?? 'bonus',
      description: json['description'] ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      awardedOn: DateTime.parse(json['awarded_on']),
    );
  }
}

/// Player-facing point categories, in the order shown to players.
const inFormCategories = <String>[
  'offensive',
  'defensive',
  'team_result',
  'discipline',
  'participation',
  'bonus',
];

String inFormCategoryLabel(String category) => switch (category) {
      'offensive' => currentL10n.inFormCategoryOffensive,
      'defensive' => currentL10n.inFormCategoryDefensive,
      'team_result' => currentL10n.inFormCategoryTeamResult,
      'discipline' => currentL10n.inFormCategoryDiscipline,
      'participation' => currentL10n.inFormCategoryParticipation,
      _ => currentL10n.inFormCategoryBonus,
    };

String inFormCategoryDescription(String category) => switch (category) {
      'offensive' => currentL10n.inFormCategoryOffensiveDescription,
      'defensive' => currentL10n.inFormCategoryDefensiveDescription,
      'team_result' => currentL10n.inFormCategoryTeamResultDescription,
      'discipline' => currentL10n.inFormCategoryDisciplineDescription,
      'participation' => currentL10n.inFormCategoryParticipationDescription,
      _ => currentL10n.inFormCategoryBonusDescription,
    };

int _int(dynamic value) => (value as num?)?.toInt() ?? 0;
double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;

/// Per-match stats as they were scored (after any registered overrides).
class InFormMatchStats {
  final String? position;
  final int goals;
  final int assists;
  final int ownGoals;
  final int decisiveGoals;
  final int yellowCards;
  final int redCards;
  final int penaltiesMissed;
  final int penaltiesSaved;
  final int motmVotes;
  final bool motm;

  const InFormMatchStats({
    this.position,
    this.goals = 0,
    this.assists = 0,
    this.ownGoals = 0,
    this.decisiveGoals = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.penaltiesMissed = 0,
    this.penaltiesSaved = 0,
    this.motmVotes = 0,
    this.motm = false,
  });

  factory InFormMatchStats.fromJson(Map<String, dynamic> json) {
    return InFormMatchStats(
      position: json['position'],
      goals: _int(json['goals']),
      assists: _int(json['assists']),
      ownGoals: _int(json['own_goals']),
      decisiveGoals: _int(json['decisive_goals']),
      yellowCards: _int(json['yellow_cards']),
      redCards: _int(json['red_cards']),
      penaltiesMissed: _int(json['penalties_missed']),
      penaltiesSaved: _int(json['penalties_saved']),
      motmVotes: _int(json['motm_votes']),
      motm: json['motm'] == true,
    );
  }
}

/// Manually registered per-match data. Null fields use the derived value.
class InFormMatchOverride {
  final String? position;
  final int? ownGoals;
  final int? penaltiesMissed;
  final int? penaltiesSaved;
  final int? decisiveGoals;

  const InFormMatchOverride({
    this.position,
    this.ownGoals,
    this.penaltiesMissed,
    this.penaltiesSaved,
    this.decisiveGoals,
  });

  factory InFormMatchOverride.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InFormMatchOverride();
    return InFormMatchOverride(
      position: json['position'],
      ownGoals: (json['own_goals'] as num?)?.toInt(),
      penaltiesMissed: (json['penalties_missed'] as num?)?.toInt(),
      penaltiesSaved: (json['penalties_saved'] as num?)?.toInt(),
      decisiveGoals: (json['decisive_goals'] as num?)?.toInt(),
    );
  }
}

enum InFormMatchResult { win, draw, loss }

class InFormMatchBreakdown {
  final int eventId;
  final DateTime? date;
  final String? opponent;
  final bool isHomeTeam;
  final int? teamGoals;
  final int? opponentGoals;
  final InFormMatchResult? result;
  final String? position;
  final InFormMatchStats stats;
  final InFormMatchOverride override;
  final double total;
  final List<InFormScoreEntry> entries;

  const InFormMatchBreakdown({
    required this.eventId,
    required this.date,
    required this.opponent,
    required this.isHomeTeam,
    required this.teamGoals,
    required this.opponentGoals,
    required this.result,
    required this.position,
    required this.stats,
    required this.override,
    required this.total,
    required this.entries,
  });

  bool get played => position != null;

  factory InFormMatchBreakdown.fromJson(Map<String, dynamic> json) {
    return InFormMatchBreakdown(
      eventId: json['event_id'] ?? 0,
      date: json['date'] == null
          ? null
          : DateTime.tryParse(json['date'] as String)?.toLocal(),
      opponent: json['opponent'],
      isHomeTeam: json['is_home_team'] != false,
      teamGoals: (json['team_goals'] as num?)?.toInt(),
      opponentGoals: (json['opponent_goals'] as num?)?.toInt(),
      result: switch (json['result']) {
        'win' => InFormMatchResult.win,
        'draw' => InFormMatchResult.draw,
        'loss' => InFormMatchResult.loss,
        _ => null,
      },
      position: json['position'],
      stats: InFormMatchStats.fromJson(
          (json['stats'] as Map<String, dynamic>?) ?? const {}),
      override: InFormMatchOverride.fromJson(
          json['override'] as Map<String, dynamic>?),
      total: _double(json['total']),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((entry) =>
              InFormScoreEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InFormPlayerSummary {
  final int matches;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final int motm;
  final double average;

  const InFormPlayerSummary({
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.motm = 0,
    this.average = 0,
  });

  factory InFormPlayerSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InFormPlayerSummary();
    return InFormPlayerSummary(
      matches: _int(json['matches']),
      goals: _int(json['goals']),
      assists: _int(json['assists']),
      yellowCards: _int(json['yellow_cards']),
      redCards: _int(json['red_cards']),
      motm: _int(json['motm']),
      average: _double(json['average']),
    );
  }
}

class InFormPlayerBreakdown {
  final int userId;
  final String period;
  final double total;
  final bool canEditPosition;
  final bool canEditMatchData;
  final InFormPlayerSummary summary;
  final List<InFormMatchBreakdown> matches;
  final List<InFormScoreEntry> bonuses;
  final List<InFormScoreEntry> entries;

  const InFormPlayerBreakdown({
    required this.userId,
    required this.period,
    required this.total,
    this.canEditPosition = false,
    this.canEditMatchData = false,
    this.summary = const InFormPlayerSummary(),
    this.matches = const [],
    this.bonuses = const [],
    required this.entries,
  });

  factory InFormPlayerBreakdown.fromJson(Map<String, dynamic> json) {
    List<InFormScoreEntry> entries(String key) =>
        (json[key] as List<dynamic>? ?? [])
            .map((entry) =>
                InFormScoreEntry.fromJson(entry as Map<String, dynamic>))
            .toList();

    return InFormPlayerBreakdown(
      userId: json['user_id'] ?? 0,
      period: json['period'] ?? 'current_season',
      total: _double(json['total']),
      canEditPosition: json['can_edit_position'] == true,
      canEditMatchData: json['can_edit_match_data'] == true,
      summary: InFormPlayerSummary.fromJson(
          json['summary'] as Map<String, dynamic>?),
      matches: (json['matches'] as List<dynamic>? ?? [])
          .map((match) =>
              InFormMatchBreakdown.fromJson(match as Map<String, dynamic>))
          .toList(),
      bonuses: entries('bonuses'),
      entries: entries('entries'),
    );
  }
}

class InFormPointRule {
  final String rule;
  final String label;
  final double value;
  final String category;

  const InFormPointRule({
    required this.rule,
    required this.label,
    required this.value,
    required this.category,
  });

  factory InFormPointRule.fromJson(Map<String, dynamic> json) {
    return InFormPointRule(
      rule: json['rule'] ?? '',
      label: json['label'] ?? '',
      value: _double(json['value']),
      category: json['category'] ?? 'bonus',
    );
  }
}

class InFormPointsSystem {
  final Map<String, List<InFormPointRule>> rulesByPosition;

  const InFormPointsSystem({required this.rulesByPosition});

  factory InFormPointsSystem.fromJson(Map<String, dynamic> json) {
    return InFormPointsSystem(
      rulesByPosition: {
        for (final item in (json['positions'] as List<dynamic>? ?? []))
          (item as Map<String, dynamic>)['position'] as String:
              (item['rules'] as List<dynamic>? ?? [])
                  .map((rule) =>
                      InFormPointRule.fromJson(rule as Map<String, dynamic>))
                  .toList(),
      },
    );
  }
}
