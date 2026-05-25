import 'package:kopa/model/match_details.dart';

enum MatchProgrammeStatus { initial, loading, loaded, creating, failure }

class MatchProgrammeState {
  final MatchProgrammeStatus status;
  final List<MatchDetails> matches;
  final String? errorMessage;

  const MatchProgrammeState({
    this.status = MatchProgrammeStatus.initial,
    this.matches = const [],
    this.errorMessage,
  });

  bool get isLoading =>
      status == MatchProgrammeStatus.initial ||
      status == MatchProgrammeStatus.loading;

  bool get isCreating => status == MatchProgrammeStatus.creating;

  MatchProgrammeState copyWith({
    MatchProgrammeStatus? status,
    List<MatchDetails>? matches,
    String? errorMessage,
  }) {
    return MatchProgrammeState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage,
    );
  }
}
