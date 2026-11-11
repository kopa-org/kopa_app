import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/repository/season_wrapped_repository.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/services/secure_storage_service.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> fetchDashboardData(
    int teamId, {
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    if (showLoading || state.status == HomeStatus.initial) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final results = await Future.wait([
        MatchRepository.getMatchSummaries(
          forceRefresh: forceRefresh || showLoading,
        ),
        _safeFetchStats(teamId),
        _safeFetchFineBox(),
        _safeFetchDbuStandings(teamId),
      ]);

      final matches = results[0] as List<MatchDetails>;
      final statistics = results[1] as StatisticsResponse?;
      final fineBox = results[2] as FineBoxDetails?;
      final dbuStandings = results[3] as DbuStandings?;

      MatchDetails? nextMatch;
      MatchDetails? lastMatch;

      final now = DateTime.now();
      final unplayedMatches = matches
          .where((m) =>
              !m.hasMatchBeenPlayed &&
              m.date.isAfter(now.subtract(const Duration(days: 1))))
          .toList();
      unplayedMatches.sort((a, b) => a.date.compareTo(b.date));
      if (unplayedMatches.isNotEmpty) {
        nextMatch = unplayedMatches.first;
      }
      // The season is over once no *match* is left; weekly trainings often
      // keep going after the last match and must not hide the season end.
      final seasonOver = !unplayedMatches.any((m) => m.isMatch);

      final playedMatches = matches.where((m) => m.hasMatchBeenPlayed).toList();
      playedMatches.sort((a, b) => b.date.compareTo(a.date));
      if (playedMatches.isNotEmpty) {
        lastMatch = playedMatches.first;
      }

      if (lastMatch != null) {
        try {
          lastMatch = await MatchRepository.getMatch(lastMatch.id);
        } catch (_) {
          // The summary remains usable when the optional result details fail.
        }
      }

      emit(state.copyWith(
        status: HomeStatus.loaded,
        nextMatch: nextMatch,
        lastMatch: lastMatch,
        matches: matches,
        statistics: statistics,
        fineBox: fineBox,
        dbuStandings: dbuStandings,
        isRegisteringForNextMatch: false,
        errorMessage: null,
        // Back on schedule: drop any stale season-over outlook.
        seasonOutlook: seasonOver ? state.seasonOutlook : null,
        seasonWrapped: seasonOver ? state.seasonWrapped : null,
      ));

      // Nothing left to play: find out whether the next season is out yet.
      // Loaded after the dashboard so a slow DBU lookup never blocks it.
      if (seasonOver &&
          (state.seasonOutlook == null || showLoading || forceRefresh)) {
        unawaited(loadSeasonOutlook(teamId));
      }
      if (seasonOver &&
          (state.seasonWrapped == null || showLoading || forceRefresh)) {
        unawaited(loadSeasonWrapped(teamId));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
        isRegisteringForNextMatch: false,
      ));
    }
  }

  /// Checks DBU for the team's next season. [refresh] is the manager's
  /// "check again", which asks the backend to bypass its cache.
  Future<void> loadSeasonOutlook(int teamId, {bool refresh = false}) async {
    if (state.isCheckingSeasonOutlook) return;
    emit(state.copyWith(isCheckingSeasonOutlook: true));

    DbuSeasonOutlook? outlook;
    try {
      outlook = await TeamDbuRepository.getSeasonOutlook(
        teamId,
        refresh: refresh,
      );
    } catch (_) {
      // Keep what we had; without any answer the screen shows "waiting".
      outlook = state.seasonOutlook ??
          const DbuSeasonOutlook(status: DbuSeasonOutlookStatus.waiting);
    }

    if (isClosed) return;
    emit(state.copyWith(
      seasonOutlook: outlook,
      isCheckingSeasonOutlook: false,
    ));
  }

  /// Loads the ended season's Wrapped and whether this device has seen it.
  Future<void> loadSeasonWrapped(int teamId) async {
    if (state.isLoadingSeasonWrapped) return;
    emit(state.copyWith(isLoadingSeasonWrapped: true));

    SeasonWrapped? wrapped;
    var seen = state.hasSeenSeasonWrapped ?? false;
    try {
      wrapped = await SeasonWrappedRepository.getSeasonWrapped(teamId);
      final seasonId = wrapped.seasonId;
      if (seasonId != null) {
        seen = await _hasSeenWrapped(teamId, seasonId);
      }
    } catch (_) {
      wrapped = state.seasonWrapped;
    }

    if (isClosed) return;
    emit(state.copyWith(
      seasonWrapped: wrapped,
      hasSeenSeasonWrapped: seen,
      isLoadingSeasonWrapped: false,
    ));
  }

  /// Opening (or skipping) the Wrapped moves home on to the season-over state.
  Future<void> markSeasonWrappedSeen(int teamId) async {
    final seasonId = state.seasonWrapped?.seasonId;
    emit(state.copyWith(hasSeenSeasonWrapped: true));
    if (seasonId == null) return;
    try {
      await SecureStorageService.setSeasonWrappedSeen(teamId, seasonId);
    } catch (_) {
      // Seen only for this session when storage is unavailable.
    }
  }

  Future<bool> _hasSeenWrapped(int teamId, int seasonId) async {
    try {
      return await SecureStorageService.hasSeenSeasonWrapped(teamId, seasonId);
    } catch (_) {
      return false;
    }
  }

  Future<StatisticsResponse?> _safeFetchStats(int teamId) async {
    try {
      return await StatisticsRepository.getStatistics(teamId);
    } catch (_) {
      return null;
    }
  }

  Future<FineBoxDetails?> _safeFetchFineBox() async {
    try {
      return await FinesRepository.getFineBox();
    } catch (e) {
      return null;
    }
  }

  Future<DbuStandings?> _safeFetchDbuStandings(int teamId) async {
    try {
      return await TeamDbuRepository.getStandings(teamId);
    } catch (_) {
      return null;
    }
  }

  Future<void> registerForMatch(int matchId, int teamId) async {
    if (state.isRegisteringForNextMatch) return;

    final nextMatch = state.nextMatch;
    if (nextMatch != null && nextMatch.id == matchId) {
      emit(state.copyWith(
        nextMatch: _nextMatchWith(
          nextMatch,
          isCurrentUserRegistered: true,
          isCurrentUserSelected: nextMatch.isCurrentUserSelected,
          registeredCount: nextMatch.isCurrentUserRegistered
              ? nextMatch.registeredCount
              : nextMatch.registeredCount + 1,
          unavailableCount: nextMatch.unavailableCount,
        ),
        isRegisteringForNextMatch: true,
      ));
    } else {
      emit(state.copyWith(isRegisteringForNextMatch: true));
    }

    try {
      await MatchRepository.registerForMatch(matchId);
      MatchRepository.invalidateMatchSummaries();
      await fetchDashboardData(teamId, showLoading: false);
    } catch (e) {
      emit(state.copyWith(
        isRegisteringForNextMatch: false,
        errorMessage: e.toString(),
      ));
      await fetchDashboardData(teamId, showLoading: false);
    }
  }

  Future<void> declineMatch(int matchId, int teamId) async {
    if (state.isRegisteringForNextMatch) return;

    final nextMatch = state.nextMatch;
    if (nextMatch != null && nextMatch.id == matchId) {
      emit(state.copyWith(
        nextMatch: _nextMatchWith(
          nextMatch,
          isCurrentUserRegistered: false,
          isCurrentUserSelected: null,
          registeredCount: nextMatch.isCurrentUserRegistered
              ? nextMatch.registeredCount > 0
                  ? nextMatch.registeredCount - 1
                  : 0
              : nextMatch.registeredCount,
          unavailableCount: nextMatch.unavailableCount + 1,
        ),
        isRegisteringForNextMatch: true,
      ));
    } else {
      emit(state.copyWith(isRegisteringForNextMatch: true));
    }

    try {
      await MatchRepository.unregisterFromMatch(matchId);
      MatchRepository.invalidateMatchSummaries();
      await fetchDashboardData(teamId, showLoading: false);
    } catch (e) {
      emit(state.copyWith(
        isRegisteringForNextMatch: false,
        errorMessage: e.toString(),
      ));
      await fetchDashboardData(teamId, showLoading: false);
    }
  }

  MatchDetails _nextMatchWith(
    MatchDetails match, {
    required bool isCurrentUserRegistered,
    required bool? isCurrentUserSelected,
    required int registeredCount,
    required int unavailableCount,
  }) {
    return MatchDetails(
      id: match.id,
      type: match.type,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      date: match.date,
      meetingTime: match.meetingTime,
      location: match.location,
      createdAt: match.createdAt,
      updatedAt: match.updatedAt,
      notes: match.notes,
      matchPollDetails: match.matchPollDetails,
      homeTeamScore: match.homeTeamScore,
      awayTeamScore: match.awayTeamScore,
      isHomeTeam: match.isHomeTeam,
      isCurrentUserRegistered: isCurrentUserRegistered,
      isCurrentUserAttending: isCurrentUserRegistered,
      isCurrentUserSelected: isCurrentUserSelected,
      registeredCount: registeredCount,
      unavailableCount: unavailableCount,
      teamPlayerCount: match.teamPlayerCount,
      formation: match.formation,
      latitude: match.latitude,
      longitude: match.longitude,
      attendanceDetailsList: match.attendanceDetailsList,
      matchEventDetailsList: match.matchEventDetailsList,
      playerRatingDetailsList: match.playerRatingDetailsList,
    );
  }
}
