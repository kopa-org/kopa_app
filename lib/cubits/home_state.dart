import 'package:equatable/equatable.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/dbu_standings.dart';

enum HomeStatus { initial, loading, loaded, failure }

const Object _unset = Object();

class HomeState extends Equatable {
  final HomeStatus status;
  final MatchDetails? nextMatch;
  final MatchDetails? lastMatch;
  final List<MatchDetails> matches;
  final StatisticsResponse? statistics;
  final FineBoxDetails? fineBox;
  final DbuStandings? dbuStandings;
  final String? errorMessage;
  final bool isRegisteringForNextMatch;

  const HomeState({
    this.status = HomeStatus.initial,
    this.nextMatch,
    this.lastMatch,
    this.matches = const [],
    this.statistics,
    this.fineBox,
    this.dbuStandings,
    this.errorMessage,
    this.isRegisteringForNextMatch = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    Object? nextMatch = _unset,
    Object? lastMatch = _unset,
    List<MatchDetails>? matches,
    Object? statistics = _unset,
    Object? fineBox = _unset,
    Object? dbuStandings = _unset,
    Object? errorMessage = _unset,
    bool? isRegisteringForNextMatch,
  }) {
    return HomeState(
      status: status ?? this.status,
      nextMatch:
          nextMatch == _unset ? this.nextMatch : nextMatch as MatchDetails?,
      lastMatch:
          lastMatch == _unset ? this.lastMatch : lastMatch as MatchDetails?,
      matches: matches ?? this.matches,
      statistics: statistics == _unset
          ? this.statistics
          : statistics as StatisticsResponse?,
      fineBox: fineBox == _unset ? this.fineBox : fineBox as FineBoxDetails?,
      dbuStandings: dbuStandings == _unset
          ? this.dbuStandings
          : dbuStandings as DbuStandings?,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      isRegisteringForNextMatch:
          isRegisteringForNextMatch ?? this.isRegisteringForNextMatch,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nextMatch,
        lastMatch,
        matches,
        statistics,
        fineBox,
        dbuStandings,
        errorMessage,
        isRegisteringForNextMatch,
      ];
}
