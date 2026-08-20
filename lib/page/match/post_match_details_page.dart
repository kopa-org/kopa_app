import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PostMatchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  final UserDetails user;
  final Widget heroCard;
  final List<Widget> attendanceList;
  final Future<void> Function()? onRefresh;
  final VoidCallback onAddEvent;
  final VoidCallback onSetMatchScore;
  final VoidCallback onCreateMatchPoll;
  final MatchDetailSegment selectedSegment;
  final ValueChanged<MatchDetailSegment> onSegmentChanged;

  const PostMatchDetailsPage({
    super.key,
    required this.match,
    required this.user,
    required this.heroCard,
    required this.attendanceList,
    required this.onAddEvent,
    required this.onSetMatchScore,
    required this.onCreateMatchPoll,
    required this.selectedSegment,
    required this.onSegmentChanged,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return MatchDetailTemplate(
      onRefresh: onRefresh,
      selectedSegment: selectedSegment,
      onSegmentChanged: onSegmentChanged,
      heroCard: heroCard,
      overviewTitle: 'Efter kampen',
      attendanceTitle: 'Tilmeldte',
      timelineTitle: 'Kampbegivenheder',
      attendanceSegmentLabel: 'Tilmeldte',
      timelineSegmentLabel: 'Begivenheder',
      showTimelineSegment: false,
      timelineEmptyMessage: 'Ingen kampbegivenheder registreret endnu.',
      overviewWidgets: [
        if (user.isTeamOwner && !match.hasFinalScore) ...[
          _RegisterMatchResultSection(onPressed: onSetMatchScore),
          const SizedBox(height: Spacing.lg),
        ],
        PlayerOfMatchSummaryCard(
          playerName: match.matchPollDetails?.playerOfTheMatchDetails.name,
          voteCount: match.matchPollDetails?.playerOfTheMatchVotes,
          onPressed: match.matchPollDetails == null ? onCreateMatchPoll : null,
        ),
        const SizedBox(height: Spacing.lg),
        _MatchTimelineSection(
          items: _buildTimelineItems(match),
          canAddEvent: user.isTeamOwner,
          onAddEvent: onAddEvent,
        ),
      ],
      infoRows: const [],
      votingModule: null,
      playerPositions: null,
      attendanceList: attendanceList,
      ratingsSection: null,
      timelineItems: const [],
    );
  }

  List<Widget> _buildTimelineItems(MatchDetails match) {
    final events = List<MatchEventDetails>.from(
      match.matchEventDetailsList ?? const [],
    )..sort((a, b) => (a.minute ?? 0).compareTo(b.minute ?? 0));

    if (events.isEmpty) return [];

    return events.indexed.map((entry) {
      final event = entry.$2;
      final item = _TimelineEventItem.from(event);

      return TimelineItem(
        title: item.title,
        time: item.timeLabel,
        icon: item.icon,
        iconColor: item.iconColor,
        isLast: entry.$1 == events.length - 1,
        subtitle: item.subtitle,
      );
    }).toList();
  }
}

class _RegisterMatchResultSection extends StatelessWidget {
  final VoidCallback onPressed;

  const _RegisterMatchResultSection({required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
              'Registrer kampens resultat',
              style: styles.subtitle2.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Button(
            buttonText: 'Indtast',
            icon: CupertinoIcons.pencil,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _TimelineEventItem {
  final String title;
  final String timeLabel;
  final IconData icon;
  final Color? iconColor;
  final String subtitle;

  const _TimelineEventItem({
    required this.title,
    required this.timeLabel,
    required this.icon,
    this.iconColor,
    required this.subtitle,
  });

  factory _TimelineEventItem.from(MatchEventDetails event) {
    final minute = event.minute != null ? '${event.minute}\'' : null;

    if (event.type == MatchEventType.goal) {
      return _TimelineEventItem(
        title: 'Mål: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'MÅL',
        icon: Icons.sports_soccer,
        subtitle: event.assistMakerUserName != null
            ? 'Assisteret af ${event.assistMakerUserName}'
            : 'Mål',
      );
    }

    if (event.type == MatchEventType.yellowCard) {
      return _TimelineEventItem(
        title: 'Gult kort: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'KORT',
        icon: Icons.square,
        iconColor: Colors.yellow,
        subtitle: 'Gult kort',
      );
    }

    if (event.type == MatchEventType.redCard) {
      return _TimelineEventItem(
        title: 'Rødt kort: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'KORT',
        icon: Icons.square,
        iconColor: Colors.red,
        subtitle: 'Rødt kort',
      );
    }

    if (event.type == MatchEventType.substitution) {
      return _TimelineEventItem(
        title:
            '${event.goalscorerUserName} (Ind) / ${event.assistMakerUserName ?? '?'} (Ud)',
        timeLabel: minute ?? 'UDSK.',
        icon: Icons.swap_horiz,
        subtitle: 'Udskiftning',
      );
    }

    return _TimelineEventItem(
      title: 'Straffe: ${event.goalscorerUserName}',
      timeLabel: minute ?? 'STRAFFE',
      icon: Icons.sports_soccer,
      iconColor: Colors.orange,
      subtitle: 'Straffespark',
    );
  }
}

class _MatchTimelineSection extends StatelessWidget {
  final List<Widget> items;
  final bool canAddEvent;
  final VoidCallback onAddEvent;

  const _MatchTimelineSection({
    required this.items,
    required this.canAddEvent,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _MatchTimelineEmptyState(
        canAddEvent: canAddEvent,
        onAddEvent: onAddEvent,
      );
    }

    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kampforløb',
          style: styles.subtitle1.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        KopaCard(
          borderRadius: Spacing.borderRadiusLargeIncreased,
          padding: const EdgeInsets.all(20),
          child: Column(children: items),
        ),
        if (canAddEvent) ...[
          const SizedBox(height: Spacing.lg),
          _AddMatchEventOutlineButton(onPressed: onAddEvent),
        ],
      ],
    );
  }
}

class _MatchTimelineEmptyState extends StatelessWidget {
  final bool canAddEvent;
  final VoidCallback onAddEvent;

  const _MatchTimelineEmptyState({
    required this.canAddEvent,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      borderRadius: Spacing.borderRadiusLargeIncreased,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.offWhite,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              CupertinoIcons.list_bullet_indent,
              color: colors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Ingen hændelser endnu',
            style: styles.subtitle1.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Tilføj hændelser som mål, kort og udskiftninger',
            style: styles.body3.copyWith(color: colors.dirt),
            textAlign: TextAlign.center,
          ),
          if (canAddEvent) ...[
            const SizedBox(height: Spacing.lg),
            _AddMatchEventButton(onPressed: onAddEvent),
          ],
        ],
      ),
    );
  }
}

class _AddMatchEventButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMatchEventButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+ Tilføj hændelse',
          style: styles.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AddMatchEventOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMatchEventOutlineButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+ Tilføj hændelse',
          style: styles.body1.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
