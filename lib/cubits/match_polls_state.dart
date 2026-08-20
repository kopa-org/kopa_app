import 'package:equatable/equatable.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';

enum MatchPollsStatus { initial, loading, loaded, submitting, failure }

const Object _unset = Object();

class MatchPollRow extends Equatable {
  final MatchPollDetails matchPoll;
  final UserDetails user;

  const MatchPollRow({
    required this.matchPoll,
    required this.user,
  });

  @override
  List<Object?> get props => [matchPoll, user];
}

class MatchPollsState extends Equatable {
  final MatchPollsStatus status;
  final List<UserDetails> squad;
  final List<MatchDetails> matches;
  final List<MatchPollDetails> matchPolls;
  final List<MatchPollRow> rows;
  final String? errorMessage;
  final String? formErrorMessage;

  const MatchPollsState({
    this.status = MatchPollsStatus.initial,
    this.squad = const [],
    this.matches = const [],
    this.matchPolls = const [],
    this.rows = const [],
    this.errorMessage,
    this.formErrorMessage,
  });

  bool get isLoading =>
      status == MatchPollsStatus.initial || status == MatchPollsStatus.loading;

  bool get isSubmitting => status == MatchPollsStatus.submitting;

  MatchPollsState copyWith({
    MatchPollsStatus? status,
    List<UserDetails>? squad,
    List<MatchDetails>? matches,
    List<MatchPollDetails>? matchPolls,
    List<MatchPollRow>? rows,
    Object? errorMessage = _unset,
    Object? formErrorMessage = _unset,
  }) {
    return MatchPollsState(
      status: status ?? this.status,
      squad: squad ?? this.squad,
      matches: matches ?? this.matches,
      matchPolls: matchPolls ?? this.matchPolls,
      rows: rows ?? this.rows,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      formErrorMessage: formErrorMessage == _unset
          ? this.formErrorMessage
          : formErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        squad,
        matches,
        matchPolls,
        rows,
        errorMessage,
        formErrorMessage,
      ];
}
