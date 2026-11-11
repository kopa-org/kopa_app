import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/profile/dbu_calendar_import_flow.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';

/// Replaces the next-match hero once nothing is left on the schedule.
///
/// Recaps the season just played and tells the team where the next one is:
/// still being looked up, not yet published on DBU ("waiting", with a manual
/// "import anyway" override for team leaders), or found and ready to start.
class SeasonOverHero extends StatefulWidget {
  final List<MatchDetails> matches;
  final UserDetails currentUser;
  final DbuSeasonOutlook? outlook;
  final bool isChecking;

  /// Re-opens the season's Wrapped once it has been seen.
  final VoidCallback? onOpenWrapped;

  const SeasonOverHero({
    super.key,
    required this.matches,
    required this.currentUser,
    required this.outlook,
    required this.isChecking,
    this.onOpenWrapped,
  });

  @override
  State<SeasonOverHero> createState() => _SeasonOverHeroState();
}

class _SeasonOverHeroState extends State<SeasonOverHero> {
  bool _isImporting = false;

  int? get _teamId => widget.currentUser.teamDetails?.id;

  Future<void> _import({
    DbuNextSeasonCandidate? candidate,
    bool skipSuggestion = false,
    required String source,
  }) async {
    if (_isImporting) return;
    AppAnalytics.logEvent('season_over_import', parameters: {'source': source});
    setState(() => _isImporting = true);

    try {
      final message = await DbuCalendarImportFlow.run(
        context,
        teamId: _teamId,
        startNewSeason: true,
        candidate: candidate,
        skipSuggestion: skipSuggestion,
      );
      if (!mounted || message == null) return;

      context.read<MatchProgrammeRefreshNotifier>().notifyMatchesChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _checkAgain() {
    final teamId = _teamId;
    if (teamId == null) return;
    AppAnalytics.logEvent('season_over_check_again');
    context.read<HomeCubit>().loadSeasonOutlook(teamId, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final recap = _SeasonRecap.from(widget.matches);
    final hasHistory = recap.played > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.sm),
          Text(
            hasHistory ? l10n.seasonOverEyebrow : l10n.seasonEmptyEyebrow,
            style: textStyles.caption2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasHistory ? l10n.seasonOverTitle : l10n.seasonEmptyTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyles.h2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.05,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Container(
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(HomeBentoCard.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasHistory) _RecapBand(recap: recap),
                Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildStatus(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onOpenWrapped != null)
            TextButton.icon(
              key: const ValueKey('season_over_watch_wrapped'),
              onPressed: widget.onOpenWrapped,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(l10n.wrappedWatchAgain),
              style: TextButton.styleFrom(
                foregroundColor: WrappedPalette.deepGraes,
                minimumSize: const Size.fromHeight(44),
                textStyle: textStyles.body4.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final outlook = widget.outlook;

    if (outlook == null) {
      return const _CheckingSection(key: ValueKey('season_checking'));
    }

    final candidate = outlook.bestCandidate;
    switch (outlook.status) {
      case DbuSeasonOutlookStatus.ready when candidate != null:
        return _ReadySection(
          key: const ValueKey('season_ready'),
          candidate: candidate,
          isImporting: _isImporting,
          onStart: () => _import(candidate: candidate, source: 'ready'),
          onFindManually: () => _import(
            skipSuggestion: true,
            source: 'ready_not_this_one',
          ),
        );
      case DbuSeasonOutlookStatus.unavailable:
        return _ManualSection(
          key: const ValueKey('season_manual'),
          isImporting: _isImporting,
          onStart: () => _import(skipSuggestion: true, source: 'manual'),
        );
      case DbuSeasonOutlookStatus.ready:
      case DbuSeasonOutlookStatus.waiting:
        return _WaitingSection(
          key: const ValueKey('season_waiting'),
          checkedAt: outlook.checkedAt,
          isChecking: widget.isChecking,
          isImporting: _isImporting,
          onCheckAgain: _checkAgain,
          onImportAnyway: () => _import(
            skipSuggestion: true,
            source: 'waiting_override',
          ),
        );
    }
  }
}

/// Played-match totals from the team's own perspective. Matches without a
/// known home/away side still count as played, but not towards W-D-L/goals.
class _SeasonRecap {
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goals;
  final bool hasRecord;

  const _SeasonRecap({
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goals,
    required this.hasRecord,
  });

  factory _SeasonRecap.from(List<MatchDetails> matches) {
    var played = 0, wins = 0, draws = 0, losses = 0, goals = 0;
    var hasRecord = false;
    for (final match in matches) {
      if (!match.hasMatchBeenPlayed) continue;
      played++;
      final isHome = match.isHomeTeam;
      if (isHome == null) continue;
      hasRecord = true;
      final own = isHome ? match.homeTeamScore! : match.awayTeamScore!;
      final other = isHome ? match.awayTeamScore! : match.homeTeamScore!;
      goals += own;
      if (own > other) {
        wins++;
      } else if (own == other) {
        draws++;
      } else {
        losses++;
      }
    }
    return _SeasonRecap(
      played: played,
      wins: wins,
      draws: draws,
      losses: losses,
      goals: goals,
      hasRecord: hasRecord,
    );
  }
}

class _RecapBand extends StatelessWidget {
  final _SeasonRecap recap;

  const _RecapBand({required this.recap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 14, Spacing.md, 14),
      decoration: BoxDecoration(
        color: colors.lightGrass,
        borderRadius: BorderRadius.circular(HomeBentoCard.cardRadius),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/illustrations/kopa_flag.svg',
            height: 64,
            colorFilter: ColorFilter.mode(colors.dirt, BlendMode.srcIn),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.seasonRecapTitle,
                  style: textStyles.caption.copyWith(
                    color: colors.dirt,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _RecapStat(
                        value: '${recap.played}',
                        label: l10n.seasonRecapMatches,
                      ),
                    ),
                    if (recap.hasRecord) ...[
                      Expanded(
                        child: _RecapStat(
                          value: '${recap.wins}-${recap.draws}-${recap.losses}',
                          label: l10n.seasonRecapRecord,
                        ),
                      ),
                      Expanded(
                        child: _RecapStat(
                          value: '${recap.goals}',
                          label: l10n.seasonRecapGoals,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapStat extends StatelessWidget {
  final String value;
  final String label;

  const _RecapStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: textStyles.h4.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyles.caption3.copyWith(
            color: colors.grey5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CheckingSection extends StatelessWidget {
  const _CheckingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      children: [
        SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: Spacing.itemGap),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.seasonChecking,
            style: textStyles.body3.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingSection extends StatelessWidget {
  final DateTime? checkedAt;
  final bool isChecking;
  final bool isImporting;
  final VoidCallback onCheckAgain;
  final VoidCallback onImportAnyway;

  const _WaitingSection({
    super.key,
    required this.checkedAt,
    required this.isChecking,
    required this.isImporting,
    required this.onCheckAgain,
    required this.onImportAnyway,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final checkedAt = this.checkedAt;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusHeader(
          icon: Icons.hourglass_top_rounded,
          iconColor: colors.sunset,
          iconBackground: colors.sunset.withValues(alpha: 0.14),
          title: l10n.seasonWaitingTitle,
          body: l10n.seasonWaitingBody,
        ),
        if (checkedAt != null) ...[
          const SizedBox(height: Spacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: _StatusHeader.textInset),
            child: Text(
              l10n.seasonLastChecked(
                DateFormat.MMMd(locale).add_Hm().format(checkedAt),
              ),
              style: textStyles.caption3.copyWith(
                color: colors.grey4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        FullWidthButton(
          outlined: true,
          icon: Icons.refresh_rounded,
          buttonText: l10n.seasonCheckAgain,
          loading: isChecking,
          enabled: !isChecking && !isImporting,
          onPressed: onCheckAgain,
        ),
        const SizedBox(height: Spacing.xs),
        _LinkButton(
          label: l10n.seasonImportAnyway,
          loading: isImporting,
          onPressed: isImporting ? null : onImportAnyway,
        ),
      ],
    );
  }
}

class _ReadySection extends StatelessWidget {
  final DbuNextSeasonCandidate candidate;
  final bool isImporting;
  final VoidCallback onStart;
  final VoidCallback onFindManually;

  const _ReadySection({
    super.key,
    required this.candidate,
    required this.isImporting,
    required this.onStart,
    required this.onFindManually,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstMatch = candidate.firstUpcomingMatchOn;
    final headline = candidate.seriesName.isNotEmpty
        ? candidate.seriesName
        : candidate.teamName;
    final subline = [candidate.seasonLabel, candidate.poolLabel]
        .where((part) => part.isNotEmpty && !headline.contains(part))
        .join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + 2,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.sun,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 14, color: colors.dirt),
                const SizedBox(width: Spacing.xs),
                Text(
                  l10n.seasonReadyBadge,
                  style: textStyles.caption3.copyWith(
                    color: colors.dirt,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.itemGap),
        Text(
          l10n.seasonReadyTitle,
          style: textStyles.subtitle2.copyWith(
            color: colors.dirt,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          padding: const EdgeInsets.all(Spacing.itemGap),
          decoration: BoxDecoration(
            color: colors.lightGrass95,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
            border: Border.all(color: colors.lightGrass),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: colors.primary),
              const SizedBox(width: Spacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.body3.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subline.isNotEmpty)
                      Text(
                        subline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.caption3.copyWith(
                          color: colors.grey5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (firstMatch != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.seasonReadyMatches(
                          candidate.upcomingMatchCount,
                          DateFormat.MMMd(locale).format(firstMatch),
                        ),
                        style: textStyles.caption3.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        FullWidthButton(
          icon: Icons.play_arrow_rounded,
          buttonText: l10n.seasonStartNew,
          loading: isImporting,
          enabled: !isImporting,
          onPressed: onStart,
        ),
        const SizedBox(height: Spacing.xs),
        _LinkButton(
          label: l10n.seasonNotThisOne,
          onPressed: isImporting ? null : onFindManually,
        ),
      ],
    );
  }
}

class _ManualSection extends StatelessWidget {
  final bool isImporting;
  final VoidCallback onStart;

  const _ManualSection({
    super.key,
    required this.isImporting,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusHeader(
          icon: Icons.event_available_outlined,
          iconColor: colors.sky,
          iconBackground: colors.lightSky95,
          title: l10n.seasonManualTitle,
          body: l10n.seasonManualBody,
        ),
        const SizedBox(height: Spacing.md),
        FullWidthButton(
          icon: Icons.play_arrow_rounded,
          buttonText: l10n.seasonStartNew,
          loading: isImporting,
          enabled: !isImporting,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  static const double _iconSize = 40;
  static const double textInset = _iconSize + Spacing.itemGap;

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String body;

  const _StatusHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _iconSize,
          height: _iconSize,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: Spacing.itemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textStyles.subtitle2.copyWith(
                  color: colors.dirt,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: textStyles.body3.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _LinkButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size.fromHeight(44),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          : Text(
              label,
              textAlign: TextAlign.center,
              style: textStyles.body4.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
