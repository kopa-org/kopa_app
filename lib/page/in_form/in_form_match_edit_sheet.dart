import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Opens the per-match in-form editor. Returns only the fields that changed
/// (in the API's wire format), or null when dismissed.
///
/// Every player can change their own position for a match. When
/// [canEditMatchData] is true (team owner) the data points the match timeline
/// cannot express can be registered as well.
Future<Map<String, Object?>?> showInFormMatchEditSheet(
  BuildContext context, {
  required InFormMatchBreakdown match,
  required bool canEditMatchData,
}) {
  final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

  return showModalBottomSheet<Map<String, Object?>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colors.offWhite,
    builder: (_) => _InFormMatchEditSheet(
      match: match,
      canEditMatchData: canEditMatchData,
    ),
  );
}

class _InFormMatchEditSheet extends StatefulWidget {
  final InFormMatchBreakdown match;
  final bool canEditMatchData;

  const _InFormMatchEditSheet({
    required this.match,
    required this.canEditMatchData,
  });

  @override
  State<_InFormMatchEditSheet> createState() => _InFormMatchEditSheetState();
}

class _InFormMatchEditSheetState extends State<_InFormMatchEditSheet> {
  late String? _position = widget.match.override.position;
  late final Map<String, int> _initialCounts = {
    'own_goals': widget.match.stats.ownGoals,
    'penalties_missed': widget.match.stats.penaltiesMissed,
    'penalties_saved': widget.match.stats.penaltiesSaved,
    'decisive_goals': widget.match.stats.decisiveGoals,
  };
  late final Map<String, int> _counts = Map.of(_initialCounts);

  Map<String, Object?> get _changes => {
        if (_position != widget.match.override.position) 'position': _position,
        for (final entry in _counts.entries)
          if (entry.value != _initialCounts[entry.key]) entry.key: entry.value,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final changes = _changes;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          0,
          Spacing.md,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.match.opponent ?? l10n.inFormUnknownOpponent,
              style: styles.sectionHeader,
            ),
            const SizedBox(height: Spacing.lg),
            Text(l10n.inFormMatchPosition, style: styles.bodyBold),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.inFormMatchPositionHint,
              style: styles.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.itemGap),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                InFormPill(
                  label: l10n.inFormUseProfilePosition,
                  selected: _position == null,
                  onTap: () => setState(() => _position = null),
                ),
                for (final position in inFormPositions)
                  InFormPill(
                    label: inFormPositionLabel(position),
                    selected: _position == position,
                    selectedColor: colors.sky,
                    onTap: () => setState(() => _position = position),
                  ),
              ],
            ),
            if (widget.canEditMatchData) ...[
              const SizedBox(height: Spacing.lg),
              Text(l10n.inFormMatchDataPoints, style: styles.bodyBold),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.inFormMatchDataPointsHint,
                style: styles.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: Spacing.sm),
              InFormPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                child: Column(
                  children: [
                    _counter('own_goals', l10n.inFormOwnGoals),
                    _counter('penalties_missed', l10n.inFormPenaltiesMissed),
                    _counter('penalties_saved', l10n.inFormPenaltiesSaved),
                    _counter('decisive_goals', l10n.inFormDecisiveGoals),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.grass,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: changes.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(changes),
                child: Text(l10n.inFormSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter(String field, String label) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final value = _counts[field] ?? 0;

    return Row(
      children: [
        Expanded(child: Text(label, style: styles.body)),
        IconButton(
          onPressed: value == 0
              ? null
              : () => setState(() => _counts[field] = value - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: styles.bodyBold,
          ),
        ),
        IconButton(
          onPressed: value >= 20
              ? null
              : () => setState(() => _counts[field] = value + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
