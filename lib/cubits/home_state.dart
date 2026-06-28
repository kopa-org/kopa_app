import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeState {
  final HomeStatus status;
  final MatchDetails? nextMatch;
  final MatchDetails? lastMatch;
  final List<MatchDetails> matches;
  final StatisticsResponse? statistics;
  final FineBoxDetails? fineBox;
  final String? errorMessage;
  final bool isRegisteringForNextMatch;

  const HomeState({
    this.status = HomeStatus.initial,
    this.nextMatch,
    this.lastMatch,
    this.matches = const [],
    this.statistics,
    this.fineBox,
    this.errorMessage,
    this.isRegisteringForNextMatch = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    MatchDetails? nextMatch,
    MatchDetails? lastMatch,
    List<MatchDetails>? matches,
    StatisticsResponse? statistics,
    FineBoxDetails? fineBox,
    String? errorMessage,
    bool? isRegisteringForNextMatch,
  }) {
    return HomeState(
      status: status ?? this.status,
      nextMatch: nextMatch ?? this.nextMatch,
      lastMatch: lastMatch ?? this.lastMatch,
      matches: matches ?? this.matches,
      statistics: statistics ?? this.statistics,
      fineBox: fineBox ?? this.fineBox,
      errorMessage: errorMessage ?? this.errorMessage,
      isRegisteringForNextMatch:
          isRegisteringForNextMatch ?? this.isRegisteringForNextMatch,
    );
  }
}
