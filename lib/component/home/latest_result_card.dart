import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class HomeLatestResultCard extends StatefulWidget {
  final MatchDetails? match;
  final UserDetails currentUser;
  final void Function(MatchDetails match) onOpenMatch;
  final String Function(MatchDetails match, String source) matchHeroTag;

  const HomeLatestResultCard({
    super.key,
    required this.match,
    required this.currentUser,
    required this.onOpenMatch,
    required this.matchHeroTag,
  });

  @override
  State<HomeLatestResultCard> createState() => _HomeLatestResultCardState();
}

class _HomeLatestResultCardState extends State<HomeLatestResultCard> {
  bool _showAllEvents = false;

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final match = widget.match;
    final score = match == null
        ? '--'
        : '${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0}';
    final result = _resultStatus(match, widget.currentUser);
    final motm = match?.matchPollDetails?.playerOfTheMatchDetails.name;
    final motmVotes = match?.matchPollDetails?.playerOfTheMatchVotes;
    final events = [...?match?.matchEventDetailsList]
      ..sort((a, b) => (b.minute ?? 0).compareTo(a.minute ?? 0));
    final goalCount =
        events.where((event) => event.type == MatchEventType.goal).length;
    final yellowCardCount =
        events.where((event) => event.type == MatchEventType.yellowCard).length;
    final redCardCount =
        events.where((event) => event.type == MatchEventType.redCard).length;
    final cardHeroTag =
        match == null ? null : widget.matchHeroTag(match, 'home_latest');

    return HomeBentoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      color: appColors.white,
      child: InkWell(
        onTap: match == null ? null : () => widget.onOpenMatch(match),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SENESTE RESULTAT',
                    style: appTextStyles.label.copyWith(
                      color: appColors.grey5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (result != null) MatchResultBadge(result: result),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TeamBadgeLabel(
                  teamName: match?.homeTeam ?? 'Hjemme',
                  teamId: stableTeamSeed(match?.homeTeam ?? 'Hjemme'),
                  heroTag: cardHeroTag == null
                      ? null
                      : MatchHeroCard.logoHeroTag(
                          cardHeroTag,
                          TeamSide.home,
                        ),
                  width: 86,
                  radius: 22,
                  labelStyle: appTextStyles.caption.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  score,
                  style: appTextStyles.h2.copyWith(
                    color: appColors.dirt,
                    fontSize: 42,
                  ),
                ),
                TeamBadgeLabel(
                  teamName: match?.awayTeam ?? 'Ude',
                  teamId: stableTeamSeed(match?.awayTeam ?? 'Ude'),
                  heroTag: cardHeroTag == null
                      ? null
                      : MatchHeroCard.logoHeroTag(
                          cardHeroTag,
                          TeamSide.away,
                        ),
                  width: 86,
                  radius: 22,
                  labelStyle: appTextStyles.caption.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            PlayerOfMatchSummaryCard(
              playerName: motm,
              voteCount: motmVotes,
            ),
            if (match != null) ...[
              const SizedBox(height: Spacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kamphistorik',
                  style: appTextStyles.label.copyWith(
                    color: appColors.grey5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              if (events.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingen hændelser registreret',
                    style: appTextStyles.caption2.copyWith(
                      color: appColors.grey5,
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _LatestResultEventSummary(
                        icon: Icons.sports_soccer,
                        label: 'Mål',
                        count: goalCount,
                        color: appColors.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: _LatestResultEventSummary(
                        icon: Icons.crop_portrait,
                        label: 'Gule kort',
                        count: yellowCardCount,
                        color: appColors.warning,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: _LatestResultEventSummary(
                        icon: Icons.crop_portrait,
                        label: 'Røde kort',
                        count: redCardCount,
                        color: appColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _showAllEvents = !_showAllEvents),
                    iconAlignment: IconAlignment.end,
                    icon: AnimatedRotation(
                      turns: _showAllEvents ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(Icons.keyboard_arrow_down, size: 20),
                    ),
                    label: Text(
                      _showAllEvents
                          ? 'Skjul hændelser'
                          : 'Vis alle hændelser (${events.length})',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: appColors.dirt,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.xs,
                      ),
                      textStyle: appTextStyles.caption2.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _showAllEvents
                      ? Padding(
                          padding: const EdgeInsets.only(top: Spacing.xs),
                          child: Column(
                            children: [
                              for (final event in events)
                                _LatestResultHistoryRow(event: event),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _LatestResultEventSummary extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _LatestResultEventSummary({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: appColors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: Spacing.xs),
              Text(
                '$count',
                style: appTextStyles.subtitle2.copyWith(
                  color: appColors.dirt,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appTextStyles.caption3.copyWith(
              color: appColors.grey5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestResultHistoryRow extends StatelessWidget {
  final MatchEventDetails event;

  const _LatestResultHistoryRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final (icon, color, label) = switch (event.type) {
      MatchEventType.goal => (
          Icons.sports_soccer,
          appColors.primary,
          'Mål',
        ),
      MatchEventType.yellowCard => (
          Icons.crop_portrait,
          appColors.warning,
          'Gult kort',
        ),
      MatchEventType.redCard => (
          Icons.crop_portrait,
          appColors.error,
          'Rødt kort',
        ),
      MatchEventType.substitution => (
          Icons.swap_horiz,
          appColors.sky,
          'Udskiftning',
        ),
      MatchEventType.penaltyKick => (
          Icons.sports_soccer,
          appColors.sunset,
          'Straffespark',
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              event.minute == null ? '-' : '${event.minute}′',
              style: appTextStyles.caption2.copyWith(
                color: appColors.grey5,
              ),
            ),
          ),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              _latestResultEventLabel(event),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.caption2.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: appTextStyles.caption3.copyWith(
              color: appColors.grey5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _latestResultEventLabel(MatchEventDetails event) {
  if (event.type == MatchEventType.goal && event.assistMakerUserName != null) {
    return '${event.goalscorerUserName} (Assist: ${event.assistMakerUserName})';
  }

  if (event.type == MatchEventType.substitution) {
    return '${event.goalscorerUserName} ind / ${event.assistMakerUserName ?? '?'} ud';
  }

  return event.goalscorerUserName;
}

MatchResultStatus? _resultStatus(
  MatchDetails? match,
  UserDetails currentUser,
) {
  if (match == null ||
      match.homeTeamScore == null ||
      match.awayTeamScore == null) {
    return null;
  }

  final currentTeamName = currentUser.teamDetails?.title.toLowerCase();
  final isHome = match.homeTeam?.toLowerCase() == currentTeamName;
  final currentScore = isHome ? match.homeTeamScore! : match.awayTeamScore!;
  final opponentScore = isHome ? match.awayTeamScore! : match.homeTeamScore!;

  return MatchResultStatus.fromScores(
    teamScore: currentScore,
    opponentScore: opponentScore,
  );
}
