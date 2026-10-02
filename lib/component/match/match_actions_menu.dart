import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';

enum _MatchAction { delete, result, externalPlayer, editTraining }

class MatchActionsMenu extends StatelessWidget {
  final bool isTraining;
  final bool hasFinalScore;
  final bool isAddingExternalPlayer;
  final VoidCallback onDelete;
  final VoidCallback onEnterResult;
  final VoidCallback onCreateExternalPlayer;
  final VoidCallback onEditTraining;

  const MatchActionsMenu({
    super.key,
    required this.isTraining,
    required this.hasFinalScore,
    required this.isAddingExternalPlayer,
    required this.onDelete,
    required this.onEnterResult,
    required this.onCreateExternalPlayer,
    required this.onEditTraining,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return PopupMenuButton<_MatchAction>(
      key: const ValueKey('match-actions-menu'),
      tooltip: l10n.matchActionsMore,
      position: PopupMenuPosition.under,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: SvgPicture.asset(
        'assets/icons/match/more.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          isTraining ? colors.textPrimary : colors.white,
          BlendMode.srcIn,
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case _MatchAction.delete:
            onDelete();
          case _MatchAction.result:
            onEnterResult();
          case _MatchAction.externalPlayer:
            onCreateExternalPlayer();
          case _MatchAction.editTraining:
            onEditTraining();
        }
      },
      itemBuilder: (_) => [
        if (isTraining)
          PopupMenuItem(
            key: const ValueKey('edit-training-action'),
            value: _MatchAction.editTraining,
            child: Text(l10n.eventEditTrainingAction),
          ),
        if (!isTraining) ...[
          PopupMenuItem(
            key: const ValueKey('match-register-result-action'),
            value: _MatchAction.result,
            child: Text(hasFinalScore
                ? l10n.matchActionsEditResult
                : l10n.matchRegisterResult),
          ),
          PopupMenuItem(
            key: const ValueKey('create-external-player'),
            value: _MatchAction.externalPlayer,
            enabled: !isAddingExternalPlayer,
            child: Text(l10n.externalPlayerCreateButton),
          ),
        ],
        PopupMenuItem(
          key: const ValueKey('delete-match-action'),
          value: _MatchAction.delete,
          child: Row(children: [
            Icon(CupertinoIcons.delete, size: 18, color: colors.error),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isTraining ? l10n.eventDeleteTraining : l10n.matchDelete,
                style: TextStyle(color: colors.error),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
