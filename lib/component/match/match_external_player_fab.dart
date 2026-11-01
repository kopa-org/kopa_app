import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';

class MatchExternalPlayerFab extends StatelessWidget {
  final int matchId;
  final VoidCallback? onPressed;

  const MatchExternalPlayerFab({
    super.key,
    required this.matchId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return FloatingActionButton.extended(
      key: const ValueKey('match-external-player-fab'),
      heroTag: 'match-$matchId-external-player-fab',
      tooltip: l10n.matchFabAddExternalPlayers,
      backgroundColor: AppColors.matchDetailsHeader,
      foregroundColor: colors.white,
      onPressed: onPressed,
      icon: const Icon(Icons.person_add_alt_1_outlined, size: 24),
      label: Text(l10n.matchFabExternalPlayerLabel),
    );
  }
}
