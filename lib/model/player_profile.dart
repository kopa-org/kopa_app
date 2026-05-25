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
  final DateTime date;
  final bool participated;
  final double? rating;
  final bool scored;
  final bool assisted;

  PlayerMatchHistoryItem({
    required this.eventId,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.participated,
    required this.rating,
    required this.scored,
    required this.assisted,
  });

  factory PlayerMatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return PlayerMatchHistoryItem(
      eventId: json['event_id'],
      homeTeam: json['home_team'] ?? 'Hjemmehold',
      awayTeam: json['away_team'] ?? 'Udehold',
      date: DateTime.parse(json['date']),
      participated: json['participated'] ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      scored: json['scored'] ?? false,
      assisted: json['assisted'] ?? false,
    );
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
