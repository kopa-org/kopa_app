import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/theme/app_text_styles.dart';

// Brand colours (kopa_brand) plus the few deeper shades the slides need so
// small text keeps its contrast.
const _jord = WrappedPalette.jord;
const _graes = WrappedPalette.graes;
const _lysGraes = WrappedPalette.lysGraes;
const _himmel = WrappedPalette.himmel;
const _lysHimmel = WrappedPalette.lysHimmel;
const _sol = WrappedPalette.sol;
const _solnedgang = WrappedPalette.solnedgang;
const _offWhite = WrappedPalette.offWhite;
const _deepHimmel = WrappedPalette.deepHimmel;
const _deepGraes = WrappedPalette.deepGraes;
const _cream = WrappedPalette.cream;
const _night = WrappedPalette.night;
const _lanternRed = WrappedPalette.lanternRed;
const _muted = WrappedPalette.muted;

/// One full-screen slide of the Season Wrapped story.
class WrappedSlide extends StatelessWidget {
  final String slide;
  final SeasonWrapped wrapped;
  final int currentUserId;

  /// Wraps the shareable award card on the last slide.
  final GlobalKey? shareKey;
  final VoidCallback? onShare;
  final VoidCallback? onContinue;

  const WrappedSlide({
    super.key,
    required this.slide,
    required this.wrapped,
    required this.currentUserId,
    this.shareKey,
    this.onShare,
    this.onContinue,
  });

  /// Slides drawn on a dark background get light progress bars and icons.
  static bool isDark(String slide) =>
      const {'intro', 'you', 'motm', 'fines', 'lantern'}.contains(slide);

  static Color background(String slide) => switch (slide) {
        'intro' => _himmel,
        'team' => _lysGraes,
        'you' => _deepHimmel,
        'form' => _lysHimmel,
        'goals' => _sol,
        'assists' => _solnedgang,
        'motm' => _jord,
        'iron' => _offWhite,
        'fines' => _deepGraes,
        'cards' => _cream,
        'lantern' => _night,
        _ => _lysGraes,
      };

  @override
  Widget build(BuildContext context) {
    final content = switch (slide) {
      'intro' => _IntroSlide(wrapped: wrapped),
      'team' => _TeamSlide(wrapped: wrapped),
      'you' => _YouSlide(wrapped: wrapped),
      'form' => _FormSlide(wrapped: wrapped, currentUserId: currentUserId),
      'goals' => _GoalsSlide(wrapped: wrapped, currentUserId: currentUserId),
      'assists' => _AssistsSlide(wrapped: wrapped),
      'motm' => _MotmSlide(wrapped: wrapped),
      'iron' => _IronSlide(wrapped: wrapped),
      'fines' => _FinesSlide(wrapped: wrapped),
      'cards' => _CardsSlide(wrapped: wrapped),
      'lantern' => _LanternSlide(wrapped: wrapped),
      _ => _OutroSlide(
          wrapped: wrapped,
          shareKey: shareKey,
          onShare: onShare,
          onContinue: onContinue,
        ),
    };

    return SizedBox.expand(
      child: ColoredBox(
        color: background(slide),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 72, 28, 32),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(slide),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - t)),
                  child: child,
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

// -- shared pieces --------------------------------------------------------------

TextStyle _style(BuildContext context) =>
    (Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light)
        .h2
        .copyWith(height: 1.05);

class _Eyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const _Eyebrow(this.text, {this.color = _jord});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: _style(context).copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: color,
        ),
      );
}

class _Headline extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const _Headline(this.text, {this.color = _jord, this.size = 52});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: _style(context).copyWith(
          fontSize: size,
          height: 0.95,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: color,
        ),
      );
}

class _Line extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final FontWeight weight;

  const _Line(
    this.text, {
    this.color = _jord,
    this.size = 20,
    this.weight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: _style(context).copyWith(
          fontSize: size,
          height: 1.3,
          fontWeight: weight,
          color: color,
        ),
      );
}

class _BigNumber extends StatelessWidget {
  final String value;
  final String? suffix;
  final Color color;
  final Color? suffixColor;
  final double size;

  const _BigNumber(
    this.value, {
    this.suffix,
    this.color = _jord,
    this.suffixColor,
    this.size = 128,
  });

