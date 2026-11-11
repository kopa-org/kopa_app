import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/settings/settings_list.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/team_settings_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/page/team/team_tasks_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Team-wide match behaviour: how the squad is picked, the default meeting
/// time and match day tasks. Every change is saved immediately.
///
/// Expects a [TeamSettingsCubit] above it (provided by the settings hub).
class MatchSettingsPage extends StatelessWidget {
  const MatchSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final isOwner = context.watch<AuthCubit>().state.user?.isTeamOwner == true;

    return BlocConsumer<TeamSettingsCubit, TeamSettingsState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus &&
          current.saveStatus == TeamSettingsSaveStatus.failed,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSaveFailed)),
        );
      },
      builder: (context, state) {
        final cubit = context.read<TeamSettingsCubit>();
        final saving = state.saveStatus == TeamSettingsSaveStatus.saving;

        return PageScaffold(
          title: l10n.settingsMatchDayTitle,
          showBackButton: true,
          backgroundColor: colors.background,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              Spacing.xl,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                child: Text(
                  l10n.settingsMatchDayIntro,
                  style: styles.body3.copyWith(color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              SettingsSectionLabel(l10n.settingsSignupQuestion),
              _RsvpModeOption(
                key: const ValueKey('match-settings-rsvp-first-come'),
                title: l10n.teamRsvpFirstComeOption,
                description: l10n.settingsRsvpFirstComeDescription,
                selected:
                    state.rsvpSelectionMode != TeamDetails.teamLeaderSelection,
                onTap: saving
                    ? null
                    : () => cubit
                        .setRsvpSelectionMode(TeamDetails.firstComeFirstServed),
              ),
              const SizedBox(height: 10),
              _RsvpModeOption(
                key: const ValueKey('match-settings-rsvp-leader'),
                title: l10n.teamRsvpLeaderOption,
                description: l10n.settingsRsvpLeaderDescription,
                selected:
                    state.rsvpSelectionMode == TeamDetails.teamLeaderSelection,
                onTap: saving
                    ? null
                    : () => cubit
                        .setRsvpSelectionMode(TeamDetails.teamLeaderSelection),
              ),
              if (state.rsvpSelectionMode !=
                  TeamDetails.teamLeaderSelection) ...[
                const SizedBox(height: Spacing.lg),
                SettingsSectionLabel(l10n.settingsSignupLimitSection),
                _SignupLimitCard(
                  maxSignups: state.maxSignups,
                  onChanged: cubit.setMaxSignups,
                ),
              ],
              if (isOwner) ...[
                const SizedBox(height: Spacing.lg),
                SettingsSectionLabel(l10n.settingsMeetingTimeSection),
                _MeetingTimeCard(
                  selected: state.meetingOffsetMinutes,
                  enabled: !saving,
                  onSelected: cubit.setMeetingOffset,
                ),
              ],
              const SizedBox(height: Spacing.lg),
              SettingsSection(
                title: l10n.settingsTasksSection,
                children: [
                  SettingsRow(
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
              const SizedBox(height: Spacing.lg),
              switch (state.saveStatus) {
                TeamSettingsSaveStatus.saving => SettingsSaveStatusLine(
                    text: l10n.settingsSaving,
                    color: colors.textSecondary,
                    busy: true,
                  ),
                TeamSettingsSaveStatus.saved => SettingsSaveStatusLine(
                    text: l10n.settingsSaved,
                    icon: Icons.check_rounded,
                    color: colors.primary,
                  ),
                TeamSettingsSaveStatus.failed => SettingsSaveStatusLine(
                    text: l10n.settingsSaveFailed,
                    icon: Icons.error_outline_rounded,
                    color: colors.error,
                  ),
                TeamSettingsSaveStatus.idle => SettingsSaveStatusLine(
                    text: l10n.settingsAutosaveHint,
                    icon: Icons.check_rounded,
                    color: colors.textSecondary,
                  ),
              },
            ],
          ),
        );
      },
    );
  }
}

