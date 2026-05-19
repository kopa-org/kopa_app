import 'package:kopa/model/match_poll_user_votes_details.dart';
import 'package:kopa/model/user_details.dart';

class MatchPollDetails {
  final int id;
  final int eventId;
  final UserDetails playerOfTheMatchDetails;
  final int playerOfTheMatchVotes;
  final List<MatchPollUserVotesDetails> matchPollUserVotesDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchPollDetails({
    required this.id,
    required this.eventId,
    required this.playerOfTheMatchDetails,
    required this.playerOfTheMatchVotes,
    required this.matchPollUserVotesDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchPollDetails.fromJson(Map<String, dynamic> json) {
    return MatchPollDetails(
      id: json['id'],
      eventId: json['event_id'],
      playerOfTheMatchDetails:
          UserDetails.fromJson(json['player_of_the_match_details']),
      playerOfTheMatchVotes: json['player_of_the_match_votes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      matchPollUserVotesDetails: List<MatchPollUserVotesDetails>.from(
          json['match_poll_user_votes_details']
              .map((x) => MatchPollUserVotesDetails.fromJson(x))),
    );
  }
}
