import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/repository/team_dbu_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> fetchDashboardData(int teamId, {bool showLoading = true}) async {
    if (showLoading || state.status == HomeStatus.initial) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final results = await Future.wait([
        MatchRepository.getMatches(),
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

      final playedMatches = matches.where((m) => m.hasMatchBeenPlayed).toList();
      playedMatches.sort((a, b) => b.date.compareTo(a.date));
      if (playedMatches.isNotEmpty) {
        lastMatch = playedMatches.first;
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
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
        isRegisteringForNextMatch: false,
      ));
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
