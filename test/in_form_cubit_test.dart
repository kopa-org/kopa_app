import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/in_form_cubit.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';

void main() {
  group('InFormCubit', () {
    test('loads the current season leaderboard by default', () async {
      final cubit = InFormCubit(
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
        }) async {
          expect(teamId, 12);
          expect(period, InFormPeriod.currentSeason);
          expect(position, isNull);
          return _leaderboard(period, position);
        },
      );

      await cubit.load(12);

      expect(cubit.state.status, InFormStatus.loaded);
      expect(cubit.state.leaderboard?.rows.single.userName, 'Anders');
    });

    test('changing period and position reloads with selected filters',
        () async {
      final requests = <String>[];
      final cubit = InFormCubit(
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
        }) async {
          requests.add('${period.wire}:${position ?? 'all'}');
          return _leaderboard(period, position);
        },
      );

      await cubit.load(12);
      await cubit.selectPeriod(InFormPeriod.currentSeason);
      await cubit.selectPosition('striker');

      expect(requests, [
        'current_season:all',
        'current_season:striker',
      ]);
      expect(cubit.state.position, 'striker');
    });

    test('emits empty when no players have points', () async {
      final cubit = InFormCubit(
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
        }) async =>
            InFormLeaderboard(
          period: period.wire,
          position: position,
          rows: const [],
        ),
      );

      await cubit.load(12);
      expect(cubit.state.status, InFormStatus.empty);
    });
  });
}

InFormLeaderboard _leaderboard(
  InFormPeriod period,
  String? position,
) {
  return InFormLeaderboard(
    period: period.wire,
    position: position,
    rows: const [
      InFormLeaderboardRow(
        rank: 1,
        userId: 1,
        userName: 'Anders',
        position: 'striker',
        rankChange: 1,
        latestRound: 12,
        pointsToFirst: 0,
        total: 42,
      ),
    ],
  );
}
