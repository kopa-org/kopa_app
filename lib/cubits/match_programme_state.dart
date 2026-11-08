import 'package:equatable/equatable.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_details.dart';

enum MatchProgrammeStatus { initial, loading, loaded, creating, failure }

class MatchProgrammeState extends Equatable {
  final MatchProgrammeStatus status;
  final List<MatchDetails> matches;
  final String? errorMessage;

  /// The team's seasons, active first and then newest first.
  final List<SeasonDetails> seasons;

  /// The season being viewed. `null` means the team's active season.
  final int? selectedSeasonId;

  const MatchProgrammeState({
    this.status = MatchProgrammeStatus.initial,
    this.matches = const [],
    this.errorMessage,
    this.seasons = const [],
    this.selectedSeasonId,
  });

  bool get isLoading =>
      status == MatchProgrammeStatus.initial ||
      status == MatchProgrammeStatus.loading;

  bool get isCreating => status == MatchProgrammeStatus.creating;

  SeasonDetails? get activeSeason {
    for (final season in seasons) {
      if (season.isActive) return season;
    }
    return null;
  }

  /// The season shown in the selector, falling back to the active season.
  SeasonDetails? get selectedSeason {
    final selectedId = selectedSeasonId;
    if (selectedId == null) return activeSeason;

    for (final season in seasons) {
      if (season.id == selectedId) return season;
    }
    return activeSeason;
  }

  /// True while a finished season is shown instead of the active one.
  bool get isViewingPastSeason {
    final selected = selectedSeason;
    return selectedSeasonId != null && selected != null && !selected.isActive;
  }

  MatchProgrammeState copyWith({
    MatchProgrammeStatus? status,
    List<MatchDetails>? matches,
    String? errorMessage,
    List<SeasonDetails>? seasons,
    int? Function()? selectedSeasonId,
  }) {
    return MatchProgrammeState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage,
      seasons: seasons ?? this.seasons,
      selectedSeasonId:
          selectedSeasonId != null ? selectedSeasonId() : this.selectedSeasonId,
    );
  }

  @override
  List<Object?> get props =>
      [status, matches, errorMessage, seasons, selectedSeasonId];
}
