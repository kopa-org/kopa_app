import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/match_polls_state.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_vote.dart';
import 'package:kopa/repository/match_polls_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

class MatchPollsCubit extends Cubit<MatchPollsState> {
  MatchPollsCubit() : super(const MatchPollsState());

  void setData({
    required List<UserDetails> squad,
    required List<MatchDetails> matches,
    List<MatchPollDetails> matchPolls = const [],
  }) {
    emit(state.copyWith(
      status: MatchPollsStatus.loaded,
      squad: squad,
      matches: matches,
      matchPolls: matchPolls,
      rows: _buildRows(squad, matchPolls),
      errorMessage: null,
      formErrorMessage: null,
    ));
  }

  Future<void> load() async {
    emit(state.copyWith(
      status: MatchPollsStatus.loading,
      errorMessage: null,
      formErrorMessage: null,
    ));

    try {
      final results = await Future.wait([
        UsersRepository.getSquad(),
        MatchRepository.getMatchSummaries(),
        MatchPollsRepository.getMatchPolls(),
      ]);

      final squad = results[0] as List<UserDetails>;
      final matches = results[1] as List<MatchDetails>;
      final matchPolls = results[2] as List<MatchPollDetails>;

      emit(state.copyWith(
        status: MatchPollsStatus.loaded,
        squad: squad,
        matches: matches,
        matchPolls: matchPolls,
        rows: _buildRows(squad, matchPolls),
        errorMessage: null,
        formErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MatchPollsStatus.failure,
        errorMessage: 'Kunne ikke hente afstemninger.',
      ));
    }
  }

  Future<MatchPollDetails?> createMatchPoll({
    required int selectedMatchIndex,
    required List<UserVote> userVotes,
  }) async {
    final validationError = _validateCreate(selectedMatchIndex, userVotes);
    if (validationError != null) {
      emit(state.copyWith(formErrorMessage: validationError));
      return null;
    }

    final matchId = state.matches[selectedMatchIndex].id;
    emit(state.copyWith(
      status: MatchPollsStatus.submitting,
      formErrorMessage: null,
    ));

    try {
      final matchPollId =
          await MatchPollsRepository.createMatchPoll(matchId, userVotes);
      final createdMatchPoll =
          await MatchPollsRepository.getMatchPoll(matchPollId);

      AppAnalytics.logEvent(
        'match_poll_created',
        parameters: {'vote_count': userVotes.length},
      );

      await load();
      return createdMatchPoll;
    } catch (e) {
      emit(state.copyWith(
        status: MatchPollsStatus.loaded,
        formErrorMessage: 'Kunne ikke oprette afstemningen.',
      ));
      return null;
    }
  }

  void clearFormError() {
    emit(state.copyWith(formErrorMessage: null));
  }

  String? _validateCreate(int selectedMatchIndex, List<UserVote> userVotes) {
    if (state.matches.isEmpty) {
      return 'Der er ingen kampe at oprette en afstemning for.';
    }

    if (selectedMatchIndex < 0 || selectedMatchIndex >= state.matches.length) {
      return 'Vælg en gyldig kamp.';
    }

    final matchId = state.matches[selectedMatchIndex].id;
    final exists = state.matchPolls.any((poll) => poll.eventId == matchId);
    if (exists) {
      return 'Afstemning til kampen eksisterer allerede. Vælg en anden kamp.';
    }

    if (userVotes.isEmpty) {
      return 'Afgiv mindst én stemme for at oprette en afstemning.';
    }

    return null;
  }

  List<MatchPollRow> _buildRows(
    List<UserDetails> squad,
    List<MatchPollDetails> matchPolls,
  ) {
    return matchPolls.map((poll) {
      return MatchPollRow(
        matchPoll: poll,
        user: squad.firstWhere(
          (user) => user.id == poll.playerOfTheMatchDetails.id,
          orElse: () => poll.playerOfTheMatchDetails,
        ),
      );
    }).toList();
  }
}
