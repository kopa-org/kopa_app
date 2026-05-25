import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/player_plus_cubit.dart';
import 'package:kopa/cubits/player_plus_state.dart';
import 'package:kopa/model/player_plus.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';

void main() {
  group('PlayerPlusCubit', () {
    test('emits noTeam when user has no team', () async {
      final cubit = PlayerPlusCubit();
      final user = _buildUserWithoutTeam();

      await cubit.load(user);

      expect(cubit.state.status, PlayerPlusStatus.noTeam);
      expect(cubit.state.teamId, isNull);
    });

    test('loads overview and default leaderboard', () async {
      final cubit = PlayerPlusCubit(
        overviewLoader: (_) async => _buildOverview(
          categories: const ['goals', 'overall'],
          scopes: const ['global', 'team'],
        ),
        leaderboardLoader: ({
          required int teamId,
          required String scope,
          required String category,
        }) async {
          expect(teamId, 12);
          expect(scope, 'team');
          expect(category, 'overall');

          return _buildLeaderboard(
            scope: scope,
            category: category,
            rows: [
              PlayerPlusLeaderboardRow(
                rank: 1,
                userId: 99,
                userName: 'Jonas',
                teamId: 12,
                teamTitle: 'Kopa FC',
                value: 9,
              ),
            ],
          );
        },
      );

      await cubit.load(_buildUser());

      expect(cubit.state.status, PlayerPlusStatus.loaded);
      expect(cubit.state.selectedCategory, 'overall');
      expect(cubit.state.selectedScope, 'team');
      expect(cubit.state.leaderboard?.rows, hasLength(1));
    });

    test('changing scope reloads leaderboard and preserves category', () async {
      final requestedScopes = <String>[];

      final cubit = PlayerPlusCubit(
        overviewLoader: (_) async => _buildOverview(),
        leaderboardLoader: ({
          required int teamId,
          required String scope,
          required String category,
        }) async {
          requestedScopes.add(scope);
          return _buildLeaderboard(
            scope: scope,
            category: category,
            rows: scope == 'global'
                ? []
                : [
                    PlayerPlusLeaderboardRow(
                      rank: 1,
                      userId: 99,
                      userName: 'Jonas',
                      teamId: 12,
                      teamTitle: 'Kopa FC',
                      value: 4,
                    ),
                  ],
          );
        },
      );

      await cubit.load(_buildUser());
      await cubit.selectScope('global');

      expect(requestedScopes, ['team', 'global']);
      expect(cubit.state.selectedCategory, 'overall');
      expect(cubit.state.selectedScope, 'global');
      expect(cubit.state.status, PlayerPlusStatus.empty);
    });
  });
}

UserDetails _buildUser({TeamDetails? teamDetails}) {
  final now = DateTime(2026, 1, 1);

  return UserDetails(
    id: 42,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: teamDetails ??
        TeamDetails(
          id: 12,
          title: 'Kopa FC',
          createdAt: now,
          updatedAt: now,
        ),
  );
}

UserDetails _buildUserWithoutTeam() {
  final now = DateTime(2026, 1, 1);

  return UserDetails(
    id: 42,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}

PlayerPlusOverview _buildOverview({
  List<String> categories = const ['overall', 'goals'],
  List<String> scopes = const ['team', 'global'],
}) {
  return PlayerPlusOverview(
    entitlement: PlayerPlusEntitlement(
      active: true,
      status: 'active',
      source: 'rollout',
      provider: 'disabled',
    ),
    locked: false,
    categories: categories,
    scopes: scopes,
    dbuContext: PlayerPlusTeamContext(),
  );
}

PlayerPlusLeaderboard _buildLeaderboard({
  required String scope,
  required String category,
  required List<PlayerPlusLeaderboardRow> rows,
}) {
  return PlayerPlusLeaderboard(
    entitlement: PlayerPlusEntitlement(
      active: true,
      status: 'active',
      source: 'rollout',
      provider: 'disabled',
    ),
    locked: false,
    scope: scope,
    category: category,
    rows: rows,
  );
}
