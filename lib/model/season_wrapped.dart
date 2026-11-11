/// The "Season Wrapped" story for the season that just ended, as built by
/// `GET /teams/:id/season_wrapped`. Only categories with enough data (and not
/// switched off by the team leader) appear in [slides].
class SeasonWrapped {
  /// The optional award categories, in story order.
  static const optionalCategories = [
    'form',
    'goals',
    'assists',
    'motm',
    'iron',
    'fines',
    'cards',
    'lantern',
  ];

  final bool available;
  final int? seasonId;
  final String seasonName;
  final WrappedTeam team;
  final WrappedMe me;
  final WrappedAwards awards;
  final List<WrappedCategory> categories;
  final List<String> slides;

  const SeasonWrapped({
    required this.available,
    required this.seasonId,
    required this.seasonName,
    required this.team,
    required this.me,
    required this.awards,
    required this.categories,
    required this.slides,
  });

  factory SeasonWrapped.fromJson(Map<String, dynamic> json) {
    final season = _map(json['season']);
    return SeasonWrapped(
      available: json['available'] == true,
      seasonId: _int(season['id']),
      seasonName: season['name']?.toString() ?? '',
      team: WrappedTeam.fromJson(_map(json['team'])),
      me: WrappedMe.fromJson(_map(json['me'])),
      awards: WrappedAwards.fromJson(_map(json['awards'])),
      categories: _list(json['categories'])
          .map(WrappedCategory.fromJson)
          .toList(growable: false),
      slides: (json['slides'] is List)
          ? (json['slides'] as List).map((e) => e.toString()).toList()
          : const ['intro', 'team', 'outro'],
    );
  }

  List<String> get disabledCategories => categories
      .where((category) => !category.enabled)
      .map((category) => category.key)
      .toList(growable: false);
}

class WrappedTeam {
  final String title;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  /// "W", "D" or "L" for the last five matches, oldest first.
  final List<String> form;
  final int bestWinStreak;

  /// The season's played matches, oldest first.
  final List<int> matchIds;

  const WrappedTeam({
    required this.title,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.form,
    required this.bestWinStreak,
    required this.matchIds,
  });

  factory WrappedTeam.fromJson(Map<String, dynamic> json) => WrappedTeam(
        title: json['title']?.toString() ?? '',
        played: _int(json['played']) ?? 0,
        wins: _int(json['wins']) ?? 0,
        draws: _int(json['draws']) ?? 0,
        losses: _int(json['losses']) ?? 0,
        goalsFor: _int(json['goals_for']) ?? 0,
        goalsAgainst: _int(json['goals_against']) ?? 0,
        form: (json['form'] is List)
            ? (json['form'] as List).map((e) => e.toString()).toList()
            : const [],
        bestWinStreak: _int(json['best_win_streak']) ?? 0,
        matchIds: (json['match_ids'] is List)
            ? (json['match_ids'] as List).map(_int).whereType<int>().toList()
            : const [],
      );
}

class WrappedMe {
  final String name;
  final int matchesPlayed;
  final int goals;
  final int assists;
  final double trainingPercentage;
  final int playersWithMoreMatches;
  final int? formRank;
  final int formPlayers;

  const WrappedMe({
    required this.name,
    required this.matchesPlayed,
    required this.goals,
    required this.assists,
    required this.trainingPercentage,
    required this.playersWithMoreMatches,
    required this.formRank,
    required this.formPlayers,
  });

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory WrappedMe.fromJson(Map<String, dynamic> json) => WrappedMe(
        name: json['name']?.toString() ?? '',
        matchesPlayed: _int(json['matches_played']) ?? 0,
        goals: _int(json['goals']) ?? 0,
        assists: _int(json['assists']) ?? 0,
        trainingPercentage: _double(json['training_percentage']),
        playersWithMoreMatches: _int(json['players_with_more_matches']) ?? 0,
        formRank: _int(json['form_rank']),
        formPlayers: _int(json['form_players']) ?? 0,
      );
}

/// A player on a podium or leaderboard. [value] is goals, wins, kroner, ...
class WrappedPlayer {
  final int userId;
  final String name;
  final num value;
  final int? rank;
  final int yellow;
  final int red;
  final List<int> eventIds;

