import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class VotingModule extends StatelessWidget {
  final String title;
  final List<VotingOption> options;
  final bool hasVoted;
  final Function(int optionId)? onVote;

  const VotingModule({
    super.key,
    required this.title,
    required this.options,
    this.hasVoted = false,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appTextStyles.bodyBold,
          ),
          const SizedBox(height: Spacing.md),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _buildOption(context, option, appColors, appTextStyles),
          )),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, VotingOption option, AppColors appColors, AppTextStyles appTextStyles) {
    final double percentage = option.totalVotes > 0 
        ? (option.votes / option.totalVotes) 
        : 0;

    return InkWell(
      onTap: (!hasVoted && onVote != null) ? () => onVote!(option.id) : null,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      child: Stack(
        children: [
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
            ),
          ),
          FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: appColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
              ),
            ),
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              children: [
                if (option.avatarUrl != null || option.initials != null) ...[
                  AppAvatar(
                    imageUrl: option.avatarUrl,
                    initials: option.initials,
                    radius: 14,
                  ),
                  const SizedBox(width: Spacing.sm),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    style: appTextStyles.body.copyWith(
                      fontWeight: option.isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: appTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (option.isSelected)
            Positioned(
              right: 8,
              top: 8,
              child: Icon(
                Icons.check_circle,
                color: appColors.primary,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class VotingOption {
  final int id;
  final String label;
  final int votes;
  final int totalVotes;
  final bool isSelected;
  final String? avatarUrl;
  final String? initials;

  VotingOption({
    required this.id,
    required this.label,
    required this.votes,
    required this.totalVotes,
    this.isSelected = false,
    this.avatarUrl,
    this.initials,
  });
}
