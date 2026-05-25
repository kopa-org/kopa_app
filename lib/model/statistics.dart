class PlayerStats {
  final String name;
  final int matchesPlayed;
  final double trainingAttendancePercentage;
  final int goalsScored;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double finesTotal;

  PlayerStats({
    required this.name,
    required this.matchesPlayed,
    required this.trainingAttendancePercentage,
    required this.goalsScored,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
    required this.finesTotal,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      name: json['name'] ?? 'Unknown',
      matchesPlayed: json['matches_played'] ?? 0,
      trainingAttendancePercentage:
          (json['training_attendance_percentage'] ?? 0).toDouble(),
      goalsScored: json['goals_scored'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
      finesTotal: (json['fines_total'] ?? 0).toDouble(),
    );
  }
}

class ClubStats {
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final List<int> lastFiveMatchesForm;

  ClubStats({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.lastFiveMatchesForm,
  });

  factory ClubStats.fromJson(Map<String, dynamic> json) {
    return ClubStats(
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      goalsFor: json['goals_for'] ?? 0,
      goalsAgainst: json['goals_against'] ?? 0,
      lastFiveMatchesForm: json['last_five_matches_form'] != null
          ? List<int>.from(json['last_five_matches_form'])
          : [],
    );
  }
}

class LeaderboardRow {
  final int userId;
  final String userName;
  final num value;

  LeaderboardRow({
    required this.userId,
    required this.userName,
    required this.value,
  });

  factory LeaderboardRow.fromJson(Map<String, dynamic> json) {
    return LeaderboardRow(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Ukendt',
      value: json['value'] ?? 0,
    );
  }
}

class InFormRow {
  final int userId;
  final String userName;
  final int points;

  InFormRow({
    required this.userId,
    required this.userName,
    required this.points,
  });

  factory InFormRow.fromJson(Map<String, dynamic> json) {
    return InFormRow(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Ukendt',
      points: json['points'] ?? 0,
    );
  }
}

class TeamMetrics {
  final double? teamAveragePoints;
  final List<int> teamForm;
  final int goalsScored;
  final int goalsConceded;

  TeamMetrics({
    required this.teamAveragePoints,
    required this.teamForm,
    required this.goalsScored,
    required this.goalsConceded,
  });

  factory TeamMetrics.fromJson(Map<String, dynamic> json) {
    return TeamMetrics(
      teamAveragePoints: (json['team_average_points'] as num?)?.toDouble(),
      teamForm: (json['team_form'] as List<dynamic>? ?? []).cast<int>(),
      goalsScored: json['goals_scored'] ?? 0,
      goalsConceded: json['goals_conceded'] ?? 0,
    );
  }
}

class Leaderboards {
  final List<LeaderboardRow> topScorers;
  final List<LeaderboardRow> assists;
  final List<LeaderboardRow> matchesPlayed;
  final List<LeaderboardRow> mostVotes;
  final List<LeaderboardRow> bestPointsAverage;

  Leaderboards({
    required this.topScorers,
    required this.assists,
    required this.matchesPlayed,
    required this.mostVotes,
    required this.bestPointsAverage,
  });

  factory Leaderboards.fromJson(Map<String, dynamic> json) {
    List<LeaderboardRow> parse(String key) {
      return (json[key] as List<dynamic>? ?? [])
          .map((row) => LeaderboardRow.fromJson(row))
          .toList();
    }

    return Leaderboards(
      topScorers: parse('top_scorers'),
      assists: parse('assists'),
      matchesPlayed: parse('matches_played'),
      mostVotes: parse('most_votes'),
      bestPointsAverage: parse('best_points_average'),
    );
  }
}

class StatisticsResponse {
  final PlayerStats player;
  final ClubStats club;
  final List<InFormRow> inFormRows;
  final Leaderboards leaderboards;
  final TeamMetrics teamMetrics;

  StatisticsResponse({
    required this.player,
    required this.club,
    required this.inFormRows,
    required this.leaderboards,
    required this.teamMetrics,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      player: PlayerStats.fromJson(json['player']),
      club: ClubStats.fromJson(json['club']),
      inFormRows: (json['in_form_rows'] as List<dynamic>? ?? [])
          .map((row) => InFormRow.fromJson(row))
          .toList(),
      leaderboards: Leaderboards.fromJson(json['leaderboards'] ?? {}),
      teamMetrics: TeamMetrics.fromJson(json['team_metrics'] ?? {}),
    );
  }
}
