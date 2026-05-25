import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/player_plus_state.dart';
import 'package:kopa/model/player_plus.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/player_plus_repository.dart';

typedef PlayerPlusOverviewLoader = Future<PlayerPlusOverview> Function(
  int teamId,
);
typedef PlayerPlusLeaderboardLoader = Future<PlayerPlusLeaderboard> Function({
  required int teamId,
  required String scope,
  required String category,
});

class PlayerPlusCubit extends Cubit<PlayerPlusState> {
  PlayerPlusCubit({
    PlayerPlusOverviewLoader? overviewLoader,
    PlayerPlusLeaderboardLoader? leaderboardLoader,
  })  : _overviewLoader = overviewLoader ?? PlayerPlusRepository.getOverview,
        _leaderboardLoader =
            leaderboardLoader ?? PlayerPlusRepository.getLeaderboard,
        super(const PlayerPlusState());

  final PlayerPlusOverviewLoader _overviewLoader;
  final PlayerPlusLeaderboardLoader _leaderboardLoader;

  Future<void> load(UserDetails? currentUser) async {
    final team = currentUser?.teamDetails;
    if (team == null) {
      emit(
        PlayerPlusState(
          status: PlayerPlusStatus.noTeam,
          currentUserId: currentUser?.id,
        ),
      );
      return;
    }

    emit(
      PlayerPlusState(
        status: PlayerPlusStatus.loading,
        teamId: team.id,
        teamTitle: team.title,
        currentUserId: currentUser?.id,
      ),
    );

    try {
      final overview = await _overviewLoader(team.id);
      final selectedCategory = _defaultCategory(overview.categories);
      final selectedScope = _defaultScope(overview.scopes);

      final leaderboard = await _leaderboardLoader(
        teamId: team.id,
        scope: selectedScope,
        category: selectedCategory,
      );

      emit(
        PlayerPlusState(
          status: leaderboard.rows.isEmpty
              ? PlayerPlusStatus.empty
              : PlayerPlusStatus.loaded,
          teamId: team.id,
          teamTitle: team.title,
          currentUserId: currentUser?.id,
          overview: overview,
          leaderboard: leaderboard,
          selectedCategory: selectedCategory,
          selectedScope: selectedScope,
        ),
      );
    } catch (error) {
      emit(
        PlayerPlusState(
          status: PlayerPlusStatus.error,
          teamId: team.id,
          teamTitle: team.title,
          currentUserId: currentUser?.id,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> selectCategory(String category) async {
    if (state.teamId == null ||
        state.selectedScope == null ||
        state.selectedCategory == category) {
      return;
    }

    await _reloadLeaderboard(
      category: category,
      scope: state.selectedScope!,
    );
  }

  Future<void> selectScope(String scope) async {
    if (state.teamId == null ||
        state.selectedCategory == null ||
        state.selectedScope == scope) {
      return;
    }

    await _reloadLeaderboard(
      category: state.selectedCategory!,
      scope: scope,
    );
  }

  Future<void> retry() async {
    final teamId = state.teamId;
    if (teamId == null) {
      return;
    }

    if (state.selectedCategory == null || state.selectedScope == null) {
      emit(
          state.copyWith(status: PlayerPlusStatus.loading, errorMessage: null));

      try {
        final overview = await _overviewLoader(teamId);
        final selectedCategory = _defaultCategory(overview.categories);
        final selectedScope = _defaultScope(overview.scopes);
        final leaderboard = await _leaderboardLoader(
          teamId: teamId,
          scope: selectedScope,
          category: selectedCategory,
        );

        emit(
          state.copyWith(
            status: leaderboard.rows.isEmpty
                ? PlayerPlusStatus.empty
                : PlayerPlusStatus.loaded,
            overview: overview,
            leaderboard: leaderboard,
            selectedCategory: selectedCategory,
            selectedScope: selectedScope,
            errorMessage: null,
          ),
        );
      } catch (error) {
        emit(
          state.copyWith(
            status: PlayerPlusStatus.error,
            errorMessage: error.toString(),
          ),
        );
      }
      return;
    }

    await _reloadLeaderboard(
      category: state.selectedCategory!,
      scope: state.selectedScope!,
      refreshOverview: state.overview == null,
    );
  }

  Future<void> _reloadLeaderboard({
    required String category,
    required String scope,
    bool refreshOverview = false,
  }) async {
    final teamId = state.teamId;
    final overview = state.overview;
    if (teamId == null) return;

    emit(
      state.copyWith(
        status: PlayerPlusStatus.loading,
        selectedCategory: category,
        selectedScope: scope,
        errorMessage: null,
      ),
    );

    try {
      final resolvedOverview = refreshOverview || overview == null
          ? await _overviewLoader(teamId)
          : overview;
      final leaderboard = await _leaderboardLoader(
        teamId: teamId,
        scope: scope,
        category: category,
      );

      emit(
        state.copyWith(
          status: leaderboard.rows.isEmpty
              ? PlayerPlusStatus.empty
              : PlayerPlusStatus.loaded,
          overview: resolvedOverview,
          leaderboard: leaderboard,
          selectedCategory: category,
          selectedScope: scope,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerPlusStatus.error,
          selectedCategory: category,
          selectedScope: scope,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  String _defaultCategory(List<String> categories) {
    if (categories.isEmpty) {
      return 'overall';
    }

    if (categories.contains('overall')) {
      return 'overall';
    }

    return categories.first;
  }

  String _defaultScope(List<String> scopes) {
    if (scopes.isEmpty) {
      return 'team';
    }

    if (scopes.contains('team')) {
      return 'team';
    }

    return scopes.first;
  }
}
