import 'package:kopa/navigation/app_router.dart';

/// Resolves push taps, keeping season actions scoped to the current team.
String? notificationDestination(
  Map<String, dynamic> data, {
  required int? currentTeamId,
}) {
  switch (data['type']) {
    case 'new_season_available':
    case 'new_season_ready':
      final teamId = int.tryParse((data['team_id'] ?? '').toString());
      if (teamId == null || teamId != currentTeamId) return null;
      return data['type'] == 'new_season_available'
          ? AppRouter.profileSettings
          : AppRouter.match;
    case 'team_join_request':
      return AppRouter.teamJoinRequests;
    case 'match_calendar_changed':
    case 'match_lineup_revealed':
    case 'waitlist_promoted':
      final matchId = int.tryParse(
        (data['match_id'] ?? data['event_id'] ?? '').toString(),
      );
      return matchId == null ? null : AppRouter.matchDetailsPath(matchId);
    default:
      return null;
  }
}
