import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class FinesCard extends StatelessWidget {
  final double totalFines;

  const FinesCard({
    super.key,
    required this.totalFines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.error, appColors.dirt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.error.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                'Udestående Bøder',
                style: appTextStyles.bodyBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            '${totalFines.toInt()} kr',
            style: appTextStyles.pageTitle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}