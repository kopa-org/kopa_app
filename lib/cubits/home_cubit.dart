import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/statistics_repository.dart';

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
      ]);

      final matches = results[0] as List<MatchDetails>;
      final statistics = results[1] as StatisticsResponse?;
      final fineBox = results[2] as FineBoxDetails?;

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
        statistics: statistics,
        fineBox: fineBox,
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

  Future<void> registerForMatch(int matchId, int teamId) async {
    if (state.isRegisteringForNextMatch) return;

    final nextMatch = state.nextMatch;
    if (nextMatch != null && nextMatch.id == matchId) {
      emit(state.copyWith(
        nextMatch: MatchDetails(
          id: nextMatch.id,
          type: nextMatch.type,
          homeTeam: nextMatch.homeTeam,
          awayTeam: nextMatch.awayTeam,
          date: nextMatch.date,
          meetingTime: nextMatch.meetingTime,
          location: nextMatch.location,
          createdAt: nextMatch.createdAt,
          updatedAt: nextMatch.updatedAt,
          notes: nextMatch.notes,
          matchPollDetails: nextMatch.matchPollDetails,
          homeTeamScore: nextMatch.homeTeamScore,
          awayTeamScore: nextMatch.awayTeamScore,
          isHomeTeam: nextMatch.isHomeTeam,
          isCurrentUserRegistered: true,
          isCurrentUserSelected: nextMatch.isCurrentUserSelected,
          registeredCount: nextMatch.isCurrentUserRegistered
              ? nextMatch.registeredCount
              : nextMatch.registeredCount + 1,
          unavailableCount: nextMatch.unavailableCount,
          latitude: nextMatch.latitude,
          longitude: nextMatch.longitude,
          attendanceDetailsList: nextMatch.attendanceDetailsList,
          matchEventDetailsList: nextMatch.matchEventDetailsList,
          playerRatingDetailsList: nextMatch.playerRatingDetailsList,
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
}
