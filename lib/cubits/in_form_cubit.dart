import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/repository/in_form_repository.dart';

typedef InFormLeaderboardLoader = Future<InFormLeaderboard> Function({
  required int teamId,
  required InFormPeriod period,
  String? position,
});

class InFormCubit extends Cubit<InFormState> {
  InFormCubit({InFormLeaderboardLoader? loader})
      : _loader = loader ?? InFormRepository.getLeaderboard,
        super(const InFormState());

  final InFormLeaderboardLoader _loader;

  Future<void> load(int teamId) async {
    emit(state.copyWith(
      status: InFormStatus.loading,
      teamId: teamId,
      errorMessage: null,
    ));

    try {
      final leaderboard = await _loader(
        teamId: teamId,
        period: state.period,
        position: state.position,
      );
      emit(state.copyWith(
        status:
            leaderboard.rows.isEmpty ? InFormStatus.empty : InFormStatus.loaded,
        leaderboard: leaderboard,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: InFormStatus.failure,
        errorMessage: 'Kunne ikke hente In-form.',
      ));
    }
  }

  Future<void> selectPeriod(InFormPeriod period) async {
    if (period == state.period || state.teamId == null) return;
    emit(state.copyWith(period: period));
    await load(state.teamId!);
  }

  Future<void> selectPosition(String? position) async {
    if (position == state.position || state.teamId == null) return;
    emit(state.copyWith(
      position: position,
      clearPosition: position == null,
    ));
    await load(state.teamId!);
  }
}
