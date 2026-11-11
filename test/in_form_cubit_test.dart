import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/in_form_cubit.dart';
import 'package:kopa/cubits/in_form_state.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/model/season_details.dart';

void main() {
  group('InFormCubit', () {
    test('loads the rolling three-month leaderboard by default', () async {
      final cubit = InFormCubit(
        seasonsLoader: (_) async => const [],
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
          int? seasonId,
        }) async {
          expect(teamId, 12);
          expect(period, InFormPeriod.rollingThreeMonths);
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
        seasonsLoader: (_) async => const [],
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
          int? seasonId,
        }) async {
          requests.add('${period.wire}:${position ?? 'all'}');
          return _leaderboard(period, position);
        },
      );

      await cubit.load(12);
      await cubit.selectPeriod(InFormPeriod.currentSeason);
      await cubit.selectPosition('striker');

      expect(requests, [
        'rolling_3_months:all',
        'current_season:all',
        'current_season:striker',
      ]);
      expect(cubit.state.position, 'striker');
    });

    test('a past season can be picked under the season period', () async {
      final requests = <String>[];
      final active = SeasonDetails(
        id: 2,
        teamId: 12,
        name: 'Efterår 2026',
        startsOn: DateTime(2026, 8, 1),
        endsOn: null,
        isActive: true,
      );
      final past = SeasonDetails(
        id: 1,
        teamId: 12,
        name: 'Forår 2026',
        startsOn: DateTime(2026, 2, 1),
        endsOn: DateTime(2026, 7, 31),
        isActive: false,
      );
      final cubit = InFormCubit(
        seasonsLoader: (_) async => [active, past],
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
          int? seasonId,
        }) async {
          requests.add('${period.wire}:${seasonId ?? 'active'}');
          return _leaderboard(period, position);
        },
      );

      await cubit.load(12);
      await cubit.selectPeriod(InFormPeriod.currentSeason);
      expect(cubit.state.selectedSeason, active);
      expect(cubit.state.isViewingPastSeason, isFalse);

      await cubit.selectSeason(past);
      expect(cubit.state.isViewingPastSeason, isTrue);

      // The rolling period ignores the picked season.
      await cubit.selectPeriod(InFormPeriod.rollingThreeMonths);
      expect(cubit.state.isViewingPastSeason, isFalse);

      await cubit.selectPeriod(InFormPeriod.currentSeason);
      await cubit.showActiveSeason();

      expect(requests, [
        'rolling_3_months:active',
        'current_season:active',
        'current_season:1',
        'rolling_3_months:active',
        'current_season:1',
        'current_season:active',
      ]);
    });

    test('emits empty when no players have points', () async {
      final cubit = InFormCubit(
        seasonsLoader: (_) async => const [],
        loader: ({
          required int teamId,
          required InFormPeriod period,
          String? position,
          int? seasonId,
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
