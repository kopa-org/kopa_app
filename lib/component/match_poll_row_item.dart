import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:provider/provider.dart';

class MatchPollRowItem extends StatelessWidget {
  final bool disabled;
  final int userId;
  final String userName;
  final bool isUserPlayerOfTheMatch;

  const MatchPollRowItem({
    super.key,
    this.disabled = false,
    required this.userId,
    required this.userName,
    this.isUserPlayerOfTheMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final votesState = context.watch<UserVotesState>();
    final votes = votesState.votesForUser(userId);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: votes > 0
            ? appColors.lightGrass.withValues(alpha: 0.22)
            : appColors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
        border: Border.all(
          color: votes > 0
              ? appColors.primary.withValues(alpha: 0.32)
              : appColors.divider,
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            initials: _getInitials(userName),
            radius: 20,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: appTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isUserPlayerOfTheMatch)
                  Text(
                    'Kampens spiller',
                    style: appTextStyles.caption.copyWith(
                      color: appColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          _VoteStepper(
            votes: votes,
            disabled: disabled,
            onChanged: (nextVotes) {
              context.read<UserVotesState>().updateUserVote(userId, nextVotes);
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}

class _VoteStepper extends StatelessWidget {
  final int votes;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const _VoteStepper({
    required this.votes,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final canDecrease = votes > 0 && !disabled;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: appColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: CupertinoIcons.minus,
            enabled: canDecrease,
            onPressed: () => onChanged(votes - 1),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$votes',
              textAlign: TextAlign.center,
              style: appTextStyles.bodyBold.copyWith(
                color: votes > 0 ? appColors.primary : appColors.textPrimary,
              ),
            ),
          ),
          _StepperButton(
            icon: CupertinoIcons.plus,
            enabled: !disabled,
            onPressed: () => onChanged(votes + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      onPressed: enabled ? onPressed : null,
      child: Icon(
        icon,
        size: 18,
        color: enabled
            ? appColors.primary
            : appColors.textSecondary.withValues(alpha: 0.35),
      ),
    );
  }
}
