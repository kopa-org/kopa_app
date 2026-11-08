import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/statistics_state.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final int teamId;

  StatisticsCubit({required this.teamId}) : super(const StatisticsState());

  Future<void> load() async {
    await Future.wait([loadStatistics(), _loadSeasons()]);
  }

  Future<void> loadStatistics({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(status: StatisticsStatus.loading));
    }

    final seasonId = state.selectedSeasonId;
    try {
      final stats = await StatisticsRepository.getStatistics(
        teamId,
        seasonId: seasonId,
      );
      // Drop results for a season the user has already switched away from.
      if (isClosed || state.selectedSeasonId != seasonId) return;
      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        stats: () => stats,
      ));
    } catch (_) {
      if (isClosed || state.selectedSeasonId != seasonId) return;
      emit(state.copyWith(status: StatisticsStatus.failure));
    }
  }

  /// A failure leaves the list empty, which hides the season selector.
  Future<void> _loadSeasons() async {
    try {
      final seasons = await TeamSeasonRepository.getSeasons(teamId);
      if (isClosed) return;
      emit(state.copyWith(seasons: seasons));
    } catch (_) {
      // The active season's statistics still load without the selector.
    }
  }

  /// Shows [season]'s statistics. The active season is stored as `null` so
  /// the page keeps following whichever season the backend treats as active.
  Future<void> selectSeason(SeasonDetails season) async {
    final seasonId = season.isActive ? null : season.id;
    if (seasonId == state.selectedSeasonId) return;

    AppAnalytics.logEvent(
      'statistics_season_selected',
      parameters: {'is_active': season.isActive ? 'true' : 'false'},
    );
    emit(state.copyWith(
      selectedSeasonId: () => seasonId,
      stats: () => null,
      status: StatisticsStatus.loading,
    ));
    await loadStatistics();
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
      stats: () => null,
      status: StatisticsStatus.loading,
    ));
    await loadStatistics();
  }
}
