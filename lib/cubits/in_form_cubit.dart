import 'dart:async';

import 'package:kopa/l10n/current_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/repository/in_form_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';

typedef InFormLeaderboardLoader = Future<InFormLeaderboard> Function({
  required int teamId,
  required InFormPeriod period,
  String? position,
  int? seasonId,
});

typedef InFormSeasonsLoader = Future<List<SeasonDetails>> Function(int teamId);

class InFormCubit extends Cubit<InFormState> {
  InFormCubit({
    InFormLeaderboardLoader? loader,
    InFormSeasonsLoader? seasonsLoader,
  })  : _loader = loader ?? InFormRepository.getLeaderboard,
        _seasonsLoader = seasonsLoader ?? TeamSeasonRepository.getSeasons,
        super(const InFormState());

  final InFormLeaderboardLoader _loader;
  final InFormSeasonsLoader _seasonsLoader;
  bool _seasonsRequested = false;

  /// Loads the season list once; a failure only hides the season selector.
  Future<void> _loadSeasons(int teamId) async {
    if (_seasonsRequested) return;
    _seasonsRequested = true;
    try {
      final seasons = await _seasonsLoader(teamId);
      if (!isClosed) emit(state.copyWith(seasons: seasons));
    } catch (_) {
      _seasonsRequested = false;
    }
  }

  /// Shows [season] (for the "Sæson" period). The active season is stored as
  /// `null` so the page keeps following the season the backend treats as
  /// active.
  Future<void> selectSeason(SeasonDetails season) async {
    final seasonId = season.isActive ? null : season.id;
    if (seasonId == state.selectedSeasonId || state.teamId == null) return;
    emit(state.copyWith(selectedSeasonId: () => seasonId));
    await load(state.teamId!);
  }

  Future<void> showActiveSeason() async {
    if (state.selectedSeasonId == null || state.teamId == null) return;
    emit(state.copyWith(selectedSeasonId: () => null));
    await load(state.teamId!);
  }

  Future<void> load(int teamId) async {
    emit(state.copyWith(
      status: InFormStatus.loading,
      teamId: teamId,
      errorMessage: null,
    ));
    unawaited(_loadSeasons(teamId));

    final period = state.period;
    final position = state.position;
    final seasonId = state.requestSeasonId;
    try {
      final leaderboard = await _loader(
        teamId: teamId,
        period: period,
        position: position,
        seasonId: seasonId,
      );
      // Drop results for filters the user has already changed.
      if (isClosed ||
          state.period != period ||
          state.position != position ||
          state.requestSeasonId != seasonId) {
        return;
      }
      emit(state.copyWith(
        status:
            leaderboard.rows.isEmpty ? InFormStatus.empty : InFormStatus.loaded,
        leaderboard: leaderboard,
        errorMessage: null,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: InFormStatus.failure,
        errorMessage: currentL10n.uiCouldNotFetchInForm,
      ));
    }
  }

  Future<void> selectPeriod(InFormPeriod period) async {
    if (period == state.period || state.teamId == null) return;
    emit(state.copyWith(period: period));
    await load(state.teamId!);
  }

  Future<void> selectPosition(String? position) async {
    if (position == state.position || state.teamId == null) return;
    emit(state.copyWith(
      position: position,
      clearPosition: position == null,
    ));
    await load(state.teamId!);
  }
}
