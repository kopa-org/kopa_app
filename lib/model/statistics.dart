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
  final List<int> lastFiveMatchesForm; // 1 for win, 0 for draw, -1 for loss

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

class StatisticsResponse {
  final PlayerStats player;
  final ClubStats club;

  StatisticsResponse({required this.player, required this.club});

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      player: PlayerStats.fromJson(json['player']),
      club: ClubStats.fromJson(json['club']),
    );
  }
}

/// Hardcoded mock data for UI development before the backend is connected.
class MockData {
  static final playerStats = PlayerStats(
    name: 'Mads Futte',
    matchesPlayed: 14,
    trainingAttendancePercentage: 82.5,
    goalsScored: 6,
    assists: 4,
    yellowCards: 2,
    redCards: 0,
    finesTotal: 250.0,
  );

  static final clubStats = ClubStats(
    wins: 9,
    draws: 3,
    losses: 2,
    goalsFor: 28,
    goalsAgainst: 12,
    lastFiveMatchesForm: [1, 1, 0, -1, 1], // W, W, D, L, W
  );
}
