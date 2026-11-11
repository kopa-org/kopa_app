import 'package:equatable/equatable.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/repository/team_dbu_repository.dart';

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

  /// Whether the next DBU season is published. Only loaded once nothing is
  /// left on the schedule, so the home screen can show the season-over state.
  final DbuSeasonOutlook? seasonOutlook;
  final bool isCheckingSeasonOutlook;

  /// The ended season's Wrapped story, and whether this device has opened it.
  final SeasonWrapped? seasonWrapped;
  final bool? hasSeenSeasonWrapped;
  final bool isLoadingSeasonWrapped;

  /// Players waiting for the team owner to approve their join request.
  final int pendingJoinRequests;

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
    this.seasonOutlook,
    this.isCheckingSeasonOutlook = false,
    this.seasonWrapped,
    this.hasSeenSeasonWrapped,
    this.isLoadingSeasonWrapped = false,
    this.pendingJoinRequests = 0,
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
    Object? seasonOutlook = _unset,
    bool? isCheckingSeasonOutlook,
    Object? seasonWrapped = _unset,
    Object? hasSeenSeasonWrapped = _unset,
    bool? isLoadingSeasonWrapped,
    int? pendingJoinRequests,
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
      seasonOutlook: seasonOutlook == _unset
          ? this.seasonOutlook
          : seasonOutlook as DbuSeasonOutlook?,
      isCheckingSeasonOutlook:
          isCheckingSeasonOutlook ?? this.isCheckingSeasonOutlook,
      seasonWrapped: seasonWrapped == _unset
          ? this.seasonWrapped
          : seasonWrapped as SeasonWrapped?,
      hasSeenSeasonWrapped: hasSeenSeasonWrapped == _unset
          ? this.hasSeenSeasonWrapped
          : hasSeenSeasonWrapped as bool?,
      isLoadingSeasonWrapped:
          isLoadingSeasonWrapped ?? this.isLoadingSeasonWrapped,
      pendingJoinRequests: pendingJoinRequests ?? this.pendingJoinRequests,
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
        seasonOutlook,
        isCheckingSeasonOutlook,
        seasonWrapped,
        hasSeenSeasonWrapped,
        isLoadingSeasonWrapped,
        pendingJoinRequests,
      ];
}
