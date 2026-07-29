import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/user_details.dart';

class PlayerProfile {
  final UserDetails player;
  final PlayerBio bio;
  final List<PlayerMatchHistoryItem> matchHistory;
  final PlayerFineOverview fineOverview;
  final PlayerPlusSummary playerPlusSummary;

  PlayerProfile({
    required this.player,
    required this.bio,
    required this.matchHistory,
    required this.fineOverview,
    required this.playerPlusSummary,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      player: UserDetails.fromJson(json['player']),
      bio: PlayerBio.fromJson(json['bio'] ?? {}),
      matchHistory: (json['match_history'] as List<dynamic>? ?? [])
          .map((item) => PlayerMatchHistoryItem.fromJson(item))
          .toList(),
      fineOverview: PlayerFineOverview.fromJson(json['fine_overview'] ?? {}),
      playerPlusSummary:
          PlayerPlusSummary.fromJson(json['player_plus_summary'] ?? {}),
    );
  }
}

class PlayerBio {
  final int? age;
  final String? position;

  PlayerBio({this.age, this.position});

  factory PlayerBio.fromJson(Map<String, dynamic> json) {
    return PlayerBio(
      age: json['age'],
      position: json['position'],
    );
  }
}

class PlayerMatchHistoryItem {
  final int eventId;
  final String homeTeam;
  final String awayTeam;
  final String opponentName;
  final int? homeTeamScore;
  final int? awayTeamScore;
  final int? teamScore;
  final int? opponentScore;
  final bool isHomeTeam;
  final String? seasonName;
  final DateTime date;
  final bool participated;
  final double? rating;
  final bool scored;
  final bool assisted;
  final int goalsCount;
  final int assistsCount;
  final int yellowCardsCount;
  final int redCardsCount;
  final bool playerOfTheMatch;

  PlayerMatchHistoryItem({
    required this.eventId,
    required this.homeTeam,
    required this.awayTeam,
    required this.opponentName,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.teamScore,
    required this.opponentScore,
    required this.isHomeTeam,
    required this.seasonName,
    required this.date,
    required this.participated,
    required this.rating,
    required this.scored,
    required this.assisted,
    required this.goalsCount,
    required this.assistsCount,
    required this.yellowCardsCount,
    required this.redCardsCount,
    required this.playerOfTheMatch,
  });

  factory PlayerMatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return PlayerMatchHistoryItem(
      eventId: json['event_id'],
      homeTeam: json['home_team'],
      awayTeam: json['away_team'],
      opponentName: json['opponent_name'],
      homeTeamScore: json['home_team_score'],
      awayTeamScore: json['away_team_score'],
      teamScore: json['team_score'],
      opponentScore: json['opponent_score'],
      isHomeTeam: json['is_home_team'],
      seasonName: json['season_name'],
      date: DateTime.parse(json['date']),
      participated: json['participated'],
      rating: (json['rating'] as num?)?.toDouble(),
      scored: json['scored'],
      assisted: json['assisted'],
      goalsCount: json['goals_count'],
      assistsCount: json['assists_count'],
      yellowCardsCount: json['yellow_cards_count'],
      redCardsCount: json['red_cards_count'],
      playerOfTheMatch: json['player_of_the_match'],
    );
  }

  String? get scoreLabel {
    if (teamScore == null || opponentScore == null) return null;
    return '$teamScore - $opponentScore';
  }
}

class PlayerFineOverview {
  final double owedAmount;
  final List<FineDetails> fines;

  PlayerFineOverview({
    required this.owedAmount,
    required this.fines,
  });

  factory PlayerFineOverview.fromJson(Map<String, dynamic> json) {
    return PlayerFineOverview(
      owedAmount: (json['owed_amount'] as num?)?.toDouble() ?? 0,
      fines: (json['fines'] as List<dynamic>? ?? [])
          .map((item) => FineDetails.fromJson(item))
          .toList(),
    );
  }
}

class PlayerPlusSummary {
  final int matchesPlayed;
  final int goalsScored;
  final int assists;
  final double? pointsAverage;
  final int voteCount;

  PlayerPlusSummary({
    required this.matchesPlayed,
    required this.goalsScored,
    required this.assists,
    required this.pointsAverage,
    required this.voteCount,
  });

  factory PlayerPlusSummary.fromJson(Map<String, dynamic> json) {
    return PlayerPlusSummary(
      matchesPlayed: json['matches_played'] ?? 0,
      goalsScored: json['goals_scored'] ?? 0,
      assists: json['assists'] ?? 0,
      pointsAverage: (json['points_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
