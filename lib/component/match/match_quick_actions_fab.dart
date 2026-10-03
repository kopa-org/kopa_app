import 'package:flutter/material.dart';
import 'package:kopa/component/button/expandable_fab.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';

class MatchQuickActionsFab extends StatefulWidget {
  final int matchId;
  final bool hasPoll;
  final bool hasFinalScore;
  final VoidCallback? onPoll;
  final VoidCallback? onResult;
  final VoidCallback? onExternalPlayers;

  const MatchQuickActionsFab({
    super.key,
    required this.matchId,
    this.hasPoll = false,
    this.hasFinalScore = false,
    required this.onPoll,
    required this.onResult,
    required this.onExternalPlayers,
  });

  @override
  State<MatchQuickActionsFab> createState() => _MatchQuickActionsFabState();
}

class _MatchQuickActionsFabState extends State<MatchQuickActionsFab> {
  final _fabKey = GlobalKey<ExpandableFabState>();

  Widget _action(String name, String label, String tooltip, IconData icon,
      VoidCallback? callback) {
    final colors = AppColors.of(context);
    return FloatingActionButton.extended(
      key: ValueKey('match-fab-$name'),
      heroTag: 'match-${widget.matchId}-fab-$name',
      tooltip: tooltip,
      backgroundColor: colors.surface,
      foregroundColor: callback == null ? colors.grey4 : colors.grass,
      onPressed: callback == null
          ? null
          : () {
              _fabKey.currentState?.close();
              callback();
            },
      icon: Icon(icon, size: 24),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return ExpandableFab(
      key: _fabKey,
      distance: 64,
      expandVertically: true,
      expandedWidth: 280,
      openButtonKey: const ValueKey('match-quick-actions-fab'),
      heroTag: 'match-${widget.matchId}-quick-actions',
      tooltip: l10n.matchActionsMore,
      backgroundColor: AppColors.matchDetailsHeader,
      foregroundColor: colors.white,
      children: [
        _action(
            'motm',
            l10n.matchFabMotmLabel,
            widget.hasPoll
                ? l10n.matchFabEditMotmPoll
                : l10n.matchFabCreateMotmPoll,
            Icons.emoji_events_outlined,
            widget.onPoll),
        _action(
            'result',
            l10n.matchFabResultLabel,
            widget.hasFinalScore
                ? l10n.matchActionsEditResult
                : l10n.matchFabEnterResult,
            Icons.scoreboard_outlined,
            widget.onResult),
        _action(
            'external-players',
            l10n.matchFabExternalPlayerLabel,
            l10n.matchFabAddExternalPlayers,
            Icons.person_add_alt_1_outlined,
            widget.onExternalPlayers),
      ],
    );
  }
}
