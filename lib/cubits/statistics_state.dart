import 'package:equatable/equatable.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/model/statistics.dart';

enum StatisticsStatus { loading, loaded, failure }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final StatisticsResponse? stats;

  /// The team's seasons, active first and then newest first.
  final List<SeasonDetails> seasons;

  /// The season being viewed. `null` means the team's active season.
  final int? selectedSeasonId;

  const StatisticsState({
    this.status = StatisticsStatus.loading,
    this.stats,
    this.seasons = const [],
    this.selectedSeasonId,
  });

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

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatisticsResponse? Function()? stats,
    List<SeasonDetails>? seasons,
    int? Function()? selectedSeasonId,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      stats: stats != null ? stats() : this.stats,
      seasons: seasons ?? this.seasons,
      selectedSeasonId:
          selectedSeasonId != null ? selectedSeasonId() : this.selectedSeasonId,
    );
  }

  @override
  List<Object?> get props => [status, stats, seasons, selectedSeasonId];
}
