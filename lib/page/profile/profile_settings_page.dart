import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/settings/settings_list.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/cubits/team_settings_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/profile/edit_position_sheet.dart';
import 'package:kopa/page/profile/match_settings_page.dart';
import 'package:kopa/page/profile/season_settings_page.dart';
import 'package:kopa/page/profile/team_logo_design_page.dart';
import 'package:kopa/page/team/team_tasks_page.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:share_plus/share_plus.dart';

/// Profile & settings hub. Settings are grouped by category; each row shows
/// the current value and opens a focused sub-page.
class ProfileSettingsPage extends StatelessWidget {
  final TeamSettingsCubit Function(BuildContext context)? createSettingsCubit;
  final Future<UserDetails> Function(String position)? updatePosition;

  const ProfileSettingsPage({
    super.key,
    this.createSettingsCubit,
    this.updatePosition,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamSettingsCubit>(
      create: (context) {
        final user = context.read<AuthCubit>().state.user;
        final cubit = createSettingsCubit?.call(context) ??
            TeamSettingsCubit(
              teamId: user?.teamDetails?.id,
              team: user?.teamDetails,
              onTeamSaved: (_) => context.read<AuthCubit>().init(),
            );
        if (user?.isTeamOwner == true) cubit.loadPendingJoinRequests();
        return cubit;
      },
      child: _ProfileSettingsView(
        updatePosition: updatePosition ?? UsersRepository.updatePosition,
      ),
    );
  }
}

class _ProfileSettingsView extends StatefulWidget {
  final Future<UserDetails> Function(String position) updatePosition;

  const _ProfileSettingsView({required this.updatePosition});

