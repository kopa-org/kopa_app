import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:kopa/model/user_vote.dart';

class UserVotesState extends ChangeNotifier {
  final List<UserVote> _userVotes = [];

  UserVotesState();

  UnmodifiableListView<UserVote> get userVotes =>
      UnmodifiableListView(_userVotes);

  int votesForUser(int userId) {
    final index = _userVotes.indexWhere((x) => x.userId == userId);
    return index == -1 ? 0 : _userVotes[index].votes;
  }

  void addUserVote(UserVote userVote) {
    bool doesUserHaveNotVotesYet =
        !_userVotes.any((x) => x.userId == userVote.userId);

    if (doesUserHaveNotVotesYet) {
      _userVotes.add(userVote);
      notifyListeners();
    } else {
      updateUserVote(userVote.userId, userVote.votes);
    }
  }

  void updateUserVote(int userId, int votes) {
    final index = _userVotes.indexWhere((x) => x.userId == userId);

    if (votes == 0) {
      _userVotes.removeWhere((x) => x.userId == userId);
    } else if (index == -1) {
      _userVotes.add(UserVote(userId: userId, votes: votes));
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
