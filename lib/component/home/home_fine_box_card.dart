import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class HomeFineBoxCard extends StatelessWidget {
  final FineBoxDetails? fineBox;
  final UserDetails currentUser;
  final VoidCallback onOpenFineBox;

  const HomeFineBoxCard({
    super.key,
    required this.fineBox,
    required this.currentUser,
    required this.onOpenFineBox,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _FineBoxPalette(appColors);
    final personalAmounts = fineBox == null
        ? (0.0, 0.0)
        : _personalFineAmounts(fineBox!, currentUser);
    final totalBalance = fineBox == null
        ? 0.0
        : fineBox!.currentAmount + fineBox!.totalOwedAmount;
    final primaryAmount =
        currentUser.isTeamOwner ? totalBalance : personalAmounts.$2;
    final collected = fineBox?.currentAmount ?? 0;
    final target = math.max(totalBalance, 1);
    final progress = (collected / target).clamp(0.0, 1.0);

    return HomeBentoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: InkWell(
        onTap: fineBox == null ? null : onOpenFineBox,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BØDEKASSEN',
                        style: appTextStyles.label.copyWith(
                          color: palette.onSurfaceMuted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        '${primaryAmount.toStringAsFixed(0)},-',
                        style: _displayStyle(context).copyWith(
                          color: appColors.primary,
                          fontSize: 42,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.savings_outlined, color: appColors.primary),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Text(
                  currentUser.isTeamOwner ? 'Indsamlet' : 'Samlet bøder',
                  style: appTextStyles.caption2.copyWith(
                    color: palette.onSurfaceMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  currentUser.isTeamOwner
                      ? '${collected.toStringAsFixed(0)},-'
                      : '${personalAmounts.$1.toStringAsFixed(0)},-',
                  style: appTextStyles.caption2.copyWith(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: palette.surfaceRaised,
                valueColor: AlwaysStoppedAnimation<Color>(appColors.primary),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Text(
                  currentUser.isTeamOwner ? 'Gå til bødekassen' : 'Betal nu',
                  style: appTextStyles.buttonSmall.copyWith(
                    color: appColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: appColors.primary, size: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FineBoxPalette {
  final AppColors colors;

  const _FineBoxPalette(this.colors);

  Color get surfaceRaised => colors.grey2;
  Color get onSurface => colors.dirt;
  Color get onSurfaceMuted => colors.grey5;
}

(double, double) _personalFineAmounts(
  FineBoxDetails fineBox,
  UserDetails currentUser,
) {
  try {
    final myFineDetails = fineBox.userFineDetails
        .firstWhere((userFine) => userFine.userDetails.id == currentUser.id);
    final totalAmount = myFineDetails.fineDetailsList
        .fold(0.0, (sum, fine) => sum + fine.owedAmount);
    final owedAmount = myFineDetails.fineDetailsList
        .where((fine) => !fine.hasBeenPaid)
        .fold(0.0, (sum, fine) => sum + fine.owedAmount);
    return (totalAmount, owedAmount);
  } catch (_) {
    return (0.0, 0.0);
  }
}

TextStyle _displayStyle(BuildContext context) {
  final appTextStyles =
      Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
  return appTextStyles.h2.copyWith(
    fontWeight: FontWeight.w900,
  );
}