  @override
  Widget build(BuildContext context) {
    final base = _style(context).copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -3,
      height: 0.9,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: value,
              style: base.copyWith(fontSize: size, color: color),
            ),
            if (suffix != null)
              TextSpan(
                text: suffix,
                style: base.copyWith(
                  fontSize: size * 0.38,
                  letterSpacing: 0,
                  color: suffixColor ?? color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color color;
  final Color labelColor;

  const _StatTile({
    required this.value,
    required this.label,
    required this.background,
    required this.color,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: _style(context).copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style(context).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      );
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color background;
  final Color foreground;

  const _Avatar(
    this.name, {
    this.size = 56,
    this.background = _graes,
    this.foreground = WrappedPalette.white,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.isEmpty ? '?' : parts.first.substring(0, 1);
    final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: _jord, width: 3),
        ),
        child: Text(
          _initials,
          style: _style(context).copyWith(
            fontSize: size * 0.32,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      );
}

class _Mascot extends StatelessWidget {
  final String asset;
  final Color color;
  final double height;
  final double angle;

  const _Mascot(
    this.asset, {
    required this.color,
    this.height = 200,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          'assets/illustrations/$asset.svg',
          height: height,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
}

String _name(WrappedPlayer player) => player.shortName;

// -- slides -----------------------------------------------------------------------

class _IntroSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _IntroSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = [wrapped.team.title, wrapped.seasonName]
        .where((part) => part.isNotEmpty)
        .join(' · ');

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -150,
          top: 60,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WrappedPalette.white.withValues(alpha: 0.22),
                width: 2,
              ),
            ),
          ),
        ),
        const Positioned(
          right: 0,
          bottom: 70,
          child: _Mascot(
            'kopa_flag',
            color: WrappedPalette.white,
            height: 200,
            angle: -0.14,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _sol,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label.toUpperCase(),
                style: _style(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: _jord,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _Headline(l10n.wrappedIntroTitle,
                color: WrappedPalette.white, size: 64),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: _Line(
                l10n.wrappedIntroBody(
                  wrapped.team.played,
                  wrapped.team.goalsFor,
                ),
                color: WrappedPalette.white,
                size: 18,
                weight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _Line(
              l10n.wrappedTapToContinue,
              color: WrappedPalette.white,
              size: 14,
            ),
          ],
        ),
      ],
    );
  }
}

class _TeamSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _TeamSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = wrapped.team;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedTeamEyebrow),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BigNumber('${team.wins}', size: 150),
            const SizedBox(width: 14),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Line(
                  l10n.wrappedTeamWinsLabel(team.played),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Line(
          l10n.wrappedTeamDrawsLosses(team.draws, team.losses),
          color: _muted,
          size: 17,
          weight: FontWeight.w700,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${team.goalsFor}',
                label: l10n.wrappedGoalsFor,
                background: WrappedPalette.white,
                color: _jord,
                labelColor: WrappedPalette.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                value: '${team.goalsAgainst}',
                label: l10n.wrappedGoalsAgainst,
                background: WrappedPalette.white,
                color: _jord,
                labelColor: WrappedPalette.textSecondary,
              ),
            ),
          ],
        ),
        if (team.form.isNotEmpty) ...[
          const SizedBox(height: 28),
          _Line(l10n.wrappedLastFive, size: 13),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final result in team.form) ...[
                _FormDot(result: result),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
        const Spacer(),
        if (team.bestWinStreak >= 2)
          _Line(l10n.wrappedBestStreak(team.bestWinStreak)),
      ],
    );
  }
}

class _FormDot extends StatelessWidget {
  final String result;

