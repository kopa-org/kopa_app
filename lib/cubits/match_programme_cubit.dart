import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

class MatchProgrammeCubit extends Cubit<MatchProgrammeState> {
  MatchProgrammeCubit() : super(const MatchProgrammeState());

  Future<void> loadMatches({
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    if (showLoading || state.status == MatchProgrammeStatus.initial) {
      emit(state.copyWith(
        status: MatchProgrammeStatus.loading,
        errorMessage: null,
      ));
    }

    try {
      final matches = await MatchRepository.getMatchSummaries(
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(
        status: MatchProgrammeStatus.loaded,
        matches: matches,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MatchProgrammeStatus.failure,
        errorMessage: 'Kunne ikke hente kampprogrammet.',
      ));
    }
  }

  Future<bool> createMatch({
    required String homeTeam,
    required String awayTeam,
    required DateTime date,
    required String location,
    required DateTime? meetingTime,
    String? notes,
  }) async {
    emit(state.copyWith(
      status: MatchProgrammeStatus.creating,
      errorMessage: null,
    ));

    try {
      await MatchRepository.createMatch(
        homeTeam,
        awayTeam,
        date,
        location,
        meetingTime,
        notes: notes,
      );
      AppAnalytics.logEvent('match_created');
      MatchRepository.invalidateMatchSummaries();
      await loadMatches(forceRefresh: true);
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: MatchProgrammeStatus.loaded,
        errorMessage: 'Kunne ikke oprette kampen.',
      ));
      return false;
    }
  }
}
