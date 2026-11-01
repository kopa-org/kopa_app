import 'package:kopa/model/match_poll_user_votes_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/external_player_details.dart';

class MatchPollDetails {
  final int id;
  final int eventId;
  final UserDetails? playerOfTheMatchDetails;
  final ExternalPlayerDetails? playerOfTheMatchExternalPlayerDetails;
  final int playerOfTheMatchVotes;
  final List<MatchPollUserVotesDetails> matchPollUserVotesDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchPollDetails({
    required this.id,
    required this.eventId,
    required this.playerOfTheMatchDetails,
    this.playerOfTheMatchExternalPlayerDetails,
    required this.playerOfTheMatchVotes,
    required this.matchPollUserVotesDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchPollDetails.fromJson(Map<String, dynamic> json) {
    return MatchPollDetails(
      id: json['id'],
      eventId: json['event_id'],
      playerOfTheMatchDetails: json['player_of_the_match_details'] == null
          ? null
          : UserDetails.fromJson(json['player_of_the_match_details']),
      playerOfTheMatchExternalPlayerDetails:
          json['player_of_the_match_external_player_details'] == null
              ? null
              : ExternalPlayerDetails.fromJson(
                  json['player_of_the_match_external_player_details']),
      playerOfTheMatchVotes: json['player_of_the_match_votes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      matchPollUserVotesDetails: List<MatchPollUserVotesDetails>.from(
          json['match_poll_user_votes_details']
              .map((x) => MatchPollUserVotesDetails.fromJson(x))),
    );
  }

  /// Every vote row sharing the highest count, so a tie has several winners.
  List<MatchPollUserVotesDetails> get winningVotes {
    if (matchPollUserVotesDetails.isEmpty) return const [];
    final highest = matchPollUserVotesDetails
        .map((vote) => vote.numberOfVotes)
        .reduce((a, b) => a > b ? a : b);
    if (highest <= 0) return const [];
    return matchPollUserVotesDetails
        .where((vote) => vote.numberOfVotes == highest)
        .toList();
  }

  String get winnerName {
    final names = winningVotes
        .map((vote) => vote.userName ?? vote.externalPlayerName)
        .whereType<String>()
        .toList();
    if (names.length > 1 && names.length == winningVotes.length) {
      return names.join(' & ');
    }
    return playerOfTheMatchDetails?.name ??
        playerOfTheMatchExternalPlayerDetails?.name ??
        '';
  }
}
