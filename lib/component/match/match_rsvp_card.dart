import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/match/attendance_response_dropdown.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum MatchRsvpStatus { pending, awaitingSelection, attending, declined }

class MatchRsvpCard extends StatelessWidget {
  final MatchRsvpStatus status;
  final bool isTraining;
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const MatchRsvpCard({
    super.key,
    required this.status,
    this.isTraining = false,
    required this.isSaving,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final pending = status == MatchRsvpStatus.pending;
    final awaitingSelection = status == MatchRsvpStatus.awaitingSelection;

    // No card chrome: the RSVP sits directly on the page background.
    return KeyedSubtree(
      key: const ValueKey('match-rsvp-card'),
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
          ] else
            AttendanceResponseDropdown(
              currentResponse: status != MatchRsvpStatus.declined,
              awaitingSelection: awaitingSelection,
              isSaving: isSaving,
              onAccept: onAccept,
              onDecline: onDecline,
              statusKey: const ValueKey('match-details-rsvp-status'),
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
