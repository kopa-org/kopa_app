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
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<StatisticsResponse?> _safeFetchStats(int teamId) async {
    try {
      return await StatisticsRepository.getStatistics(teamId);
    } catch (e) {
      return StatisticsResponse(
        player: MockData.playerStats,
        club: MockData.clubStats,
      );
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
    try {
      await MatchRepository.registerForMatch(matchId);
      await fetchDashboardData(teamId);
    } catch (e) {
      // Intentionally swallow or log?
    }
  }
}