  const _FormDot({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, background, foreground) = switch (result) {
      'W' => (l10n.wrappedFormWin, _graes, WrappedPalette.white),
      'D' => (l10n.wrappedFormDraw, _sol, _jord),
      _ => (l10n.wrappedFormLoss, WrappedPalette.loss, WrappedPalette.white),
    };

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        label,
        style: _style(context).copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _YouSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _YouSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final me = wrapped.me;
    final tile = WrappedPalette.white.withValues(alpha: 0.14);
    final ahead = me.playersWithMoreMatches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedYouEyebrow(me.firstName), color: _lysHimmel),
        const SizedBox(height: 18),
        _BigNumber(
          '${me.matchesPlayed}',
          suffix: '/${wrapped.team.played}',
          color: WrappedPalette.white,
          suffixColor: _lysHimmel,
        ),
        const SizedBox(height: 8),
        _Line(l10n.wrappedMatchesPlayed, color: WrappedPalette.white, size: 22),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${me.goals}',
                label: l10n.wrappedGoals,
                background: tile,
                color: WrappedPalette.white,
                labelColor: WrappedPalette.lightSkyText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '${me.assists}',
                label: l10n.wrappedAssists,
                background: tile,
                color: WrappedPalette.white,
                labelColor: WrappedPalette.lightSkyText,
              ),
            ),
            if (me.trainingPercentage > 0) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${me.trainingPercentage.round()}%',
                  label: l10n.wrappedTraining,
                  background: tile,
                  color: WrappedPalette.white,
                  labelColor: WrappedPalette.lightSkyText,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        if (me.matchesPlayed > 0 && ahead == 0)
          _Line(l10n.wrappedYouTopAttendance, color: WrappedPalette.white)
        else if (me.matchesPlayed > 0 && ahead <= 2)
          _Line(l10n.wrappedYouMoreMatches(ahead), color: WrappedPalette.white),
      ],
    );
  }
}

class _FormSlide extends StatelessWidget {
  final SeasonWrapped wrapped;
  final int currentUserId;

