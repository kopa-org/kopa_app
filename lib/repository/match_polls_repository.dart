import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/create_match_poll_command.dart';
import 'package:kopa/model/create_match_poll_user_command.dart';
import 'package:kopa/model/match_poll_details.dart';

import 'package:http/http.dart' as http;
import 'package:kopa/model/user_vote.dart';

class MatchPollsRepository {
  static final _secureStorage = FlutterSecureStorage();

  static Future<List<MatchPollDetails>> getMatchPolls() async {
    final token = await _secureStorage.read(key: 'token');

    var url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll/all');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      Iterable json = jsonDecode(response.body)['polls'];

      return List<MatchPollDetails>.from(
          json.map((content) => MatchPollDetails.fromJson(content)));
    } else {
      throw Exception('Failed to fetch match polls');
    }
  }

  static Future<MatchPollDetails> getMatchPoll(int id) async {
    final token = await _secureStorage.read(key: 'token');

    var url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll/$id');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body)['poll'];

      return MatchPollDetails.fromJson(json);
    } else {
      throw Exception('Failed to fetch match poll');
    }
  }

  static Future<int> createMatchPoll(
      int matchId, List<UserVote> userVotes) async {
    final token = await _secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    var url = Uri.parse('${ApiConfig.baseUrl}/match/matchpoll');

    List<CreateMatchPollUserVoteCommand> createMatchPollUserVoteCommands =
        userVotes
            .map((userVote) => CreateMatchPollUserVoteCommand(
                  userId: userVote.userId.toString(),
                  userVotes: userVote.votes.toString(),
                ))
            .toList();

    CreateMatchPollCommand createMatchPollCommand = CreateMatchPollCommand(
        matchId.toString(), createMatchPollUserVoteCommands);

    var response = await http.post(
      url,
      body: createMatchPollCommand.toJson(),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create match poll');
    }

    var json = jsonDecode(response.body);

    return json['id'];
  }
}
