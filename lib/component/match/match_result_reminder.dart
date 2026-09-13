import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class MatchResultReminderButton extends StatefulWidget {
  final MatchDetails match;
  final VoidCallback onPressed;

  const MatchResultReminderButton({
    super.key,
    required this.match,
    required this.onPressed,
  });

  @override
  State<MatchResultReminderButton> createState() =>
      _MatchResultReminderButtonState();
}

class _MatchResultReminderButtonState extends State<MatchResultReminderButton> {
  Timer? _timer;
  late bool _showReminder;

  @override
  void initState() {
    super.initState();
    _showReminder = _isDue;
    _scheduleRefresh();
  }

  @override
  void didUpdateWidget(covariant MatchResultReminderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) {
      _refresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isDue => widget.match.shouldPromptForResultAt(DateTime.now());

  void _refresh() {
    if (!mounted) return;

    final showReminder = _isDue;
    if (showReminder != _showReminder) {
      setState(() => _showReminder = showReminder);
    }
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _timer?.cancel();
    if (_showReminder || widget.match.hasFinalScore) return;

    final reminderAt = widget.match.date.add(MatchDetails.resultReminderDelay);
    final remaining = reminderAt.difference(DateTime.now());
    _timer = Timer(
      remaining.isNegative || remaining == Duration.zero
          ? const Duration(milliseconds: 1)
          : remaining,
      _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showReminder) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      key: const ValueKey('match-result-reminder'),
      tooltip: l10n.matchResultReminderTitle,
      onPressed: widget.onPressed,
      padding: EdgeInsets.zero,
      icon: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline,
          color: colors.sun,
          size: 25,
        ),
      ),
    );
  }
}

Future<void> showMatchResultReminderDialog(
  BuildContext context, {
  required FutureOr<void> Function() onEnterResult,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final enterResult = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors =
          Theme.of(dialogContext).extension<AppColors>() ?? AppColors.light;
      final styles = Theme.of(dialogContext).extension<AppTextStyles>() ??
          AppTextStyles.light;

      return AlertDialog(
        icon: Icon(Icons.info_outline, color: colors.sun),
        title: Text(l10n.matchResultReminderTitle),
        content: Text(
          l10n.matchResultReminderMessage,
          style: styles.body3.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.lightGrass,
              foregroundColor: colors.dirt,
              elevation: 0,
            ),
            child: Text(l10n.matchResultReminderAction),
          ),
        ],
      );
    },
  );

  if (enterResult == true && context.mounted) {
    await onEnterResult();
  }
}