  const WrappedPlayer({
    required this.userId,
    required this.name,
    required this.value,
    this.rank,
    this.yellow = 0,
    this.red = 0,
    this.eventIds = const [],
  });

  /// "Mads Kristensen" -> "Mads K."
  String get shortName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.first;
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }

  factory WrappedPlayer.fromJson(Map<String, dynamic> json) => WrappedPlayer(
        userId: _int(json['user_id']) ?? 0,
        name: json['user_name']?.toString() ?? '',
        value: (json['value'] ?? json['total'] ?? 0) as num,
        rank: _int(json['rank']),
        yellow: _int(json['yellow']) ?? 0,
        red: _int(json['red']) ?? 0,
        eventIds: (json['event_ids'] is List)
            ? (json['event_ids'] as List).map(_int).whereType<int>().toList()
            : const [],
      );
}

class WrappedDuo {
  final String fromName;
  final String toName;
  final int goals;

  const WrappedDuo({
    required this.fromName,
    required this.toName,
    required this.goals,
  });

  static WrappedDuo? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return WrappedDuo(
      fromName: json['from_name']?.toString() ?? '',
      toName: json['to_name']?.toString() ?? '',
      goals: _int(json['goals']) ?? 0,
    );
  }
}

class WrappedAwards {
  final List<WrappedPlayer> goals;
  final int teamGoals;
  final List<WrappedPlayer> assists;
  final WrappedDuo? duo;
  final List<WrappedPlayer> motm;
  final int votedMatches;
  final List<WrappedPlayer> iron;
  final int teamMatches;
  final List<WrappedPlayer> form;
  final WrappedPlayer? formMe;
  final List<WrappedPlayer> fines;
  final num finesTotal;
  final List<WrappedPlayer> cards;
  final WrappedPlayer? lantern;
  final int lanternPlayers;

  const WrappedAwards({
    this.goals = const [],
    this.teamGoals = 0,
    this.assists = const [],
    this.duo,
    this.motm = const [],
    this.votedMatches = 0,
    this.iron = const [],
    this.teamMatches = 0,
    this.form = const [],
    this.formMe,
    this.fines = const [],
    this.finesTotal = 0,
    this.cards = const [],
    this.lantern,
    this.lanternPlayers = 0,
  });

  factory WrappedAwards.fromJson(Map<String, dynamic> json) {
    List<WrappedPlayer> players(dynamic value) =>
        _list(value).map(WrappedPlayer.fromJson).toList(growable: false);
    WrappedPlayer? player(dynamic value) =>
        value is Map<String, dynamic> ? WrappedPlayer.fromJson(value) : null;

    final goals = _map(json['goals']);
    final assists = _map(json['assists']);
    final motm = _map(json['motm']);
    final iron = _map(json['iron']);
    final form = _map(json['form']);
    final fines = _map(json['fines']);
    final cards = _map(json['cards']);
    final lantern = _map(json['lantern']);

    return WrappedAwards(
      goals: players(goals['podium']),
      teamGoals: _int(goals['team_goals']) ?? 0,
      assists: players(assists['podium']),
      duo: WrappedDuo.fromJson(assists['duo']),
      motm: players(motm['podium']),
      votedMatches: _int(motm['voted_matches']) ?? 0,
      iron: players(iron['podium']),
      teamMatches: _int(iron['team_matches']) ?? 0,
      form: players(form['rows']),
      formMe: player(form['me']),
      fines: players(fines['podium']),
      finesTotal: (fines['total'] ?? 0) as num,
      cards: players(cards['podium']),
      lantern: player(lantern['last']),
      lanternPlayers: _int(lantern['players']) ?? 0,
    );
  }
}

class WrappedCategory {
  final String key;
  final bool available;
  final bool enabled;
  final num count;

  const WrappedCategory({
    required this.key,
    required this.available,
    required this.enabled,
    required this.count,
  });

  factory WrappedCategory.fromJson(Map<String, dynamic> json) =>
      WrappedCategory(
        key: json['key']?.toString() ?? '',
        available: json['available'] == true,
        enabled: json['enabled'] != false,
        count: (json['count'] ?? 0) as num,
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<Map<String, dynamic>> _list(dynamic value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList(growable: false)
    : const [];

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
