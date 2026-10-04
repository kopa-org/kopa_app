import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match/attendance_response_dropdown.dart';
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
    final awaitingSelection = status == MatchRsvpStatus.awaitingSelection;
    final attendeeSummary = Semantics(
      button: true,
      label: l10n.matchRsvpAttendeeCount(attendeeCount),
      child: InkWell(
        key: const ValueKey('match-rsvp-attendees'),
        onTap: onShowAttendees,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (attendeeCount > 0) ...[
              _AttendeePreview(
                key: const ValueKey('match-rsvp-attendee-avatars'),
                names: attendeeNames,
                count: attendeeCount,
              ),
              const SizedBox(height: 8),
            ],
            Text(l10n.matchRsvpAttendeeCount(attendeeCount),
                textAlign: TextAlign.right,
                style: styles.bodyBold.copyWith(fontSize: 11, height: 14 / 11)),
          ],
        ),
      ),
    );

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
          if (pending) ...[
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
              ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 145),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: colors.warningSurface,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(l10n.matchRsvpAwaitingResponse,
                        textAlign: TextAlign.center,
                        style: styles.body3.copyWith(
                            fontSize: 10,
                            height: 13 / 10,
                            color: colors.warningForeground)),
                  )),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _choice(
                      context, l10n.matchDetailsRsvpDecline, onDecline,
                      accept: false)),
              const SizedBox(width: 10),
              Expanded(
                  child: _choice(context, l10n.matchDetailsRsvpAccept, onAccept,
                      accept: true)),
            ]),
            const SizedBox(height: 14),
            attendeeSummary,
          ] else
            Row(
              children: [
                Expanded(
                  child: AttendanceResponseDropdown(
                    currentResponse: status != MatchRsvpStatus.declined,
                    awaitingSelection: awaitingSelection,
                    isSaving: isSaving,
                    onAccept: onAccept,
                    onDecline: onDecline,
                    statusKey: const ValueKey('match-details-rsvp-status'),
                  ),
                ),
                const SizedBox(width: 12),
                attendeeSummary,
              ],
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
  const _AttendeePreview({super.key, required this.names, required this.count});

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
