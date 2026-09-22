import 'dart:convert';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_match_poll_command.dart';
import 'package:kopa/model/create_match_poll_user_command.dart';
import 'package:kopa/model/match_poll_details.dart';

import 'package:kopa/model/user_vote.dart';
import 'package:kopa/services/api_client.dart';

class MatchPollsRepository {
  static final _apiClient = ApiClient.shared;

  static Future<List<MatchPollDetails>> getMatchPolls() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll/all');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      Iterable json = jsonDecode(response.body)['polls'];

      return List<MatchPollDetails>.from(
          json.map((content) => MatchPollDetails.fromJson(content)));
    } else {
      throw Exception('Failed to fetch match polls');
    }
  }

  static Future<MatchPollDetails> getMatchPoll(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll/$id');
    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)['poll'];

      return MatchPollDetails.fromJson(json);
    } else {
      throw Exception('Failed to fetch match poll');
    }
  }

  static Future<int> createMatchPoll(
      int matchId, List<UserVote> userVotes) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll');

    List<CreateMatchPollUserVoteCommand> createMatchPollUserVoteCommands =
        userVotes
            .map((userVote) => CreateMatchPollUserVoteCommand(
                  userId: userVote.userId?.toString(),
                  externalPlayerId: userVote.externalPlayerId?.toString(),
                  userVotes: userVote.votes.toString(),
                ))
            .toList();

    CreateMatchPollCommand createMatchPollCommand = CreateMatchPollCommand(
        matchId.toString(), createMatchPollUserVoteCommands);

    final response = await _apiClient.postJson(
      url,
      body: createMatchPollCommand.toJson(),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create match poll');
    }

    var json = jsonDecode(response.body);

    return json['id'];
  }

  static Future<MatchPollDetails> updateMatchPoll(
      int matchPollId, List<UserVote> userVotes) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll/$matchPollId');

    final response = await _apiClient.patchJson(
      url,
      body: {
        'create_match_poll_user_vote_commands': jsonEncode(
          userVotes
              .map(
                (userVote) => {
                  if (userVote.userId != null)
                    'user_id': userVote.userId.toString(),
                  if (userVote.externalPlayerId != null)
                    'external_player_id': userVote.externalPlayerId.toString(),
                  'user_votes': userVote.votes.toString(),
                },
              )
              .toList(),
        ),
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to update match poll');
    }

    final decoded = jsonDecode(response.body);
    final poll = decoded['poll'];
    if (poll is! Map) {
      throw Exception('Updated match poll was not returned');
    }

    return MatchPollDetails.fromJson(Map<String, dynamic>.from(poll));
  }
}
