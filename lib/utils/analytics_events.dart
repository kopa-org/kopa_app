/// Every product analytics event the app is allowed to send.
///
/// This is the app's tracking plan in code. [AppAnalytics.logEvent] asserts
/// in debug builds that an event is listed here, so a typo or an undocumented
/// event fails fast instead of silently creating a new event in PostHog.
///
/// Naming: `object_action` in snake_case, past tense for completed actions
/// (`fine_assigned`), `_opened` / `_started` for intent. Keep property values
/// low-cardinality and never put names, emails or free text in properties.
///
/// Server-side events (sent by the Elixir backend, team-level only) are listed
/// in [serverEvents] for reference; the app must not send them.
abstract final class AnalyticsEvents {
  /// Account and session.
  static const auth = {
    'login_success',
    'login_failure',
    'register_success',
    'register_failure',
  };

  /// Onboarding and team growth: the activation funnel.
  static const onboarding = {
    'onboarding_started',
    'team_created',
    'team_join_requested',
    'team_joined',
    'team_join_request_resolved',
    'team_invite_shared',
    'team_invite_copied',
  };

  /// Matches, trainings and RSVP: the core weekly loop.
  static const matches = {
    'match_created',
    'training_created',
    'match_opened',
    'match_registered',
    'match_unregistered',
    'match_declined',
    'training_registered',
    'training_unregistered',
    'match_attendance_selection_updated',
    'match_attendance_selection_all_approved',
    'match_lineup_updated',
    'match_lineup_visibility_updated',
    'match_external_player_added',
    'match_details_segment_selected',
    'match_details_motm_created',
    'match_details_motm_updated',
    'match_event_added',
    'match_result_entry_opened',
    'match_score_updated',
    'match_programme_season_selected',
    'match_poll_created',
    'match_poll_updated',
  };

  /// Fine box.
  static const fines = {
    'fine_box_opened',
    'fine_box_segment_selected',
    'fine_assign_started',
    'fine_assigned',
    'fine_deleted',
    'fine_marked_paid_by_admin',
    'fine_mobile_pay_answered',
    'fine_deposit_started',
    'fine_deposit_completed',
    'fine_withdraw_started',
    'fine_withdraw_completed',
    'fine_type_created',
    'fine_type_deleted',
  };

  /// DBU calendar import and seasons.
  static const seasons = {
    'dbu_webview_opened',
    'dbu_calendar_import_success',
    'dbu_calendar_import_failure',
    'dbu_pool_scrape_success',
    'dbu_pool_sync_started',
    'dbu_pool_sync_completed',
    'dbu_pool_sync_failed',
    'dbu_next_season_used',
    'season_over_import',
    'season_over_check_again',
    'season_end_result_entry_opened',
    'season_wrapped_opened',
    'season_wrapped_closed',
    'season_wrapped_shared',
    'season_wrapped_skipped',
    'season_wrapped_settings_saved',
  };

  /// Navigation and secondary features.
  static const navigation = {
    'main_tab_selected',
    'profile_settings_opened',
    'statistics_opened',
    'statistics_season_selected',
    'player_plus_opened',
  };

  static const all = {
    ...auth,
    ...onboarding,
    ...matches,
    ...fines,
    ...seasons,
    ...navigation,
  };

  /// Sent by the backend (`Kopa.Analytics`), never by the app.
  static const serverEvents = {
    'calendar_sync_completed',
    'calendar_sync_failed',
    'push_notification_sent',
  };
}
