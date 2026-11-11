import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Lets the signed-in player pick their position. Returns the chosen position
/// key, or null when dismissed.
Future<String?> showEditPositionSheet(
  BuildContext context, {
  required String? current,
}) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: colors.offWhite,
    showDragHandle: true,
    builder: (context) {
      final styles =
          Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
      final l10n = AppLocalizations.of(context)!;
      return SafeArea(
        child: Padding(
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
              Text(l10n.uiChoosePosition, style: styles.sectionHeader),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  for (final position in inFormPositions)
                    InFormPill(
                      key: ValueKey('edit-position-$position'),
                      label: inFormPositionLabel(position),
                      selected: current == position,
                      onTap: () => Navigator.pop(context, position),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
