import 'package:kopa/model/external_player_details.dart';
import 'package:kopa/model/user_details.dart';

/// A player who can participate in one match, either as a team member or as
/// a match-only external player.
class MatchPlayer {
  final int? userId;
  final int? externalPlayerId;
  final String name;
  final String? position;

  const MatchPlayer({
    this.userId,
    this.externalPlayerId,
    required this.name,
    this.position,
  }) : assert(
          (userId == null) != (externalPlayerId == null),
          'Exactly one player identity is required',
        );

  factory MatchPlayer.user(UserDetails user) {
    return MatchPlayer(
      userId: user.id,
      name: user.name,
      position: user.position,
    );
  }

  factory MatchPlayer.external(ExternalPlayerDetails player) {
    return MatchPlayer(
      externalPlayerId: player.id,
      name: player.name,
    );
  }

  bool get isExternal => externalPlayerId != null;

  /// Stable identity for UI collections where user and external IDs coexist.
  int get stableId => userId ?? -externalPlayerId!;
}
