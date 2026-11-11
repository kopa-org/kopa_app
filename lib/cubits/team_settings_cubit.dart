import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/repository/users_repository.dart';

typedef SaveTeamSettings = Future<TeamDetails> Function({
  required int teamId,
  required int? defaultMeetingOffsetMinutes,
  required int? maxSignups,
  String? rsvpSelectionMode,
});

typedef CountJoinRequests = Future<int> Function(int teamId);

enum TeamSettingsSaveStatus { idle, saving, saved, failed }

class TeamSettingsState {
  final int? meetingOffsetMinutes;
  final String rsvpSelectionMode;

  /// Signup limit in first-come-first-served mode; null means no limit.
  final int? maxSignups;
  final TeamSettingsSaveStatus saveStatus;

  /// Pending join requests, or null when unknown or not visible to the user.
  final int? pendingJoinRequests;

  const TeamSettingsState({
    this.meetingOffsetMinutes,
    this.rsvpSelectionMode = TeamDetails.firstComeFirstServed,
    this.maxSignups,
    this.saveStatus = TeamSettingsSaveStatus.idle,
    this.pendingJoinRequests,
  });

  bool sameSettingsAs(TeamSettingsState other) =>
      meetingOffsetMinutes == other.meetingOffsetMinutes &&
      rsvpSelectionMode == other.rsvpSelectionMode &&
      maxSignups == other.maxSignups;

  TeamSettingsState copyWith({
    int? Function()? meetingOffsetMinutes,
    String? rsvpSelectionMode,
    int? Function()? maxSignups,
    TeamSettingsSaveStatus? saveStatus,
    int? Function()? pendingJoinRequests,
  }) {
    return TeamSettingsState(
      meetingOffsetMinutes: meetingOffsetMinutes != null
          ? meetingOffsetMinutes()
          : this.meetingOffsetMinutes,
      rsvpSelectionMode: rsvpSelectionMode ?? this.rsvpSelectionMode,
      maxSignups: maxSignups != null ? maxSignups() : this.maxSignups,
      saveStatus: saveStatus ?? this.saveStatus,
      pendingJoinRequests: pendingJoinRequests != null
          ? pendingJoinRequests()
          : this.pendingJoinRequests,
    );
  }
}

/// Owns the team-level settings shown in the profile settings hub and its
/// sub-pages. Changes are saved immediately (optimistically) instead of
/// requiring a separate save button. Rapid stepper changes to the signup
/// limit are debounced into one save, and saves are sent one at a time.
class TeamSettingsCubit extends Cubit<TeamSettingsState> {
  static const List<int?> meetingOffsetOptions = [
    null,
    15,
    30,
    45,
    60,
    90,
    120,
  ];

  /// Bounds match the backend's `teams_max_signups_range` constraint.
  static const int minSignupLimit = 1;
  static const int maxSignupLimit = 50;
  static const int defaultSignupLimit = 14;

  final int? teamId;
  final SaveTeamSettings _saveSettings;
  final CountJoinRequests _countJoinRequests;
  final Duration saveDebounce;

  /// Called with the saved team so the signed-in user can be refreshed.
  final Future<void> Function(TeamDetails team)? onTeamSaved;

  /// Last settings the server accepted; failed saves roll back to this.
  TeamSettingsState _confirmed;
  Timer? _debounce;
  Future<void> _saveChain = Future.value();

  TeamSettingsCubit({
    required this.teamId,
    TeamDetails? team,
    SaveTeamSettings? saveSettings,
    CountJoinRequests? countJoinRequests,
    this.onTeamSaved,
    this.saveDebounce = const Duration(milliseconds: 600),
  })  : _saveSettings = saveSettings ?? UsersRepository.updateTeamSettings,
        _countJoinRequests = countJoinRequests ?? _defaultCountJoinRequests,
        _confirmed = _initialState(team),
        super(_initialState(team));

  static TeamSettingsState _initialState(TeamDetails? team) =>
      TeamSettingsState(
        meetingOffsetMinutes: team?.defaultMeetingOffsetMinutes,
        rsvpSelectionMode:
            team?.rsvpSelectionMode ?? TeamDetails.firstComeFirstServed,
        maxSignups: team?.maxSignups,
      );

  static Future<int> _defaultCountJoinRequests(int teamId) async {
    final result = await OnboardingRepository().listJoinRequests(teamId);
    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Could not load join requests.');
    }
    return (result['join_requests'] as List<dynamic>? ?? []).length;
  }

  Future<void> loadPendingJoinRequests() async {
    final id = teamId;
    if (id == null) return;
    try {
      final count = await _countJoinRequests(id);
      if (!isClosed) emit(state.copyWith(pendingJoinRequests: () => count));
    } catch (_) {
      // The badge is a hint only; leave it hidden when the count fails.
      if (!isClosed) emit(state.copyWith(pendingJoinRequests: () => null));
    }
  }

  Future<void> setMeetingOffset(int? minutes) {
    if (minutes == state.meetingOffsetMinutes) return Future.value();
    emit(state.copyWith(
      meetingOffsetMinutes: () => minutes,
      saveStatus: TeamSettingsSaveStatus.saving,
    ));
    return _persist();
  }

  Future<void> setRsvpSelectionMode(String mode) {
    if (mode == state.rsvpSelectionMode) return Future.value();
    emit(state.copyWith(
      rsvpSelectionMode: mode,
      saveStatus: TeamSettingsSaveStatus.saving,
    ));
    return _persist();
  }

  /// Sets the signup limit (null = no limit). Saved after a short pause so
  /// tapping the stepper several times sends one request.
  void setMaxSignups(int? max) {
    final value = max?.clamp(minSignupLimit, maxSignupLimit);
    if (value == state.maxSignups) return;
    emit(state.copyWith(
      maxSignups: () => value,
      saveStatus: TeamSettingsSaveStatus.saving,
    ));
    _debounce?.cancel();
    _debounce = Timer(saveDebounce, _persist);
  }

  Future<void> _persist() {
    _debounce?.cancel();
    _debounce = null;
    final next = state;
    _saveChain = _saveChain.then((_) => _send(next));
    return _saveChain;
  }

  Future<void> _send(TeamSettingsState next) async {
    final id = teamId;
    if (id == null) return;
    try {
      final team = await _saveSettings(
        teamId: id,
        defaultMeetingOffsetMinutes: next.meetingOffsetMinutes,
        maxSignups: next.maxSignups,
        rsvpSelectionMode: next.rsvpSelectionMode,
      );
      _confirmed = next;
      if (isClosed) return;
      // Only report "saved" when no newer change is still waiting.
      if (_debounce == null && state.sameSettingsAs(next)) {
        emit(state.copyWith(saveStatus: TeamSettingsSaveStatus.saved));
      }
      await onTeamSaved?.call(team);
    } catch (_) {
      if (isClosed) return;
      _debounce?.cancel();
      _debounce = null;
      // Roll back so the UI never shows a value the server did not accept.
      emit(_confirmed.copyWith(
        saveStatus: TeamSettingsSaveStatus.failed,
        pendingJoinRequests: () => state.pendingJoinRequests,
      ));
    }
  }

  @override
  Future<void> close() {
    // Leaving the screen mid-debounce must not drop the change.
    if (_debounce?.isActive == true) _persist();
    return super.close();
  }
}
