import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/standings/standings_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class StandingsPreviewCard extends StatelessWidget {
  final DbuStandings? standings;
  final UserDetails currentUser;

  const StandingsPreviewCard({
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
    final palette = _StandingsPreviewPalette(appColors);
    final allRows = standings?.rows ?? const <DbuStandingRow>[];
    final topRows = allRows.take(3).toList();
    final standingsLabel = _standingsLabel(standings);
    final currentTeamRow = allRows.cast<DbuStandingRow?>().firstWhere(
          (row) => row != null && _isCurrentTeam(row, currentUser, standings),
          orElse: () => null,
        );
    final showCurrentTeamBelow = currentTeamRow != null &&
        !topRows.any((row) => _isSameStandingRow(row, currentTeamRow));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openStandings(context, standings, currentUser),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                color: appColors.lightGrass,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        standingsLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appTextStyles.label.copyWith(
                          color: appColors.dirt,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  children: [
                    const _PreviewTableHeader(),
                    Divider(color: palette.outline),
                    if (topRows.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: Spacing.lg),
                        child: Text(
                          'Ingen stilling tilgængelig',
                          style: appTextStyles.caption1.copyWith(
                            color: palette.onSurfaceMuted,
                          ),
                        ),
                      )
                    else ...[
                      for (final row in topRows)
                        _StandingPreviewRow(
                          row: row,
                          isCurrentTeam: _isCurrentTeam(
                            row,
                            currentUser,
                            standings,
                          ),
                        ),
                      if (showCurrentTeamBelow) ...[
                        _StandingPreviewGap(color: palette.outline),
                        _StandingPreviewRow(
                          row: currentTeamRow,
                          isCurrentTeam: true,
                        ),
                      ],
                    ],
                    const SizedBox(height: Spacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'VIS FULD TABEL',
                        style: appTextStyles.label.copyWith(
                          color: palette.onSurfaceMuted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingPreviewGap extends StatelessWidget {
  final Color color;

  const _StandingPreviewGap({required this.color});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Expanded(child: Divider(color: color)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Text(
              '...',
              style: appTextStyles.caption2.copyWith(color: color),
            ),
          ),
          Expanded(child: Divider(color: color)),
        ],
      ),
    );
  }
}

class _PreviewTableHeader extends StatelessWidget {
  const _PreviewTableHeader();

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _StandingsPreviewPalette(appColors);
    final style = appTextStyles.label.copyWith(
      color: palette.onSurfaceMuted,
      fontWeight: FontWeight.w800,
    );

    return Row(
      children: [
        SizedBox(width: 28, child: Text('#', style: style)),
        const SizedBox(width: 28),
        Expanded(child: Text('Hold', style: style)),
        SizedBox(
          width: 30,
          child: Text('K', style: style, textAlign: TextAlign.center),
        ),
        SizedBox(
          width: 34,
          child: Text('P', style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _StandingPreviewRow extends StatelessWidget {
  final DbuStandingRow row;
  final bool isCurrentTeam;

  const _StandingPreviewRow({
    required this.row,
    required this.isCurrentTeam,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _StandingsPreviewPalette(appColors);
    final color = isCurrentTeam ? appColors.primary : palette.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: isCurrentTeam ? appColors.lightGrass55 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${row.position}.',
              style: appTextStyles.caption2.copyWith(
                color: color,
                fontWeight: isCurrentTeam ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TeamBadgeLabel(
              teamName: row.teamName,
              teamId: row.dbuTeamId,
              colorSourceUrl: row.logoUrl,
              radius: 10,
              labelStyle: appTextStyles.caption2.copyWith(
                color: color,
                fontWeight: isCurrentTeam ? FontWeight.w800 : FontWeight.w500,
              ),
              layout: TeamBadgeLabelLayout.horizontal,
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${row.matchesPlayed}',
              textAlign: TextAlign.center,
              style: appTextStyles.caption2.copyWith(
                color: palette.onSurfaceMuted,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${row.points}',
              textAlign: TextAlign.right,
              style: appTextStyles.caption2.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsPreviewPalette {
  final AppColors colors;

  const _StandingsPreviewPalette(this.colors);

  Color get statCard => colors.grass;
  Color get onSurface => colors.dirt;
  Color get onSurfaceMuted => colors.grey5;
  Color get outline => colors.grey3;
}

void _openStandings(
  BuildContext context,
  DbuStandings? standings,
  UserDetails currentUser,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => StandingsPage(
        standings: standings,
        currentUser: currentUser,
      ),
    ),
  );
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

bool _isSameStandingRow(DbuStandingRow first, DbuStandingRow second) {
  return first.position == second.position &&
      first.teamName.toLowerCase() == second.teamName.toLowerCase();
}

String? _normalizeTeamName(String? name) {
  final normalized = name?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
