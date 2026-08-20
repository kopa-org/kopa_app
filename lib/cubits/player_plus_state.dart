import 'package:equatable/equatable.dart';
import 'package:kopa/model/player_plus.dart';

enum PlayerPlusStatus { initial, loading, loaded, empty, error, noTeam }

class PlayerPlusState extends Equatable {
  final PlayerPlusStatus status;
  final int? teamId;
  final int? currentUserId;
  final String? teamTitle;
  final PlayerPlusOverview? overview;
  final PlayerPlusLeaderboard? leaderboard;
  final String? selectedCategory;
  final String? selectedScope;
  final String? errorMessage;

  const PlayerPlusState({
    this.status = PlayerPlusStatus.initial,
    this.teamId,
    this.currentUserId,
    this.teamTitle,
    this.overview,
    this.leaderboard,
    this.selectedCategory,
    this.selectedScope,
    this.errorMessage,
  });

  PlayerPlusState copyWith({
    PlayerPlusStatus? status,
    int? teamId,
    int? currentUserId,
    String? teamTitle,
    PlayerPlusOverview? overview,
    PlayerPlusLeaderboard? leaderboard,
    String? selectedCategory,
    String? selectedScope,
    String? errorMessage,
  }) {
    return PlayerPlusState(
      status: status ?? this.status,
      teamId: teamId ?? this.teamId,
      currentUserId: currentUserId ?? this.currentUserId,
      teamTitle: teamTitle ?? this.teamTitle,
      overview: overview ?? this.overview,
      leaderboard: leaderboard ?? this.leaderboard,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedScope: selectedScope ?? this.selectedScope,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        teamId,
        currentUserId,
        teamTitle,
        overview,
        leaderboard,
        selectedCategory,
        selectedScope,
        errorMessage,
      ];
}