class _RsvpModeOption extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;

  const _RsvpModeOption({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
          side: BorderSide(
            color: selected ? colors.primary : colors.offWhite,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: Spacing.cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? colors.primary : colors.grey4,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: styles.subtitle2.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        description,
                        style: styles.body3.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupLimitCard extends StatelessWidget {
  final int? maxSignups;
  final ValueChanged<int?> onChanged;

  const _SignupLimitCard({required this.maxSignups, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final max = maxSignups;
    final limited = max != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
          ),
          child: Column(
            children: [
              MergeSemantics(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.settingsSignupLimitToggle,
                          style: styles.subtitle2.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        key: const ValueKey('match-settings-limit-toggle'),
                        value: limited,
                        activeTrackColor: colors.primary,
                        onChanged: (on) => onChanged(
                          on ? TeamSettingsCubit.defaultSignupLimit : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (limited) ...[
                Divider(height: 1, thickness: 1, color: colors.offWhite),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.settingsSignupLimitLabel,
                          style: styles.subtitle2.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StepperButton(
                        key: const ValueKey('match-settings-limit-decrease'),
                        icon: Icons.remove_rounded,
                        tooltip: l10n.settingsSignupLimitDecrease,
                        onPressed: max > TeamSettingsCubit.minSignupLimit
                            ? () => onChanged(max - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '$max',
                          key: const ValueKey('match-settings-limit-value'),
                          textAlign: TextAlign.center,
                          style: styles.h4.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _StepperButton(
                        key: const ValueKey('match-settings-limit-increase'),
                        icon: Icons.add_rounded,
                        tooltip: l10n.settingsSignupLimitIncrease,
                        onPressed: max < TeamSettingsCubit.maxSignupLimit
                            ? () => onChanged(max + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.xs,
            Spacing.sm,
            Spacing.xs,
            0,
          ),
          child: Text(
            limited
                ? l10n.settingsSignupLimitHelpOn(max)
                : l10n.settingsSignupLimitHelpOff,
            style: styles.caption.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _StepperButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.grey4,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        ),
      ),
      icon: Icon(icon),
    );
  }
}

class _MeetingTimeCard extends StatelessWidget {
  final int? selected;
  final bool enabled;
  final ValueChanged<int?> onSelected;

  const _MeetingTimeCard({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  /// Example kickoff used to make the offset concrete in the preview.
  static const int _exampleKickoffMinutes = 14 * 60;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final options = TeamSettingsCubit.meetingOffsetOptions;
    // Offsets saved before this screen existed may not be one of the presets.
    final current = selected == 0 ? null : selected;

    return Container(
      padding: Spacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsMeetingTimeLabel,
            style: styles.subtitle2.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final minutes in options)
                _OffsetChip(
                  key: ValueKey('match-settings-offset-${minutes ?? 'none'}'),
                  label: minutes == null
                      ? l10n.settingsMeetingNone
                      : l10n.settingsMeetingMinutes(minutes),
                  selected: minutes == current,
                  onTap: enabled ? () => onSelected(minutes) : null,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(Spacing.itemGap),
            decoration: BoxDecoration(
              color: colors.lightGrass65,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 20, color: colors.primary),
                const SizedBox(width: Spacing.itemGap),
                Expanded(
                  child: Text(
                    current == null
                        ? l10n.settingsMeetingPreviewNone
                        : l10n.settingsMeetingPreview(
                            _clock(_exampleKickoffMinutes),
                            _clock(_exampleKickoffMinutes - current),
                          ),
                    style: styles.body3.copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _clock(int minutesOfDay) {
    final value = minutesOfDay % (24 * 60);
    final h = (value ~/ 60).toString().padLeft(2, '0');
    final m = (value % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _OffsetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _OffsetChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: selected ? colors.primary : colors.background,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 56, minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: styles.body3.copyWith(
                    color: selected ? colors.white : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
