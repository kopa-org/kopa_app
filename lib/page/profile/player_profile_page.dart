import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/player_profile.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PlayerProfilePage extends StatelessWidget {
  final UserDetails player;

  const PlayerProfilePage({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return PageScaffold(
      title: player.name,
      showBackButton: true,
      backgroundColor: _ProfileColors.background,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: _ProfileColors.background,
        systemNavigationBarColor: appColors.surface,
      ),
      body: FutureHandler<PlayerProfile>(
        future: UsersRepository.getPlayerProfile(player.id),
        onSuccess: (context, profile) => _PlayerProfileView(profile: profile),
      ),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  final PlayerProfile profile;

  const _PlayerProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(Spacing.md, 12, Spacing.md, 120),
      children: [
        _PlayerHero(profile: profile),
        const SizedBox(height: 20),
        _StatsRow(summary: profile.playerPlusSummary),
        const SizedBox(height: 22),
        const _MatchHistoryHeader(),
        const SizedBox(height: 12),
        _MatchHistoryCard(matches: profile.matchHistory),
      ],
    );
  }
}

class _PlayerHero extends StatelessWidget {
  final PlayerProfile profile;

  const _PlayerHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final position = profile.bio.position ?? profile.player.position;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _PlayerAvatar(name: profile.player.name, size: 64, fontSize: 22),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.h5.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: Spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _metaPosition(position),
                      style: styles.body3.copyWith(
                        color: appColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '•',
                      style: styles.body3.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Nr. -',
                      style: styles.body3.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metaPosition(String? position) {
    final value = position?.trim();
    if (value == null || value.isEmpty) return 'Spiller';
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;

  const _PlayerAvatar({
    required this.name,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appColors.lightGrass65,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: styles.h5.copyWith(
          color: appColors.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }
}

class _StatsRow extends StatelessWidget {
  final PlayerPlusSummary summary;

  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.show_chart,
            label: 'Kampe',
            value: '${summary.matchesPlayed}',
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.flag_outlined,
            label: 'Mål',
            value: '${summary.goalsScored}',
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.handshake,
            label: 'Assists',
            value: '${summary.assists}',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfileColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: appColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.caption2.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: styles.h4.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryHeader extends StatelessWidget {
  const _MatchHistoryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Text(
      'Kamphistorik',
      style: styles.h5.copyWith(
        color: appColors.dirt,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MatchHistoryCard extends StatelessWidget {
  final List<PlayerMatchHistoryItem> matches;

  const _MatchHistoryCard({required this.matches});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    if (matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(appColors),
        child: Text(
          'Ingen kampe fundet.',
          style: styles.body3.copyWith(color: appColors.textSecondary),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(appColors),
      child: Column(
        children: [
          for (final group in _seasonGroups(matches)) ...[
            _SeasonDivider(group: group),
            for (var index = 0; index < group.matches.length; index++)
              _MatchHistoryRow(
                match: group.matches[index],
                showDivider: index < group.matches.length - 1,
              ),
          ],
        ],
      ),
    );
  }

  List<_SeasonGroup> _seasonGroups(List<PlayerMatchHistoryItem> matches) {
    final groups = <_SeasonGroup>[];

    for (final match in matches) {
      final label = _seasonLabel(match);
      if (groups.isEmpty || groups.last.label != label) {
        groups.add(_SeasonGroup(label: label, matches: [match]));
      } else {
        groups.last.matches.add(match);
      }
    }

    return groups;
  }

  String _seasonLabel(PlayerMatchHistoryItem match) {
    final season = match.seasonName?.trim();
    if (season != null && season.isNotEmpty) return season;
    return 'Sæson ${match.date.year}';
  }

  BoxDecoration _cardDecoration(AppColors appColors) {
    return BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _ProfileColors.border, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _SeasonGroup {
  final String label;
  final List<PlayerMatchHistoryItem> matches;

  _SeasonGroup({
    required this.label,
    required this.matches,
  });
}

class _SeasonDivider extends StatelessWidget {
  final _SeasonGroup group;

  const _SeasonDivider({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: appColors.offWhite,
        border: Border(
          bottom: BorderSide(color: _ProfileColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              group.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.caption2.copyWith(
                color: appColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '${group.matches.length} ${group.matches.length == 1 ? 'kamp' : 'kampe'}',
            style: styles.caption3.copyWith(
              color: appColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryRow extends StatelessWidget {
  final PlayerMatchHistoryItem match;
  final bool showDivider;

  const _MatchHistoryRow({
    required this.match,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 75),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: _ProfileColors.border))
            : null,
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DatePill(date: match.date),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _MatchIndicators(match: match),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _HistoryTeams(match: match),
        ],
      ),
    );
  }
}

class _HistoryTeams extends StatelessWidget {
  final PlayerMatchHistoryItem match;

  const _HistoryTeams({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HistoryTeamScoreLine(
          name: match.homeTeam,
          score: match.homeTeamScore,
          isOwnTeam: match.isHomeTeam,
        ),
        const SizedBox(height: 8),
        _HistoryTeamScoreLine(
          name: match.awayTeam,
          score: match.awayTeamScore,
          isOwnTeam: !match.isHomeTeam,
        ),
      ],
    );
  }
}

class _HistoryTeamScoreLine extends StatelessWidget {
  final String name;
  final int? score;
  final bool isOwnTeam;

  const _HistoryTeamScoreLine({
    required this.name,
    required this.score,
    required this.isOwnTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HistoryTeamLine(
            name: name,
            isOwnTeam: isOwnTeam,
          ),
        ),
        const SizedBox(width: 12),
        _HistoryScore(
          score: score,
          isOwnTeam: isOwnTeam,
        ),
      ],
    );
  }
}

class _HistoryTeamLine extends StatelessWidget {
  final String name;
  final bool isOwnTeam;

  const _HistoryTeamLine({
    required this.name,
    required this.isOwnTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return TeamBadgeLabel(
      teamName: name,
      teamId: stableTeamSeed(name),
      radius: 8,
      badgePadding: 2,
      isHighlighted: isOwnTeam,
      showShadow: false,
      labelStyle: styles.body3.copyWith(
        color: isOwnTeam ? appColors.dirt : appColors.textSecondary,
        fontSize: 15,
        fontWeight: isOwnTeam ? FontWeight.w900 : FontWeight.w600,
      ),
      layout: TeamBadgeLabelLayout.horizontal,
    );
  }
}

class _HistoryScore extends StatelessWidget {
  final int? score;
  final bool isOwnTeam;

  const _HistoryScore({
    required this.score,
    required this.isOwnTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return SizedBox(
      width: 24,
      child: Text(
        score?.toString() ?? '-',
        maxLines: 1,
        textAlign: TextAlign.end,
        style: styles.subtitle2.copyWith(
          color: isOwnTeam ? appColors.dirt : appColors.textSecondary,
          fontWeight: isOwnTeam ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final DateTime date;

  const _DatePill({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.offWhite,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date.day.toString().padLeft(2, '0'),
            style: styles.caption3.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _monthLabel(date.month),
            style: styles.caption3.copyWith(
              color: appColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'maj',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return months[month - 1].toUpperCase();
  }
}

class _MatchIndicators extends StatelessWidget {
  final PlayerMatchHistoryItem match;

  const _MatchIndicators({required this.match});

  @override
  Widget build(BuildContext context) {
    final indicators = <Widget>[
      if (match.goalsCount > 0)
        _CountBadge(icon: '⚽', value: match.goalsCount.toString()),
      if (match.assistsCount > 0)
        _CountBadge(
            iconData: Icons.handshake, value: match.assistsCount.toString()),
      if (match.yellowCardsCount > 0)
        _CardIndicator(color: _ProfileColors.yellowCard),
      if (match.redCardsCount > 0)
        _CardIndicator(color: _ProfileColors.redCard),
      if (match.playerOfTheMatch) const _MotmBadge(),
    ];

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: indicators,
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String value;

  const _CountBadge({
    this.icon,
    this.iconData,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: appColors.lightGrass65,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Text(icon!, style: const TextStyle(fontSize: 12))
          else
            Icon(iconData, size: 12, color: appColors.primary),
          const SizedBox(width: 4),
          Text(
            value,
            style: styles.caption2.copyWith(
              color: appColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotmBadge extends StatelessWidget {
  const _MotmBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.star, size: 12, color: appColors.warning),
          const SizedBox(width: 2),
          Text(
            'MOTM',
            style: styles.caption3.copyWith(
              color: appColors.warning,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardIndicator extends StatelessWidget {
  final Color color;

  const _CardIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

abstract final class _ProfileColors {
  static const background = Color(0xFFF0F2F0);
  static const border = Color(0xFFDCE5E2);
  static const yellowCard = Color(0xFFFFCC00);
  static const redCard = Color(0xFFFF3B30);
}
