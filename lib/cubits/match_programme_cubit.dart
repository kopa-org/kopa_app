import 'package:kopa/l10n/current_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/model/event_type.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';
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

    final seasonId = state.selectedSeasonId;
    try {
      final matches = await MatchRepository.getMatchSummaries(
        forceRefresh: forceRefresh,
        seasonId: seasonId,
      );
      // Drop results for a season the user has already switched away from.
      if (isClosed || state.selectedSeasonId != seasonId) return;
      emit(state.copyWith(
        status: MatchProgrammeStatus.loaded,
        matches: matches,
        errorMessage: null,
      ));
    } catch (e) {
      if (isClosed || state.selectedSeasonId != seasonId) return;
      emit(state.copyWith(
        status: MatchProgrammeStatus.failure,
        errorMessage: currentL10n.uiCouldNotFetchTheMatchSchedule,
      ));
    }
  }

  /// Loads the team's seasons for the season selector.
  ///
  /// A failure leaves the list empty, which hides the selector, so the match
  /// schedule itself keeps working.
  Future<void> loadSeasons(int teamId) async {
    try {
      final seasons = await TeamSeasonRepository.getSeasons(teamId);
      if (isClosed) return;
      emit(state.copyWith(seasons: seasons));
    } catch (_) {
      // The selector stays hidden; the active season's matches still load.
    }
  }

  /// Shows [season]'s matches. The active season is stored as `null` so the
  /// list keeps following whichever season the backend treats as active.
  Future<void> selectSeason(SeasonDetails season) async {
    final seasonId = season.isActive ? null : season.id;
    if (seasonId == state.selectedSeasonId) return;

    AppAnalytics.logEvent(
      'match_programme_season_selected',
      parameters: {'is_active': season.isActive ? 'true' : 'false'},
    );
    emit(state.copyWith(
      selectedSeasonId: () => seasonId,
      matches: const [],
      status: MatchProgrammeStatus.loading,
    ));
    await loadMatches();
  }

  Future<void> showActiveSeason() async {
    final active = state.activeSeason;
    if (active != null) {
      await selectSeason(active);
      return;
    }
    if (state.selectedSeasonId == null) return;

    emit(state.copyWith(
      selectedSeasonId: () => null,
      matches: const [],
      status: MatchProgrammeStatus.loading,
    ));
    await loadMatches();
  }

  Future<bool> createMatch({
    required String homeTeam,
    required String awayTeam,
    required DateTime date,
    required String location,
    required DateTime? meetingTime,
    String? notes,
  }) async {
    return createEvent(
      type: KopaEventType.match,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      date: date,
      location: location,
      meetingTime: meetingTime,
      notes: notes,
    );
  }

  Future<bool> createEvent({
    required KopaEventType type,
    String? homeTeam,
    String? awayTeam,
    required DateTime date,
    required String location,
    DateTime? meetingTime,
    String? category,
    String? notes,
    List<DateTime>? occurrences,
  }) async {
    emit(state.copyWith(
      status: MatchProgrammeStatus.creating,
      errorMessage: null,
    ));

    try {
      await MatchRepository.createEvent(
        type: type,
        firstTeam: homeTeam,
        secondTeam: awayTeam,
        date: date,
        location: location,
        meetingTime: meetingTime,
        category: category,
        notes: notes,
        occurrences: occurrences,
      );
      AppAnalytics.logEvent(
        type == KopaEventType.training ? 'training_created' : 'match_created',
      );
      MatchRepository.invalidateMatchSummaries();
      await loadMatches(forceRefresh: true);
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: MatchProgrammeStatus.loaded,
        errorMessage: currentL10n.eventCreateMatchFailed,
      ));
      return false;
    }
  }
}
