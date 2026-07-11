import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class StandingsPage extends StatelessWidget {
  final DbuStandings? standings;
  final UserDetails currentUser;

  const StandingsPage({
    super.key,
    required this.standings,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final rows = standings?.rows ?? const <DbuStandingRow>[];
    final label = _standingsLabel(standings);

    return PageScaffold(
      title: 'Stilling',
      showBackButton: true,
      backgroundColor: appColors.white,
      body: rows.isEmpty
          ? Center(
              child: Text(
                'Ingen stilling tilgængelig',
                style: appTextStyles.body.copyWith(
                  color: appColors.textSecondary,
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.md,
                    Spacing.md,
                    Spacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyles.h3.copyWith(
                            color: appColors.grass,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          '${rows.length} hold',
                          style: appTextStyles.caption1.copyWith(
                            color: appColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        _StandingsTable(
                          rows: rows,
                          standings: standings,
                          currentUser: currentUser,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  final List<DbuStandingRow> rows;
  final DbuStandings? standings;
  final UserDetails currentUser;

  const _StandingsTable({
    required this.rows,
    required this.standings,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final palette = _StandingsPalette(appColors);
    final relegationBoundary = _relegationBoundary(rows);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _StandingsHeader(compact: compact),
                for (final row in rows) ...[
                  _StandingsRow(
                    row: row,
                    compact: compact,
                    isCurrentTeam: _isCurrentTeam(
                      row,
                      currentUser,
                      standings,
                    ),
                  ),
                  if (row.boundaryAfter != null)
                    _StandingsBoundary(
                      style: row.boundaryAfter!,
                      isRelegation: row.boundaryAfter == 'solid' &&
                          row.position == relegationBoundary,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  int _relegationBoundary(List<DbuStandingRow> rows) {
    final solidBoundaries = rows
        .where((row) => row.boundaryAfter == 'solid')
        .map((row) => row.position)
        .toList();

    if (solidBoundaries.length > 1) return solidBoundaries.last;
    return solidBoundaries.firstWhere(
      (position) => position > rows.length / 2,
      orElse: () => -1,
    );
  }
}

class _StandingsHeader extends StatelessWidget {
  final bool compact;

  const _StandingsHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final style = appTextStyles.label.copyWith(
      color: appColors.white,
      fontSize: compact ? 10 : null,
      fontWeight: FontWeight.w900,
    );

    return Container(
      height: 44,
      color: appColors.grass,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : Spacing.sm),
      child: Row(
        children: [
          _HeaderCell('#', width: compact ? 24 : 32, style: style),
          Expanded(child: Text('Hold', style: style)),
          _HeaderCell('K', width: compact ? 24 : 34, style: style),
          _HeaderCell('V', width: compact ? 24 : 34, style: style),
          _HeaderCell('U', width: compact ? 24 : 34, style: style),
          _HeaderCell('T', width: compact ? 24 : 34, style: style),
          _HeaderCell('M', width: compact ? 38 : 54, style: style),
          _HeaderCell('+/-', width: compact ? 30 : 40, style: style),
          _HeaderCell(
            'P',
            width: compact ? 28 : 36,
            style: style,
            alignEnd: true,
          ),
        ],
      ),
    );
  }
}

class _StandingsRow extends StatelessWidget {
  final DbuStandingRow row;
  final bool compact;
  final bool isCurrentTeam;

  const _StandingsRow({
    required this.row,
    required this.compact,
    required this.isCurrentTeam,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _StandingsPalette(appColors);
    final color = isCurrentTeam ? appColors.primary : appColors.textPrimary;
    final goalDifference = row.goalsFor - row.goalsAgainst;
    final weight = isCurrentTeam ? FontWeight.w900 : FontWeight.w600;

    final teamStyle =
        (compact ? appTextStyles.caption2 : appTextStyles.caption1).copyWith(
      color: color,
      fontWeight: weight,
    );

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 48 : 54),
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : Spacing.sm),
      decoration: BoxDecoration(
        color: isCurrentTeam ? appColors.lightGrass : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: palette.outline),
        ),
      ),
      child: Row(
        children: [
          _ValueCell(
            '${row.position}.',
            width: compact ? 24 : 32,
            compact: compact,
            color: color,
            weight: weight,
          ),
          Expanded(
            child: TeamBadgeLabel(
              teamName: row.teamName,
              teamId: row.dbuTeamId,
              colorSourceUrl: row.logoUrl,
              radius: 11,
              showAvatar: !compact,
              badgePadding: 5,
              labelStyle: teamStyle,
              layout: TeamBadgeLabelLayout.horizontal,
            ),
          ),
          _ValueCell(
            '${row.matchesPlayed}',
            width: compact ? 24 : 34,
            compact: compact,
          ),
          _ValueCell(
            '${row.wins}',
            width: compact ? 24 : 34,
            compact: compact,
          ),
          _ValueCell(
            '${row.draws}',
            width: compact ? 24 : 34,
            compact: compact,
          ),
          _ValueCell(
            '${row.losses}',
            width: compact ? 24 : 34,
            compact: compact,
          ),
          _ValueCell(
            '${row.goalsFor}-${row.goalsAgainst}',
            width: compact ? 38 : 54,
            compact: compact,
          ),
          _ValueCell(
            goalDifference > 0 ? '+$goalDifference' : '$goalDifference',
            width: compact ? 30 : 40,
            compact: compact,
          ),
          _ValueCell(
            '${row.points}',
            width: compact ? 28 : 36,
            compact: compact,
            color: color,
            weight: FontWeight.w900,
            alignEnd: true,
          ),
        ],
      ),
    );
  }
}

class _StandingsBoundary extends StatelessWidget {
  final String style;
  final bool isRelegation;

  const _StandingsBoundary({
    required this.style,
    required this.isRelegation,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      height: Spacing.sm,
      width: double.infinity,
      child: CustomPaint(
        painter: _BoundaryLinePainter(
          color: isRelegation ? appColors.error : appColors.success,
          dotted: style == 'dotted',
        ),
      ),
    );
  }
}

class _BoundaryLinePainter extends CustomPainter {
  final Color color;
  final bool dotted;

  const _BoundaryLinePainter({
    required this.color,
    required this.dotted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dashWidth = 6.0;
    const dashGap = 5.0;
    final y = size.height / 2;
    final lineEnd = size.width - Spacing.sm;

    if (!dotted) {
      canvas.drawLine(Offset(Spacing.sm, y), Offset(lineEnd, y), paint);
      return;
    }

    for (double x = Spacing.sm; x < lineEnd;) {
      final end = (x + dashWidth).clamp(0.0, lineEnd);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _BoundaryLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dotted != dotted;
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final TextStyle style;
  final bool alignEnd;

  const _HeaderCell(
    this.label, {
    required this.width,
    required this.style,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: alignEnd ? TextAlign.right : TextAlign.center,
        style: style,
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String value;
  final double width;
  final bool compact;
  final Color? color;
  final FontWeight weight;
  final bool alignEnd;

  const _ValueCell(
    this.value, {
    required this.width,
    required this.compact,
    this.color,
    this.weight = FontWeight.w600,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      width: width,
      child: Text(
        value,
        textAlign: alignEnd ? TextAlign.right : TextAlign.center,
        style: (compact ? appTextStyles.caption3 : appTextStyles.caption1)
            .copyWith(
          color: color ?? appColors.textSecondary,
          fontWeight: weight,
        ),
      ),
    );
  }
}

class _StandingsPalette {
  final AppColors colors;

  const _StandingsPalette(this.colors);

  Color get outline => colors.grass.withValues(alpha: 0.16);
}

String _standingsLabel(DbuStandings? standings) {
  if (standings?.seriesName?.trim().isNotEmpty == true) {
    return standings!.seriesName!.trim();
  }
  if (standings?.poolId == null) return 'Serie';
  return 'Serie ${standings!.poolId}';
}

bool _isCurrentTeam(
  DbuStandingRow row,
  UserDetails currentUser,
  DbuStandings? standings,
) {
  final currentTeamId = standings?.currentTeamId;
  if (currentTeamId != null && row.dbuTeamId == currentTeamId) {
    return true;
  }

  final currentTeamName = _normalizeTeamName(currentUser.teamDetails?.title);
  if (currentTeamName == null) return false;

  return _normalizeTeamName(row.teamName) == currentTeamName;
}

String? _normalizeTeamName(String? name) {
  final normalized = name?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
