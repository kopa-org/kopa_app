import 'dart:convert';

import 'package:kopa/model/create_match_poll_user_command.dart';

class CreateMatchPollCommand {
  final String eventId;
  final List<CreateMatchPollUserVoteCommand> createMatchPollUserVoteCommands;

  CreateMatchPollCommand(this.eventId, this.createMatchPollUserVoteCommands);

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'create_match_poll_user_vote_commands': jsonEncode(
          createMatchPollUserVoteCommands.map((e) => e.toJson()).toList())
    };
  }
}
