import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/repository/in_form_repository.dart';

enum InFormPlayerStatus { loading, loaded, failure }

class InFormPlayerState extends Equatable {
  final InFormPlayerStatus status;
  final InFormPlayerBreakdown? breakdown;
  final Set<int> expandedEventIds;

  const InFormPlayerState({
    this.status = InFormPlayerStatus.loading,
    this.breakdown,
    this.expandedEventIds = const {},
  });

  InFormPlayerState copyWith({
    InFormPlayerStatus? status,
    InFormPlayerBreakdown? breakdown,
    Set<int>? expandedEventIds,
  }) {
    return InFormPlayerState(
      status: status ?? this.status,
      breakdown: breakdown ?? this.breakdown,
      expandedEventIds: expandedEventIds ?? this.expandedEventIds,
    );
  }

  @override
  List<Object?> get props => [status, breakdown, expandedEventIds];
}

typedef InFormPlayerLoader = Future<InFormPlayerBreakdown> Function({
  required int teamId,
  required int playerId,
  required InFormPeriod period,
  int? seasonId,
});

typedef InFormMatchUpdater = Future<void> Function({
  required int eventId,
  required int playerId,
  required Map<String, Object?> changes,
});

/// Owns the in-form detail for one player: the per-match breakdown, which
/// match cards are expanded, and saving per-match data (position overrides
/// and data points) followed by a reload of the recalculated scores.
class InFormPlayerCubit extends Cubit<InFormPlayerState> {
  final int teamId;
  final int playerId;
  final InFormPeriod period;

  /// A specific season for [InFormPeriod.currentSeason]; null = active.
  final int? seasonId;
  final InFormPlayerLoader _loader;
  final InFormMatchUpdater _updater;

  InFormPlayerCubit({
    required this.teamId,
    required this.playerId,
    required this.period,
    this.seasonId,
    InFormPlayerLoader? loader,
    InFormMatchUpdater? updater,
  })  : _loader = loader ?? InFormRepository.getPlayerBreakdown,
        _updater = updater ?? InFormRepository.updateMatchPerformance,
        super(const InFormPlayerState());

  Future<void> load() async {
    if (state.breakdown == null) {
      emit(state.copyWith(status: InFormPlayerStatus.loading));
    }
    try {
      final breakdown = await _loader(
        teamId: teamId,
        playerId: playerId,
        period: period,
        seasonId: seasonId,
      );
      if (isClosed) return;
      // Open the most recent match by default, like a match feed.
      final expanded = state.breakdown == null && breakdown.matches.isNotEmpty
          ? {breakdown.matches.first.eventId}
          : state.expandedEventIds;
      emit(state.copyWith(
        status: InFormPlayerStatus.loaded,
        breakdown: breakdown,
        expandedEventIds: expanded,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: InFormPlayerStatus.failure));
    }
  }

  void toggleMatch(int eventId) {
    final expanded = Set<int>.of(state.expandedEventIds);
    if (!expanded.remove(eventId)) expanded.add(eventId);
    emit(state.copyWith(expandedEventIds: expanded));
  }

  /// Saves per-match data and reloads. Returns false when the save failed.
  Future<bool> updateMatch(int eventId, Map<String, Object?> changes) async {
    try {
      await _updater(eventId: eventId, playerId: playerId, changes: changes);
    } catch (_) {
      return false;
    }
    await load();
    return true;
  }
}
