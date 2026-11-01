import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/navigation/notification_destination.dart';

void main() {
  test('season notifications open import settings or the shared programme', () {
    expect(
      notificationDestination(
        {'type': 'new_season_available', 'team_id': '42'},
        currentTeamId: 42,
      ),
      AppRouter.profileSettings,
    );
    expect(
      notificationDestination(
        {'type': 'new_season_ready', 'team_id': '42'},
        currentTeamId: 42,
      ),
      AppRouter.match,
    );
  });

  test('stale or invalid team notifications cannot open another team action',
      () {
    for (final teamId in ['41', '', 'invalid', null]) {
      expect(
        notificationDestination(
          {'type': 'new_season_available', 'team_id': teamId},
          currentTeamId: 42,
        ),
        isNull,
      );
    }
  });

  test('existing match and join request destinations are preserved', () {
    expect(
      notificationDestination(
        {'type': 'match_calendar_changed', 'event_id': '123'},
        currentTeamId: 42,
      ),
      AppRouter.matchDetailsPath(123),
    );
    expect(
      notificationDestination({'type': 'team_join_request'}, currentTeamId: 42),
      AppRouter.teamJoinRequests,
    );
  });
}
