import 'package:kopa/model/in_form.dart';

enum InFormStatus { initial, loading, loaded, empty, failure }

class InFormState {
  final InFormStatus status;
  final int? teamId;
  final InFormPeriod period;
  final String? position;
  final InFormLeaderboard? leaderboard;
  final String? errorMessage;

  const InFormState({
    this.status = InFormStatus.initial,
    this.teamId,
    this.period = InFormPeriod.rollingThreeMonths,
    this.position,
    this.leaderboard,
    this.errorMessage,
  });

  InFormState copyWith({
    InFormStatus? status,
    int? teamId,
    InFormPeriod? period,
    String? position,
    bool clearPosition = false,
    InFormLeaderboard? leaderboard,
    String? errorMessage,
  }) {
    return InFormState(
      status: status ?? this.status,
      teamId: teamId ?? this.teamId,
      period: period ?? this.period,
      position: clearPosition ? null : position ?? this.position,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage,
    );
  }
}