  const _FormSlide({required this.wrapped, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final awards = wrapped.awards;
    final me = awards.formMe;
    final rows = awards.form.take(4).toList();
    if (me != null && !rows.any((row) => row.userId == me.userId)) {
      rows
        ..removeLast()
        ..add(me);
    }
    final leader = awards.form.isEmpty ? null : awards.form.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedFormEyebrow),
        const SizedBox(height: 18),
        if (me?.rank != null) ...[
          _Line(l10n.wrappedFormYouFinished, size: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BigNumber('#${me!.rank}', size: 140),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Line(
                  l10n.wrappedFormOfPlayers(wrapped.me.formPlayers),
                ),
              ),
            ],
          ),
        ] else if (leader != null)
          _Headline(l10n.wrappedFormWinner(_name(leader)), size: 44),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: WrappedPalette.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (final row in rows)
                _LeaderboardRow(
                  rank: row.rank ?? 0,
                  name: row.userId == currentUserId
                      ? '${_name(row)} ${l10n.wrappedYouSuffix}'
                      : _name(row),
                  value: NumberFormat.decimalPattern(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(row.value),
                  highlighted: row.userId == currentUserId,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final bool highlighted;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.value,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? _lysGraes : _jord;
    final style = _style(context).copyWith(
      fontSize: highlighted ? 16 : 15,
      fontWeight: highlighted ? FontWeight.w800 : FontWeight.w700,
      color: color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: highlighted
          ? BoxDecoration(color: _jord, borderRadius: BorderRadius.circular(14))
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$rank · $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _GoalsSlide extends StatelessWidget {
  final SeasonWrapped wrapped;
  final int currentUserId;

  const _GoalsSlide({required this.wrapped, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.goals;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final teamGoals = math.max(wrapped.awards.teamGoals, 1);
    final percent = (king.value / teamGoals * 100).round();

    // Second place left, winner in the middle, third right.
    final order = [
      if (podium.length > 1) (podium[1], 150.0, _himmel, WrappedPalette.white),
      (king, 210.0, _graes, WrappedPalette.white),
      if (podium.length > 2) (podium[2], 110.0, _solnedgang, _jord),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_outlined, size: 18, color: _jord),
            const SizedBox(width: 8),
            _Eyebrow(l10n.wrappedGoalsEyebrow),
          ],
        ),
        const SizedBox(height: 16),
        _Headline(_name(king)),
        const SizedBox(height: 10),
        _Line(l10n.wrappedGoalsLine(king.value.toInt(), percent)),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (player, height, color, foreground) in order) ...[
              Expanded(
                child: _PodiumColumn(
                  name: player.userId == currentUserId
                      ? '${_name(player)} ${l10n.wrappedYouSuffix}'
                      : _name(player),
                  fullName: player.name,
                  value: player.value.toInt(),
                  unit: l10n.wrappedGoals,
                  height: height,
                  avatarColor: color,
                  avatarForeground: foreground,
                  crowned: player == king,
                ),
              ),
              if (player != order.last.$1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final String name;
  final String fullName;
  final int value;
  final String unit;
  final double height;
  final Color avatarColor;
  final Color avatarForeground;
  final bool crowned;

  const _PodiumColumn({
    required this.name,
    required this.fullName,
    required this.value,
    required this.unit,
    required this.height,
    required this.avatarColor,
    required this.avatarForeground,
    required this.crowned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (crowned)
          const Icon(Icons.workspace_premium_rounded, size: 30, color: _jord),
        _Avatar(
          fullName,
          size: crowned ? 68 : 56,
          background: avatarColor,
          foreground: avatarForeground,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(context).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _jord,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 14),
          decoration: const BoxDecoration(
            color: _jord,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: _style(context).copyWith(
                  fontSize: crowned ? 44 : 34,
                  fontWeight: FontWeight.w800,
                  color: _sol,
                ),
              ),
              Text(
                unit,
                style: _style(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: WrappedPalette.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssistsSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _AssistsSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.assists;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final duo = wrapped.awards.duo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedAssistsEyebrow),
        const SizedBox(height: 16),
        _Headline(_name(king)),
        const SizedBox(height: 10),
        _Line(l10n.wrappedAssistsLine(king.value.toInt())),
        const SizedBox(height: 28),
        // Without a repeat assist-to-scorer pair the heart mascot fills in,
        // so the slide never ends up as a bare title.
        if (duo == null)
          const Expanded(
            child: Center(
              child: _Mascot('kopa_heart', color: _jord, height: 150),
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _jord,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(l10n.wrappedDuoTitle, color: _solnedgang),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DuoPerson(name: duo.fromName, color: _solnedgang),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 32,
                        color: _solnedgang,
                      ),
                    ),
                    _DuoPerson(name: duo.toName, color: _graes),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: _Line(
                    l10n.wrappedDuoGoals(duo.goals),
                    color: WrappedPalette.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
        _AssistBars(players: podium),
      ],
    );
  }
}

/// "Most assists": the top three as bars, scaled to the assist king.
class _AssistBars extends StatelessWidget {
  final List<WrappedPlayer> players;

  const _AssistBars({required this.players});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final best = math.max(players.first.value, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Eyebrow(l10n.wrappedAssistsLeaders),
        const SizedBox(height: 12),
        for (final (index, player) in players.take(3).indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                _Avatar(
                  player.name,
                  size: 44,
                  background: index == 0 ? _jord : WrappedPalette.white,
                  foreground: index == 0 ? _solnedgang : _jord,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name(player),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _jord,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) => Stack(
                          children: [
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: _jord.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            Container(
                              height: 10,
                              width: constraints.maxWidth *
                                  (player.value / best).clamp(0.06, 1.0),
                              decoration: BoxDecoration(
                                color: _jord,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${player.value.toInt()}',
                  style: _style(context).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _jord,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DuoPerson extends StatelessWidget {
  final String name;
  final Color color;

  const _DuoPerson({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final short = WrappedPlayer(userId: 0, name: name, value: 0).shortName;
    return Column(
      children: [
        _Avatar(
          name,
          size: 64,
          background: color,
          foreground: color == _solnedgang ? _jord : WrappedPalette.white,
        ),
        const SizedBox(height: 6),
        Text(
          short,
          style: _style(context).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: WrappedPalette.white,
          ),
        ),
      ],
    );
  }
}

class _MotmSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _MotmSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.motm;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final matchIds = wrapped.team.matchIds;
    final won = king.eventIds.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedMotmEyebrow, color: _sol),
        const SizedBox(height: 16),
        _Headline(_name(king), color: WrappedPalette.white),
        const SizedBox(height: 10),
        _Line(l10n.wrappedMotmLine(king.value.toInt()), color: _sol),
        const Spacer(),
        const Center(
          child: _Mascot('kopa_thumb', color: _lysGraes, height: 180),
        ),
        const Spacer(),
        if (matchIds.isNotEmpty) ...[
          _Line(
            l10n.wrappedSeasonMatches(matchIds.length),
            color: WrappedPalette.white,
            size: 13,
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final id in matchIds) ...[
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: won.contains(id)
                          ? _sol
                          : WrappedPalette.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (id != matchIds.last) const SizedBox(width: 5),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _IronSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _IronSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.iron;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final played = wrapped.team.played;
    final value = king.value.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedIronEyebrow),
        const SizedBox(height: 16),
        _Headline(_name(king)),
        const SizedBox(height: 22),
        _BigNumber(
          '$value',
          suffix: '/$played',
          color: _graes,
          suffixColor: _jord,
        ),
        const SizedBox(height: 8),
        _Line(
          value >= played ? l10n.wrappedIronAll : l10n.wrappedIronMost,
          size: 22,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < played; i++)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: i < value ? _graes : WrappedPalette.inactive,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FinesSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _FinesSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.fines;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedFinesEyebrow, color: _lysGraes),
        const SizedBox(height: 16),
        _Headline(_name(king), color: WrappedPalette.white),
        const SizedBox(height: 22),
        _BigNumber(
          number.format(king.value.round()),
          suffix: ' kr.',
          color: _sol,
          suffixColor: WrappedPalette.white,
          size: 112,
        ),
        const SizedBox(height: 10),
        _Line(
          l10n.wrappedFinesLine,
          color: WrappedPalette.mintText,
          size: 18,
          weight: FontWeight.w700,
        ),
        if (podium.length > 1) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: WrappedPalette.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (final (index, player) in podium.skip(1).indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Line(
                            '${index + 2} · ${_name(player)}',
                            color: WrappedPalette.white,
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                        _Line(
                          '${number.format(player.value.round())} kr.',
                          color: WrappedPalette.white,
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const Spacer(),
        _Line(
          l10n.wrappedFinesTotal(
            '${number.format(wrapped.awards.finesTotal.round())} kr.',
          ),
          color: WrappedPalette.white,
        ),
      ],
    );
  }
}

class _CardsSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _CardsSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final podium = wrapped.awards.cards;
    if (podium.isEmpty) return const SizedBox.shrink();
    final king = podium.first;
    final cards = [
      for (var i = 0; i < math.min(king.yellow, 5); i++) _sol,
      for (var i = 0; i < math.min(king.red, 2); i++) _lanternRed,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedCardsEyebrow),
        const SizedBox(height: 16),
        _Headline(_name(king)),
        const SizedBox(height: 10),
        _Line(l10n.wrappedCardsLine(king.yellow, king.red)),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 300,
              height: 240,
              child: Stack(
                children: [
                  for (final (index, color) in cards.indexed)
                    Positioned(
                      left: 20.0 + index * (160 / math.max(cards.length, 1)),
                      top: 30,
                      child: Transform.rotate(
                        angle: -0.3 + index * (0.6 / math.max(cards.length, 1)),
                        child: Container(
                          width: 110,
                          height: 156,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _jord, width: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        _Line(l10n.wrappedCardsFooter),
      ],
    );
  }
}

class _LanternSlide extends StatelessWidget {
  final SeasonWrapped wrapped;

  const _LanternSlide({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final last = wrapped.awards.lantern;
    if (last == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(l10n.wrappedLanternEyebrow,
            color: WrappedPalette.lanternLabel),
        const SizedBox(height: 16),
        _Headline(_name(last), color: WrappedPalette.white),
        const SizedBox(height: 10),
        _Line(
          l10n.wrappedLanternLine(
            last.rank ?? wrapped.awards.lanternPlayers,
            wrapped.awards.lanternPlayers,
          ),
          color: WrappedPalette.lanternLight,
        ),
        const Expanded(child: Center(child: _Lantern())),
        _Line(l10n.wrappedLanternFooter, color: WrappedPalette.white),
      ],
    );
  }
}

class _Lantern extends StatelessWidget {
  const _Lantern();

  @override
  Widget build(BuildContext context) {
    const outline = WrappedPalette.lanternLight;
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  WrappedPalette.lanternGlow,
                  WrappedPalette.lanternGlowEnd
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 4, height: 20, color: outline),
              Container(
                width: 56,
                height: 18,
                decoration: BoxDecoration(
                  color: _jord,
                  border: Border.all(color: outline, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 64,
                height: 100,
                decoration: BoxDecoration(
                  color: _lanternRed,
                  border: Border.all(color: outline, width: 3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: _sol,
                  size: 40,
                ),
              ),
              Container(
                width: 56,
                height: 16,
                decoration: BoxDecoration(
                  color: _jord,
                  border: Border.all(color: outline, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutroSlide extends StatelessWidget {
  final SeasonWrapped wrapped;
  final GlobalKey? shareKey;
  final VoidCallback? onShare;
  final VoidCallback? onContinue;

  const _OutroSlide({
    required this.wrapped,
    this.shareKey,
    this.onShare,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final awards = wrapped.awards;
    final slides = wrapped.slides;
    // Only the positive awards go on the shareable card.
    final rows = <(String, String)>[
      if (slides.contains('goals') && awards.goals.isNotEmpty)
        (
          l10n.wrappedGoalsEyebrow,
          '${awards.goals.first.shortName} · ${awards.goals.first.value.toInt()}'
        ),
      if (slides.contains('assists') && awards.assists.isNotEmpty)
        (
          l10n.wrappedAssistsEyebrow,
          '${awards.assists.first.shortName} · ${awards.assists.first.value.toInt()}'
        ),
      if (slides.contains('motm') && awards.motm.isNotEmpty)
        (
          l10n.wrappedMotmEyebrow,
          '${awards.motm.first.shortName} · ${awards.motm.first.value.toInt()}×'
        ),
      if (slides.contains('iron') && awards.iron.isNotEmpty)
        (
          l10n.wrappedIronEyebrow,
          '${awards.iron.first.shortName} · ${awards.iron.first.value.toInt()}/${wrapped.team.played}'
        ),
    ];
    final label = [wrapped.team.title, wrapped.seasonName]
        .where((part) => part.isNotEmpty)
        .join(' · ');
    final team = wrapped.team;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(
          key: shareKey,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: _himmel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Eyebrow(label, color: _sol),
                          const SizedBox(height: 6),
                          _Headline(
                            l10n.wrappedOutroTitle,
                            color: WrappedPalette.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    const _Mascot(
                      'kopa_heart',
                      color: WrappedPalette.white,
                      height: 56,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OutroRow(
                  label: l10n.wrappedTeamEyebrow,
                  value: '${team.wins}-${team.draws}-${team.losses} · '
                      '${team.goalsFor}-${team.goalsAgainst}',
                  divider: rows.isNotEmpty,
                ),
                for (final (index, (label, value)) in rows.indexed)
                  _OutroRow(
                    label: label,
                    value: value,
                    divider: index < rows.length - 1,
                  ),
                if (wrapped.slides.contains('you')) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _deepHimmel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Line(
                            l10n.wrappedOutroYou,
                            color: WrappedPalette.white,
                            size: 14,
                            weight: FontWeight.w700,
                          ),
                        ),
                        _Line(
                          l10n.wrappedOutroYouLine(
                            wrapped.me.goals,
                            wrapped.me.assists,
                          ),
                          color: WrappedPalette.white,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          key: const ValueKey('wrapped_share'),
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_rounded),
          label: Text(l10n.wrappedShare),
          style: OutlinedButton.styleFrom(
            foregroundColor: _jord,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: _jord, width: 2),
            shape: const StadiumBorder(),
            textStyle: _style(context).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const ValueKey('wrapped_continue'),
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward_rounded),
          iconAlignment: IconAlignment.end,
          label: Text(l10n.wrappedContinue),
          style: FilledButton.styleFrom(
            backgroundColor: _jord,
            foregroundColor: WrappedPalette.white,
            minimumSize: const Size.fromHeight(56),
            shape: const StadiumBorder(),
            textStyle: _style(context).copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _OutroRow extends StatelessWidget {
  final String label;
  final String value;
  final bool divider;

  const _OutroRow({
    required this.label,
    required this.value,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: WrappedPalette.white.withValues(alpha: 0.25),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: _Line(
              label,
              color: WrappedPalette.white,
              size: 15,
              weight: FontWeight.w600,
            ),
          ),
          _Line(value, color: WrappedPalette.white, size: 15),
        ],
      ),
    );
  }
}

/// Exposed for the settings sheet: the title of each optional category.
String wrappedCategoryTitle(AppLocalizations l10n, String key) => switch (key) {
      'form' => l10n.wrappedFormEyebrow,
      'goals' => l10n.wrappedGoalsEyebrow,
      'assists' => l10n.wrappedAssistsEyebrow,
      'motm' => l10n.wrappedMotmEyebrow,
      'iron' => l10n.wrappedIronEyebrow,
      'fines' => l10n.wrappedFinesEyebrow,
      'cards' => l10n.wrappedCardsEyebrow,
      'lantern' => l10n.wrappedLanternEyebrow,
      _ => key,
    };

/// Brand colours of the Wrapped, for widgets outside this file.
abstract final class WrappedColors {
  static const jord = _jord;
  static const himmel = _himmel;
  static const sol = _sol;

  static Color chrome(String slide) =>
      WrappedSlide.isDark(slide) ? WrappedPalette.white : _jord;
}