  @override
  State<_ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<_ProfileSettingsView> {
  bool _isLoggingOut = false;
  bool _isSharing = false;
  bool _isSavingPosition = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthCubit>().state.user;
    final settings = context.watch<TeamSettingsCubit>().state;
    final isOwner = user?.isTeamOwner == true;
    final canManage = user?.canManageTeam == true;
    final pending = settings.pendingJoinRequests ?? 0;

    return PageScaffold(
      title: l10n.uiSettings,
      showBackButton: true,
      backgroundColor: colors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.lg,
          Spacing.md,
          Spacing.xl,
        ),
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.itemGap),
              child: Text(
                _errorMessage!,
                style: styles.body.copyWith(color: colors.error),
              ),
            ),
          if (user != null)
            _IdentityCard(
              user: user,
              savingPosition: _isSavingPosition,
              onEdit: _editPosition,
            ),
          if (isOwner && pending > 0) ...[
            const SizedBox(height: Spacing.itemGap),
            _PendingRequestsCard(
              count: pending,
              onTap: _openJoinRequests,
            ),
          ],
          const SizedBox(height: Spacing.itemGap),
          FullWidthButton(
            key: const ValueKey('profile-settings-invite'),
            buttonText:
                _isSharing ? l10n.uiFetchingLink : l10n.settingsInvitePlayers,
            icon: Icons.person_add_alt_1_rounded,
            // The design's solid brand green; the shared primary is mint.
            backgroundColor: colors.primary,
            foregroundColor: colors.white,
            loading: _isSharing,
            onPressed: _isSharing ? () {} : _shareInvite,
          ),
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              if (state.errorMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                child: Text(
                  state.errorMessage!,
                  style: styles.caption.copyWith(color: colors.error),
                ),
              );
            },
          ),
          if (canManage) ...[
            const SizedBox(height: Spacing.lg),
            SettingsSection(
              title: l10n.settingsSectionMatches,
              children: [
                SettingsRow(
                  key: const ValueKey('profile-settings-match-day'),
                  icon: Icons.how_to_reg_rounded,
                  tone: SettingsTone.matches,
                  title: l10n.settingsMatchDayTitle,
                  subtitle: _matchDaySummary(l10n, settings),
                  onTap: _openMatchSettings,
                ),
                SettingsRow(
                  key: const ValueKey('profile-settings-team-tasks'),
                  icon: Icons.checklist_rounded,
                  tone: SettingsTone.matches,
                  title: l10n.teamTasksTitle,
                  subtitle: l10n.settingsTasksSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeamTasksPage()),
                  ),
                ),
              ],
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: Spacing.lg),
            SettingsSection(
              title: l10n.settingsSectionSeason,
              children: [
                SettingsRow(
                  key: const ValueKey('profile-settings-season'),
                  icon: Icons.calendar_month_rounded,
                  tone: SettingsTone.season,
                  title: l10n.uiImportMatchSchedule,
                  subtitle: l10n.settingsSeasonSubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SeasonSettingsPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            SettingsSection(
              title: l10n.settingsSectionTeam,
              children: [
                SettingsRow(
                  key: const ValueKey('profile-settings-team-logo'),
                  icon: Icons.shield_outlined,
                  tone: SettingsTone.team,
                  title: l10n.settingsTeamLogoTitle,
                  subtitle: l10n.settingsTeamLogoSubtitle,
                  onTap: _openTeamLogoEditor,
                ),
                SettingsRow(
                  key: const ValueKey('profile-settings-join-requests'),
                  icon: Icons.group_add_outlined,
                  tone: SettingsTone.team,
                  title: l10n.uiApproveNewPlayers,
                  subtitle: settings.pendingJoinRequests == null
                      ? null
                      : pending > 0
                          ? l10n.settingsJoinRequestsPending(pending)
                          : l10n.settingsJoinRequestsNone,
                  trailing: pending > 0 ? SettingsCountBadge(pending) : null,
                  onTap: _openJoinRequests,
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.xl),
          SizedBox(
            height: 52,
            child: TextButton(
              key: const ValueKey('profile-settings-logout'),
              style: TextButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: colors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isLoggingOut ? null : _logout,
              child: _isLoggingOut
                  ? const CupertinoActivityIndicator()
                  : Text(
                      l10n.uiLogOut,
                      style: styles.subtitle2.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _matchDaySummary(AppLocalizations l10n, TeamSettingsState settings) {
    final leaderPicks =
        settings.rsvpSelectionMode == TeamDetails.teamLeaderSelection;
    final max = settings.maxSignups;
    final minutes = settings.meetingOffsetMinutes;
    return [
      leaderPicks ? l10n.teamRsvpLeaderOption : l10n.teamRsvpFirstComeOption,
      if (!leaderPicks && max != null) l10n.settingsSignupLimitSummary(max),
      if (minutes != null && minutes != 0) l10n.settingsMeetingSummary(minutes),
    ].join(' · ');
  }

  Future<void> _editPosition() async {
    final current = context.read<AuthCubit>().state.user?.position;
    final selected = await showEditPositionSheet(context, current: current);
    if (!mounted || selected == null || selected == current) return;

    setState(() {
      _isSavingPosition = true;
      _errorMessage = null;
    });
    try {
      final user = await widget.updatePosition(selected);
      if (!mounted) return;
      context.read<AuthCubit>().updateUser(user);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage =
          AppLocalizations.of(context)!.uiCouldNotSaveThePositionTry);
    } finally {
      if (mounted) setState(() => _isSavingPosition = false);
    }
  }

  Future<void> _openMatchSettings() async {
    final cubit = context.read<TeamSettingsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const MatchSettingsPage(),
        ),
      ),
    );
  }

  Future<void> _openJoinRequests() async {
    final cubit = context.read<TeamSettingsCubit>();
    await context.push(AppRouter.teamJoinRequests);
    if (!mounted) return;
    await cubit.loadPendingJoinRequests();
  }

  Future<void> _openTeamLogoEditor() async {
    final user = context.read<AuthCubit>().state.user;
    final team = user?.teamDetails;
    if (user?.isTeamOwner != true || team == null) return;

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

  Future<void> _shareInvite() async {
    final l10n = AppLocalizations.of(context)!;
    final team = context.read<AuthCubit>().state.user?.teamDetails;
    if (team == null) {
      setState(() => _errorMessage = l10n.uiYouMustBeOnATeam);
      return;
    }

    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    try {
      final token =
          await context.read<OnboardingCubit>().fetchTeamJoinToken(team.id);
      if (!mounted) return;

      if (token == null) {
        setState(() {
          _isSharing = false;
          _errorMessage = l10n.uiCouldNotFetchTheInviteLink;
        });
        return;
      }

      final inviteUri = Uri.https('kopa.dk', '/join', {
        'team_token': token,
        'team_id': team.id.toString(),
        'team_title': team.title,
      });

      await SharePlus.instance.share(
        ShareParams(text: l10n.uiJoinOnKopa(team.title, inviteUri)),
      );
      if (!mounted) return;
      setState(() => _isSharing = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSharing = false;
        _errorMessage = l10n.uiCouldNotShareKopa;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthCubit>().logout();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoggingOut = false;
        _errorMessage = AppLocalizations.of(context)!.uiCouldNotLogOut;
      });
    }
  }
}

class _IdentityCard extends StatelessWidget {
  final UserDetails user;
  final bool savingPosition;
  final VoidCallback onEdit;

  const _IdentityCard({
    required this.user,
    required this.savingPosition,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final team = user.teamDetails;
    final position = _positionLabel(user.position);

    return Container(
      padding: Spacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.lightGrass65,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials(user.name),
                  style: styles.subtitle1.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.h4.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      position ?? l10n.uiChoosePosition,
                      style: styles.body3.copyWith(
                        color: position == null
                            ? colors.primary
                            : colors.textSecondary,
                        fontWeight: position == null ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: savingPosition
                    ? const Center(child: CupertinoActivityIndicator())
                    : IconButton(
                        key: const ValueKey('profile-settings-edit-profile'),
                        tooltip: l10n.uiChoosePosition,
                        onPressed: onEdit,
                        color: colors.primary,
                        icon: const Icon(Icons.edit_outlined, size: 22),
                      ),
              ),
            ],
          ),
          if (team != null) ...[
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(Spacing.itemGap),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
              ),
              child: Row(
                children: [
                  TeamAvatar(
                    teamName: team.title,
                    teamId: team.id,
                    logoDesign: team.logoDesign,
                    radius: 20,
                  ),
                  const SizedBox(width: Spacing.itemGap),
                  Expanded(
                    child: Text(
                      team.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.subtitle2.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  _RoleChip(
                    label: user.canManageTeam
                        ? l10n.onboardingTeamLeader
                        : l10n.onboardingPlayer,
                    emphasized: user.canManageTeam,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _positionLabel(String? position) {
    final value = position?.trim();
    if (value == null || value.isEmpty) return null;
    return inFormPositions.contains(value) ? inFormPositionLabel(value) : value;
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool emphasized;

  const _RoleChip({required this.label, required this.emphasized});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized ? colors.primary : colors.lightGrass65,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        label,
        style: styles.caption.copyWith(
          color: emphasized ? colors.white : colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PendingRequestsCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _PendingRequestsCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final background =
        Color.alphaBlend(colors.sunset.withValues(alpha: .18), colors.surface);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('profile-settings-pending-requests'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.sunset,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 20,
                  color: colors.dirt,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsPendingBannerTitle(count),
                      style: styles.subtitle2.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsPendingBannerBody,
                      style: styles.body3.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: colors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
