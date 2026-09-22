import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:kopa/model/user_vote.dart';

class UserVotesState extends ChangeNotifier {
  final List<UserVote> _userVotes = [];

  UserVotesState({Iterable<UserVote> initialVotes = const []}) {
    _userVotes.addAll(
      initialVotes.map(
        (vote) => UserVote(
          userId: vote.userId,
          externalPlayerId: vote.externalPlayerId,
          votes: vote.votes,
        ),
      ),
    );
  }

  UnmodifiableListView<UserVote> get userVotes =>
      UnmodifiableListView(_userVotes);

  int votesForUser(int userId) {
    final index = _userVotes.indexWhere((x) => x.stableId == userId);
    return index == -1 ? 0 : _userVotes[index].votes;
  }

  void addUserVote(UserVote userVote) {
    bool doesUserHaveNotVotesYet =
        !_userVotes.any((x) => x.stableId == userVote.stableId);

    if (doesUserHaveNotVotesYet) {
      _userVotes.add(userVote);
      notifyListeners();
    } else {
      updateUserVote(userVote.stableId, userVote.votes);
    }
  }

  void updateUserVote(int userId, int votes) {
    final index = _userVotes.indexWhere((x) => x.stableId == userId);

    if (votes == 0) {
      _userVotes.removeWhere((x) => x.stableId == userId);
    } else if (index == -1) {
      _userVotes.add(UserVote(
        userId: userId > 0 ? userId : null,
        externalPlayerId: userId < 0 ? -userId : null,
        votes: votes,
      ));
    } else {
      _userVotes[index].setVotes(votes);
    }

    notifyListeners();
  }

  void removeAllUserVotes() {
    _userVotes.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
