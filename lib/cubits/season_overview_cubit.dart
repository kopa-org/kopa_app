import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';

class SeasonOverviewState {
  final bool loading;
  final SeasonDetails? activeSeason;
  final DbuStandings? standings;

  /// Matches (not trainings) in the active season; null when unknown.
  final int? matchCount;
  final int? playedCount;
  final DbuSeasonOutlook? outlook;

  const SeasonOverviewState({
    this.loading = false,
    this.activeSeason,
    this.standings,
    this.matchCount,
    this.playedCount,
    this.outlook,
  });

  int? get position => standings?.currentTeamRow?.position;

  int? get poolSize {
    final rows = standings?.rows ?? const [];
    return rows.isEmpty ? null : rows.length;
  }
}

/// Loads the facts shown on the Season & DBU settings screen. Each source is
/// loaded independently so one failing request only hides its own section.
class SeasonOverviewCubit extends Cubit<SeasonOverviewState> {
  final int? teamId;
  final Future<List<SeasonDetails>> Function(int teamId) _loadSeasons;
  final Future<DbuStandings?> Function(int teamId) _loadStandings;
  final Future<List<MatchDetails>> Function() _loadMatches;
  final Future<DbuSeasonOutlook> Function(int teamId) _loadOutlook;

  SeasonOverviewCubit({
    required this.teamId,
    Future<List<SeasonDetails>> Function(int teamId)? loadSeasons,
    Future<DbuStandings?> Function(int teamId)? loadStandings,
    Future<List<MatchDetails>> Function()? loadMatches,
    Future<DbuSeasonOutlook> Function(int teamId)? loadOutlook,
  })  : _loadSeasons = loadSeasons ?? TeamSeasonRepository.getSeasons,
        _loadStandings = loadStandings ?? TeamDbuRepository.getStandings,
        _loadMatches = loadMatches ??
            (() => MatchRepository.getMatchSummaries(forceRefresh: true)),
        _loadOutlook =
            loadOutlook ?? ((id) => TeamDbuRepository.getSeasonOutlook(id)),
        super(const SeasonOverviewState());

  Future<void> load() async {
    final id = teamId;
    if (id == null) return;
    emit(SeasonOverviewState(
      loading: true,
      activeSeason: state.activeSeason,
      standings: state.standings,
      matchCount: state.matchCount,
      playedCount: state.playedCount,
      outlook: state.outlook,
    ));

    Future<T?> attempt<T>(Future<T> Function() load) async {
      try {
        return await load();
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait([
      attempt(() => _loadSeasons(id)),
      attempt(() => _loadStandings(id)),
      attempt(_loadMatches),
      attempt(() => _loadOutlook(id)),
    ]);
    if (isClosed) return;

    final seasons = results[0] as List<SeasonDetails>?;
    final matches = (results[2] as List<MatchDetails>?)
        ?.where((match) => match.isMatch)
        .toList();

    SeasonDetails? active;
    for (final season in seasons ?? const <SeasonDetails>[]) {
      if (season.isActive) active = season;
    }

    emit(SeasonOverviewState(
      activeSeason: active,
      standings: results[1] as DbuStandings?,
      matchCount: matches?.length,
      playedCount: matches?.where((match) => match.hasFinalScore).length,
      outlook: results[3] as DbuSeasonOutlook?,
    ));
  }
}
