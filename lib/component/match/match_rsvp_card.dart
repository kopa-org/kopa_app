import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum MatchRsvpStatus { pending, awaitingSelection, attending, declined }

class MatchRsvpCard extends StatelessWidget {
  final MatchRsvpStatus status;
  final bool isTraining;
  final bool isSaving;
  final List<String> attendeeNames;
  final int attendeeCount;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onShowAttendees;

  const MatchRsvpCard({
    super.key,
    required this.status,
    this.isTraining = false,
    required this.isSaving,
    required this.attendeeNames,
    required this.attendeeCount,
    required this.onAccept,
    required this.onDecline,
    required this.onShowAttendees,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final pending = status == MatchRsvpStatus.pending;
    final declined = status == MatchRsvpStatus.declined;
    final awaitingSelection = status == MatchRsvpStatus.awaitingSelection;
    final statusColor = pending || awaitingSelection
        ? colors.warningForeground
        : declined
            ? colors.error
            : colors.grass;
    final statusSurface = pending || awaitingSelection
        ? colors.warningSurface
        : declined
            ? colors.error.withValues(alpha: 0.08)
            : colors.successSurface;
    final statusLabel = switch (status) {
      MatchRsvpStatus.pending => l10n.matchRsvpAwaitingResponse,
      MatchRsvpStatus.awaitingSelection =>
        l10n.matchDetailsRsvpPendingSelection,
      MatchRsvpStatus.attending => l10n.matchDetailsRsvpRegistered,
      MatchRsvpStatus.declined => l10n.matchDetailsRsvpDeclined,
    };

    return KopaCard(
      key: const ValueKey('match-rsvp-card'),
      borderRadius: 20,
      color: colors.white,
      borderSide: BorderSide(color: colors.grey4.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
            color: colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4))
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.matchRsvpQuestion,
                    style:
                        styles.body1.copyWith(fontSize: 16, height: 20 / 16)),
                const SizedBox(height: 3),
                Text(l10n.matchRsvpHint,
                    style: styles.body3.copyWith(
                        fontSize: 11, height: 14 / 11, color: colors.grey5)),
              ],
            )),
            const SizedBox(width: 10),
            Flexible(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: statusSurface,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(statusLabel,
                  textAlign: TextAlign.center,
                  style: styles.body3.copyWith(
                      fontSize: 10, height: 13 / 10, color: statusColor)),
            )),
          ]),
          const SizedBox(height: 14),
          if (pending)
            Row(children: [
              Expanded(
                  child: _choice(
                      context, l10n.matchDetailsRsvpDecline, onDecline,
                      accept: false)),
              const SizedBox(width: 10),
              Expanded(
                  child: _choice(context, l10n.matchDetailsRsvpAccept, onAccept,
                      accept: true)),
            ])
          else
            Container(
              key: const ValueKey('match-rsvp-confirmation'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                if (!declined && !awaitingSelection)
                  SvgPicture.asset('assets/icons/match/rsvp_confirmed.svg',
                      width: 18,
                      height: 18,
                      colorFilter:
                          ColorFilter.mode(colors.grass, BlendMode.srcIn))
                else
                  Icon(
                      declined
                          ? CupertinoIcons.xmark_circle_fill
                          : CupertinoIcons.clock_fill,
                      size: 18,
                      color: statusColor),
                const SizedBox(height: 8),
                Text(
                    awaitingSelection
                        ? l10n.matchDetailsRsvpPendingSelection
                        : declined
                            ? l10n.matchRsvpDeclinedMessage
                            : isTraining
                                ? l10n.matchRsvpTrainingConfirmed
                                : l10n.matchRsvpConfirmed,
                    textAlign: TextAlign.center,
                    style: styles.bodyBold.copyWith(
                        fontSize: 14, height: 18 / 14, color: statusColor)),
                CupertinoButton(
                  key: ValueKey(declined
                      ? 'match-details-rsvp-accept-action'
                      : 'match-details-rsvp-decline-action'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                  onPressed: isSaving
                      ? null
                      : declined
                          ? onAccept
                          : onDecline,
                  child: isSaving
                      ? const CupertinoActivityIndicator()
                      : Text(
                          declined
                              ? l10n.matchDetailsRsvpAccept
                              : l10n.matchRsvpCancel,
                          textAlign: TextAlign.center,
                          style: styles.body3.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.grey5,
                              decoration: TextDecoration.underline)),
                ),
              ]),
            ),
          const SizedBox(height: 14),
          Semantics(
            button: true,
            label: l10n.matchRsvpAttendeeCount(attendeeCount),
            child: InkWell(
              key: const ValueKey('match-rsvp-attendees'),
              onTap: onShowAttendees,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  _AttendeePreview(names: attendeeNames, count: attendeeCount),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(l10n.matchRsvpAttendeeCount(attendeeCount),
                          textAlign: TextAlign.right,
                          style: styles.bodyBold
                              .copyWith(fontSize: 11, height: 14 / 11))),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice(BuildContext context, String label, VoidCallback onPressed,
      {required bool accept}) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return CupertinoButton(
      key: ValueKey(accept ? 'match-rsvp-accept' : 'match-rsvp-decline'),
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 44),
      onPressed: isSaving ? null : onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: accept ? colors.grass : AppColors.transparent,
          border:
              Border.all(color: accept ? colors.grass : colors.textSecondary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSaving
            ? const CupertinoActivityIndicator()
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (accept) ...[
                  SvgPicture.asset('assets/icons/match/rsvp_accept.svg',
                      width: 16, height: 16),
                  const SizedBox(width: 7),
                ],
                Flexible(
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: styles.bodyBold.copyWith(
                            fontSize: 13,
                            height: 16 / 13,
                            color:
                                accept ? colors.white : colors.textSecondary))),
              ]),
      ),
    );
  }
}

class _AttendeePreview extends StatelessWidget {
  final List<String> names;
  final int count;
  const _AttendeePreview({required this.names, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final visible = names.take(5).toList();
    final remaining = (count - visible.length).clamp(0, count);
    final slots = visible.length + (remaining > 0 ? 1 : 0);
    return SizedBox(
      width: slots == 0 ? 0 : 28 + (slots - 1) * 21.0,
      height: 28,
      child: Stack(children: [
        for (var i = 0; i < slots; i++)
          Positioned(
            left: i * 21.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.white, width: 2)),
              child: AppAvatar(
                radius: 12,
                backgroundColor: colors.successSurface,
                initials:
                    i == visible.length ? '+$remaining' : _initials(visible[i]),
              ),
            ),
          ),
      ]),
    );
  }

  String _initials(String name) {
    final words =
        name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    return (words.first.characters.first +
            (words.length > 1 ? words.last.characters.first : ''))
        .toUpperCase();
  }
}
