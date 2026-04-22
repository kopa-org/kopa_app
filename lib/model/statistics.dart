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
}

class ClubStats {
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int position;
  final List<int> lastFiveMatchesForm; // 1 for win, 0 for draw, -1 for loss

  ClubStats({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.position,
    required this.lastFiveMatchesForm,
  });
}

class MockData {
  static final playerStats = PlayerStats(
    name: "Mads Futte",
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
    position: 2,
    lastFiveMatchesForm: [1, 1, 0, -1, 1], // W, W, D, L, W
  );
}
