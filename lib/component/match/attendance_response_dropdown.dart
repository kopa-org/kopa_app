import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class AttendanceResponseDropdown extends StatelessWidget {
  final bool currentResponse;
  final bool isSaving;
  final bool awaitingSelection;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final Key? statusKey;

  const AttendanceResponseDropdown({
    super.key,
    required this.currentResponse,
    required this.isSaving,
    this.awaitingSelection = false,
    required this.onAccept,
    required this.onDecline,
    this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final statusColor = awaitingSelection
        ? colors.warningForeground
        : currentResponse
            ? colors.grass
            : colors.error;

    Future<void> changeResponse() async {
      if (isSaving) return;
      final response = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: AppColors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _AttendanceResponseSheet(
          currentResponse: currentResponse,
          colors: colors,
          styles: styles,
          l10n: l10n,
        ),
      );
      if (!context.mounted || response == null || response == currentResponse) {
        return;
      }
      response ? onAccept() : onDecline();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: l10n.homeAttendanceChange,
        child: Material(
          color: statusColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
          child: InkWell(
            key: statusKey,
            onTap: isSaving ? null : changeResponse,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      awaitingSelection
                          ? Icons.schedule
                          : currentResponse
                              ? Icons.check
                              : Icons.close,
                      size: 18,
                      color: statusColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isSaving
                          ? l10n.homeAttendanceSaving
                          : awaitingSelection
                              ? l10n.matchDetailsRsvpPendingSelection
                              : currentResponse
                                  ? l10n.homeAttendanceGoing
                                  : l10n.homeAttendanceDeclined,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body3.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down, size: 20, color: statusColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceResponseSheet extends StatelessWidget {
  final bool currentResponse;
  final AppColors colors;
  final AppTextStyles styles;
  final AppLocalizations l10n;

  const _AttendanceResponseSheet({
    required this.currentResponse,
    required this.colors,
    required this.styles,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            12,
            Spacing.md,
            Spacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.grey4,
                    borderRadius: BorderRadius.circular(
                      Spacing.borderRadiusFull,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(l10n.homeAttendanceChange, style: styles.sectionHeader),
              const SizedBox(height: Spacing.sm),
              _AttendanceResponseOption(
                key: const ValueKey('attendance_response_yes'),
                label: l10n.homeAttendanceYes,
                icon: Icons.how_to_reg,
                color: colors.grass,
                selected: currentResponse,
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: Spacing.sm),
              _AttendanceResponseOption(
                key: const ValueKey('attendance_response_no'),
                label: l10n.homeAttendanceNo,
                icon: Icons.close,
                color: colors.error,
                selected: !currentResponse,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceResponseOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AttendanceResponseOption({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? color.withValues(alpha: 0.10) : colors.offWhite,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: styles.bodyBold.copyWith(color: colors.dirt),
                  ),
                ),
                if (selected) Icon(Icons.check, color: color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
