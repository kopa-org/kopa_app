import 'package:equatable/equatable.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/model/season_details.dart';

enum InFormStatus { initial, loading, loaded, empty, failure }

class InFormState extends Equatable {
  final InFormStatus status;
  final int? teamId;
  final InFormPeriod period;
  final String? position;
  final InFormLeaderboard? leaderboard;
  final String? errorMessage;

  /// The team's seasons, for the season selector under "Sæson".
  final List<SeasonDetails> seasons;

  /// The season shown for [InFormPeriod.currentSeason]; `null` follows the
  /// team's active season, like the statistics page.
  final int? selectedSeasonId;

  const InFormState({
    this.status = InFormStatus.initial,
    this.teamId,
    this.period = InFormPeriod.rollingThreeMonths,
    this.position,
    this.leaderboard,
    this.errorMessage,
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
    if (selectedId != null) {
      for (final season in seasons) {
        if (season.id == selectedId) return season;
      }
    }
    return activeSeason;
  }

  /// The season id sent to the API: only for the season period, and only
  /// when a season other than the active one is chosen.
  int? get requestSeasonId =>
      period == InFormPeriod.currentSeason ? selectedSeasonId : null;

  /// True while a finished season is shown instead of the active one.
  bool get isViewingPastSeason {
    final selected = selectedSeason;
    return requestSeasonId != null && selected != null && !selected.isActive;
  }

  InFormState copyWith({
    InFormStatus? status,
    int? teamId,
    InFormPeriod? period,
    String? position,
    bool clearPosition = false,
    InFormLeaderboard? leaderboard,
    String? errorMessage,
    List<SeasonDetails>? seasons,
    int? Function()? selectedSeasonId,
  }) {
    return InFormState(
      status: status ?? this.status,
      teamId: teamId ?? this.teamId,
      period: period ?? this.period,
      position: clearPosition ? null : position ?? this.position,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage,
      seasons: seasons ?? this.seasons,
      selectedSeasonId:
          selectedSeasonId != null ? selectedSeasonId() : this.selectedSeasonId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        teamId,
        period,
        position,
        leaderboard,
        errorMessage,
        seasons,
        selectedSeasonId,
      ];
}
