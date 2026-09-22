import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class MatchPollDetailsCard extends StatelessWidget {
  final MatchPollDetails poll;
  final VoidCallback? onEdit;

  const MatchPollDetailsCard({
    super.key,
    required this.poll,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final winnerId = poll.playerOfTheMatchDetails?.id ??
        -(poll.playerOfTheMatchExternalPlayerDetails?.id ?? 0);
    final votes = [...poll.matchPollUserVotesDetails]
      ..sort((a, b) => b.numberOfVotes.compareTo(a.numberOfVotes));

    return KopaCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.lightGrass.withValues(alpha: 0.38),
                  borderRadius:
                      BorderRadius.circular(Spacing.borderRadiusSmall),
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.matchPollTitle,
                      style: styles.sectionHeader,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.matchPollTotalVotes(
                        votes.isEmpty
                            ? poll.playerOfTheMatchVotes
                            : votes.fold<int>(
                                0, (sum, vote) => sum + vote.numberOfVotes),
                      ),
                      style: styles.caption,
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: l10n.matchPollEdit,
                  icon: const Icon(CupertinoIcons.pencil),
                  color: colors.primary,
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (votes.isEmpty)
            Padding(
              key: const ValueKey('match-poll-winner'),
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _MatchPollVoteRow(
                row: _MatchPollRowData(
                  userId: winnerId,
                  userName: poll.winnerName,
                  votes: poll.playerOfTheMatchVotes,
                ),
                winnerId: winnerId,
              ),
            ),
          for (final vote in votes)
            Padding(
              key: ValueKey(
                  'match-poll-vote-${vote.userId ?? -vote.externalPlayerId!}'),
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _MatchPollVoteRow(
                row: _MatchPollRowData(
                  userId: vote.userId ?? -vote.externalPlayerId!,
                  userName: vote.userName ??
                      vote.externalPlayerName ??
                      ((vote.userId ?? -vote.externalPlayerId!) == winnerId
                          ? poll.winnerName
                          : l10n.matchPollUnknownPlayer),
                  votes: vote.numberOfVotes,
                ),
                winnerId: winnerId,
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchPollRowData {
  final int userId;
  final String userName;
  final int votes;

  const _MatchPollRowData({
    required this.userId,
    required this.userName,
    required this.votes,
  });
}

class _MatchPollVoteRow extends StatelessWidget {
  final _MatchPollRowData row;
  final int winnerId;

  const _MatchPollVoteRow({
    required this.row,
    required this.winnerId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final isWinner = row.userId == winnerId;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isWinner
            ? colors.lightGrass.withValues(alpha: 0.22)
            : colors.offWhite,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.userName,
                    style: styles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isWinner) ...[
                  const SizedBox(width: Spacing.sm),
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 18,
                    color: colors.sunset,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Text(
            _voteLabel(context, row.votes),
            style: styles.bodyBold.copyWith(
              color: isWinner ? colors.primary : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _voteLabel(BuildContext context, int count) {
    return AppLocalizations.of(context)!.matchPollVoteCount(count);
  }
}
