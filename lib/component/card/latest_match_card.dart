import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class LatestMatchCard extends StatefulWidget {
  final MatchDetails match;
  final VoidCallback? onTap;

  const LatestMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  State<LatestMatchCard> createState() => _LatestMatchCardState();
}

class _LatestMatchCardState extends State<LatestMatchCard> {
  bool _showAllEvents = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final match = widget.match;
    final dateFormat = DateFormat('EEE d. MMM', 'da_DK');
    final motm =
        match.matchPollDetails?.playerOfTheMatchDetails.name ?? 'Ingen valgt';
    final events = [...?match.matchEventDetailsList]
      ..sort((a, b) => (b.minute ?? 0).compareTo(a.minute ?? 0));
    final goalCount =
        events.where((event) => event.type == MatchEventType.goal).length;
    final yellowCardCount =
        events.where((event) => event.type == MatchEventType.yellowCard).length;
    final redCardCount =
        events.where((event) => event.type == MatchEventType.redCard).length;

    final score = '${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0}';

    return KopaCard(
      onTap: widget.onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header bar — mirrors MatchHeroCard for a shared match-card language.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: appColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(match.date).toUpperCase(),
                  style: appTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Text(
                    match.location,
                    style: appTextStyles.caption.copyWith(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.lg,
              horizontal: Spacing.md,
            ),
            child: Column(
              children: [
                // Teams + score — same layout as MatchHeroCard.
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TeamColumn(
                        label: match.homeTeam ?? 'Hjemme',
                        alignEnd: false,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            score,
                            style: appTextStyles.pageTitle.copyWith(
                              color: appColors.black,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            match.type,
                            style: appTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _TeamColumn(
                        label: match.awayTeam ?? 'Ude',
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                // Kampens spiller — muted, flat (no sun-yellow fill, no nested box).
                Row(
                  children: [
                    AppAvatar(
                      initials: _getInitials(motm),
                      radius: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kampens spiller',
                            style: appTextStyles.caption.copyWith(
                              color: appColors.textSecondary,
                            ),
                          ),
                          Text(
                            motm,
                            style: appTextStyles.bodyBold.copyWith(
                              color: appColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kamphistorik',
                    style: appTextStyles.caption.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                if (events.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingen hændelser registreret',
                      style: appTextStyles.caption.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MatchEventSummary(
                          icon: Icons.sports_soccer,
                          label: 'Mål',
                          count: goalCount,
                          color: appColors.primary,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _MatchEventSummary(
                          icon: Icons.crop_portrait,
                          label: 'Gule kort',
                          count: yellowCardCount,
                          color: appColors.warning,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _MatchEventSummary(
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
                        textStyle: appTextStyles.caption,
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
                                  _MatchHistoryRow(event: event),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name == 'Ingen valgt') return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _MatchEventSummary extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _MatchEventSummary({
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
        color: appColors.lightSky95.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
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
                style: appTextStyles.bodyBold.copyWith(color: appColors.black),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appTextStyles.caption.copyWith(
              color: appColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryRow extends StatelessWidget {
  final MatchEventDetails event;

  const _MatchHistoryRow({required this.event});

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
              style: appTextStyles.caption.copyWith(
                color: appColors.textSecondary,
              ),
            ),
          ),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              _eventParticipantLabel(event),
              style: appTextStyles.caption.copyWith(color: appColors.dirt),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: appTextStyles.caption.copyWith(
              color: appColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _eventParticipantLabel(MatchEventDetails event) {
    if (event.type == MatchEventType.goal &&
        event.assistMakerUserName != null) {
      return '${event.goalscorerUserName} (Assist: ${event.assistMakerUserName})';
    }

    if (event.type == MatchEventType.substitution) {
      return '${event.goalscorerUserName} ind / ${event.assistMakerUserName ?? '?'} ud';
    }

    return event.goalscorerUserName;
  }
}

class _TeamColumn extends StatelessWidget {
  final String label;
  final bool alignEnd;

  const _TeamColumn({
    required this.label,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        AppAvatar(
          initials: _getInitial(label),
          radius: 30,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: appTextStyles.bodyBold.copyWith(
            color: appColors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getInitial(String teamName) {
    final trimmed = teamName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
