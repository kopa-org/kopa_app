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
      eventId: json['eventId'],
      playerOfTheMatchDetails:
          UserDetails.fromJson(json['playerOfTheMatchDetails']),
      playerOfTheMatchVotes: json['playerOfTheMatchVotes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      matchPollUserVotesDetails: List<MatchPollUserVotesDetails>.from(
          json['matchPollUserVotesDetails']
              .map((x) => MatchPollUserVotesDetails.fromJson(x))),
    );
  }
}
