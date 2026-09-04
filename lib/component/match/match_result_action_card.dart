import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class MatchResultActionCard extends StatelessWidget {
  final VoidCallback onPressed;

  const MatchResultActionCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      borderRadius: Spacing.borderRadiusLargeIncreased,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.lightGrass.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
            ),
            child: Icon(
              CupertinoIcons.sportscourt,
              color: colors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              l10n.matchRegisterResult,
              style: styles.subtitle2.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Button(
            buttonText: l10n.matchEnterResult,
            icon: CupertinoIcons.pencil,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
