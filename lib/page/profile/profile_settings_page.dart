import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/profile/dbu_calendar_import_flow.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/page/profile/team_logo_design_page.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:share_plus/share_plus.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _isLoading = false;
  bool _isSharingKopa = false;
  bool _isSavingMeetingOffset = false;
  bool _isSavingRsvpSelectionMode = false;
  int? _selectedMeetingOffsetMinutes;
  String _selectedRsvpSelectionMode = TeamDetails.firstComeFirstServed;
  DbuWebviewOperation? _activeDbuSync;
  String? _errorMessage;

  static const List<int?> _meetingOffsetOptions = [
    null,
    15,
    30,
    45,
    60,
    90,
    120,
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().state.user;
    _selectedMeetingOffsetMinutes =
        currentUser?.teamDetails?.defaultMeetingOffsetMinutes;
    _selectedRsvpSelectionMode = currentUser?.teamDetails?.rsvpSelectionMode ??
        TeamDetails.firstComeFirstServed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final currentUser = context.read<AuthCubit>().state.user;
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: 'Settings',
      showBackButton: true,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: appTextStyles.body.copyWith(color: appColors.error),
                ),
              ),
            FullWidthButton(
              outlined: true,
              buttonText: 'Importér kampprogram',
              loading: _isLoading,
              onPressed: _isLoading ? () {} : _importCalendar,
            ),
            const SizedBox(height: 16),
            FullWidthButton(
              buttonText: _isSharingKopa ? 'Henter link...' : 'Del Kopa',
              outlined: true,
              loading: _isSharingKopa,
              onPressed: _isSharingKopa ? () {} : _shareKopa,
            ),
            const SizedBox(height: 24),
            Text('Holdværktøjer', style: appTextStyles.sectionHeader),
            const SizedBox(height: 12),
            if (currentUser?.isTeamOwner == true) ...[
              FullWidthButton(
                buttonText: l10n.teamLogoEditButton,
                outlined: true,
                icon: Icons.palette_outlined,
                onPressed: _openTeamLogoEditor,
              ),
              const SizedBox(height: 16),
              FullWidthButton(
                buttonText: 'Godkend nye spillere',
                outlined: true,
                onPressed: () => context.push(AppRouter.teamJoinRequests),
              ),
              const SizedBox(height: 16),
              FullWidthButton(
                buttonText: _activeDbuSync == DbuWebviewOperation.standings
                    ? 'Synkroniserer stilling...'
                    : 'Synkroniser stilling fra DBU',
                outlined: true,
                loading: _activeDbuSync != null,
                onPressed: _activeDbuSync == null ? _syncDbu : () {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _meetingOffsetOptions
                        .contains(_selectedMeetingOffsetMinutes)
                    ? _selectedMeetingOffsetMinutes
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Standard mødetid',
                  border: OutlineInputBorder(),
                ),
                items: _meetingOffsetOptions
                    .map(
                      (minutes) => DropdownMenuItem<int?>(
                        value: minutes,
                        child: Text(_meetingOffsetLabel(minutes)),
                      ),
                    )
                    .toList(),
                onChanged: _isSavingMeetingOffset
                    ? null
                    : (value) {
                        setState(() => _selectedMeetingOffsetMinutes = value);
                      },
              ),
              const SizedBox(height: 8),
              FullWidthButton(
                buttonText: _isSavingMeetingOffset
                    ? 'Gemmer mødetid...'
                    : 'Gem mødetid',
                loading: _isSavingMeetingOffset,
                onPressed: _isSavingMeetingOffset ? () {} : _saveMeetingOffset,
              ),
            ],
            if (currentUser?.canManageTeam == true) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: {
                  TeamDetails.firstComeFirstServed,
                  TeamDetails.teamLeaderSelection,
                }.contains(_selectedRsvpSelectionMode)
                    ? _selectedRsvpSelectionMode
                    : TeamDetails.firstComeFirstServed,
                decoration: InputDecoration(
                  labelText: l10n.teamRsvpSelectionModeLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: TeamDetails.firstComeFirstServed,
                    child: Text(l10n.teamRsvpFirstComeOption),
                  ),
                  DropdownMenuItem<String>(
                    value: TeamDetails.teamLeaderSelection,
                    child: Text(l10n.teamRsvpLeaderOption),
                  ),
                ],
                onChanged: _isSavingRsvpSelectionMode
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _selectedRsvpSelectionMode = value);
                      },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.teamRsvpSelectionModeDescription,
                style: appTextStyles.caption,
              ),
              const SizedBox(height: 8),
              FullWidthButton(
                buttonText: _isSavingRsvpSelectionMode
                    ? l10n.teamRsvpSelectionSaving
                    : l10n.teamRsvpSelectionSave,
                loading: _isSavingRsvpSelectionMode,
                onPressed:
                    _isSavingRsvpSelectionMode ? () {} : _saveRsvpSelectionMode,
              ),
            ],
            BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                if (state.status == OnboardingStatus.loading) {
                  return const LoadingIndicator();
                }

                if (state.errorMessage != null) {
                  return Text(
                    state.errorMessage!,
                    style:
                        appTextStyles.caption.copyWith(color: appColors.error),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            FullWidthButton(
              buttonText: _isLoading ? 'Logger ud...' : 'Log ud',
              outlined: true,
              loading: _isLoading,
              onPressed: _isLoading
                  ? () {}
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      try {
                        await context.read<AuthCubit>().logout();
                      } catch (error) {
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Kunne ikke logge ud.';
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importCalendar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = context.read<AuthCubit>().state.user;
      final message = await DbuCalendarImportFlow.run(
        context,
        teamId: currentUser?.teamDetails?.id,
      );

      if (!mounted) return;
      if (message != null) {
        context.read<MatchProgrammeRefreshNotifier>().notifyMatchesChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _shareKopa() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final team = currentUser?.teamDetails;
    if (team == null) {
      setState(
          () => _errorMessage = 'Du skal være på et hold for at dele Kopa.');
      return;
    }

    setState(() {
      _isSharingKopa = true;
      _errorMessage = null;
    });

    try {
      final token =
          await context.read<OnboardingCubit>().fetchTeamJoinToken(team.id);
      if (!mounted) return;

      if (token == null) {
        setState(() {
          _isSharingKopa = false;
          _errorMessage = 'Kunne ikke hente invitationslink.';
        });
        return;
      }

      final inviteUri = Uri.https(
        'kopa.dk',
        '/join',
        {
          'team_token': token,
          'team_id': team.id.toString(),
          'team_title': team.title,
        },
      );

      await SharePlus.instance.share(
        ShareParams(
          text: 'Join ${team.title} på Kopa: $inviteUri',
        ),
      );
      if (!mounted) return;
      setState(() => _isSharingKopa = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSharingKopa = false;
        _errorMessage = 'Kunne ikke dele Kopa.';
      });
    }
  }

  Future<void> _saveMeetingOffset() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final teamId = currentUser?.teamDetails?.id;

    if (currentUser?.isTeamOwner != true || teamId == null) {
      setState(() => _errorMessage = 'Kun holdlederen kan ændre mødetid.');
      return;
    }

    setState(() {
      _isSavingMeetingOffset = true;
      _errorMessage = null;
    });

    try {
      await UsersRepository.updateTeamSettings(
        teamId: teamId,
        defaultMeetingOffsetMinutes: _selectedMeetingOffsetMinutes,
      );
      if (!mounted) return;

      await context.read<AuthCubit>().init();
      if (!mounted) return;

      final label = _meetingOffsetLabel(_selectedMeetingOffsetMinutes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Standard mødetid er sat til $label.')),
      );
      setState(() => _isSavingMeetingOffset = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSavingMeetingOffset = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _saveRsvpSelectionMode() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final team = currentUser?.teamDetails;

    if (currentUser?.canManageTeam != true || team == null) {
      setState(
        () =>
            _errorMessage = AppLocalizations.of(context)!.teamSettingsOwnerOnly,
      );
      return;
    }

    setState(() {
      _isSavingRsvpSelectionMode = true;
      _errorMessage = null;
    });

    try {
      await UsersRepository.updateTeamSettings(
        teamId: team.id,
        defaultMeetingOffsetMinutes: team.defaultMeetingOffsetMinutes,
        rsvpSelectionMode: _selectedRsvpSelectionMode,
      );
      if (!mounted) return;

      await context.read<AuthCubit>().init();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.teamRsvpSelectionSaved,
          ),
        ),
      );
      setState(() => _isSavingRsvpSelectionMode = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSavingRsvpSelectionMode = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openTeamLogoEditor() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final team = currentUser?.teamDetails;
    if (currentUser?.isTeamOwner != true || team == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeamLogoDesignPage(
          teamId: team.id,
          teamName: team.title,
          initialDesign: team.logoDesign,
        ),
      ),
    );
  }

  static String _meetingOffsetLabel(int? minutes) {
    if (minutes == null || minutes == 0) {
      return 'Ingen standard';
    }

    return '$minutes min før kampstart';
  }

  Future<void> _syncDbu() async {
    const operation = DbuWebviewOperation.standings;
    final currentUser = context.read<AuthCubit>().state.user;
    final teamId = currentUser?.teamDetails?.id;
    if (currentUser?.isTeamOwner != true || teamId == null) {
      return;
    }

    setState(() {
      _activeDbuSync = operation;
      _errorMessage = null;
    });

    try {
      AppAnalytics.logEvent(
        'dbu_pool_sync_started',
        parameters: {'operation': operation.wireValue},
      );
      final result = await context.push<String>(
        AppRouter.dbuWebview,
        extra: operation,
      );
      if (!mounted) return;

      if (result == null) {
        setState(() => _activeDbuSync = null);
        return;
      }

      final scrapedData = jsonDecode(result) as Map<String, dynamic>;
      final scraperError = scrapedData['error']?.toString();
      if (scraperError != null && scraperError.isNotEmpty) {
        throw Exception(scraperError);
      }

      await TeamDbuRepository.syncStandings(
        teamId: teamId,
        scrapedData: scrapedData,
      );

      if (!mounted) return;
      final count = (scrapedData['standings'] as List<dynamic>? ?? []).length;
      final label = 'Stilling og puljehold er synkroniseret ($count hold).';

      AppAnalytics.logEvent(
        'dbu_pool_sync_completed',
        parameters: {
          'operation': operation.wireValue,
          'row_count': count,
        },
      );
      setState(() => _activeDbuSync = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label)),
      );
    } catch (error) {
      AppAnalytics.logEvent(
        'dbu_pool_sync_failed',
        parameters: {'operation': operation.wireValue},
      );
      if (!mounted) return;
      setState(() {
        _activeDbuSync = null;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }
}
