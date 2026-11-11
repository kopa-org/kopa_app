import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/settings/settings_list.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/match_programme_cubit.dart';
import 'package:kopa/cubits/season_overview_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/event_type.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/match/create_match_page.dart';
import 'package:kopa/page/profile/dbu_calendar_import_flow.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Season and DBU imports: a summary of the current season, the match
/// schedule and standings imports, starting the next season and creating
/// matches by hand.
class SeasonSettingsPage extends StatelessWidget {
  final SeasonOverviewCubit Function(int? teamId)? createOverviewCubit;

  const SeasonSettingsPage({super.key, this.createOverviewCubit});

  @override
  Widget build(BuildContext context) {
    final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
    return BlocProvider<SeasonOverviewCubit>(
      create: (_) => (createOverviewCubit?.call(teamId) ??
          SeasonOverviewCubit(teamId: teamId))
        ..load(),
      child: const _SeasonSettingsView(),
    );
  }
}

class _SeasonSettingsView extends StatefulWidget {
  const _SeasonSettingsView();

  @override
  State<_SeasonSettingsView> createState() => _SeasonSettingsViewState();
}

class _SeasonSettingsViewState extends State<_SeasonSettingsView> {
  bool _isImporting = false;
  bool _isStartingSeason = false;
  bool _isSyncingStandings = false;
  String? _errorMessage;

  bool get _busy => _isImporting || _isStartingSeason || _isSyncingStandings;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final overview = context.watch<SeasonOverviewCubit>().state;
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final matchCount = overview.matchCount;
    final syncedAt = overview.standings?.syncedAt;

    return PageScaffold(
      title: l10n.settingsSectionSeason,
      showBackButton: true,
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: context.read<SeasonOverviewCubit>().load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.xl,
          ),
          children: [
            _SeasonHero(overview: overview),
            if (_errorMessage != null) ...[
              const SizedBox(height: Spacing.itemGap),
              Text(
                _errorMessage!,
                style: styles.body.copyWith(color: colors.error),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            SettingsSectionLabel(l10n.settingsSeasonFetchSection),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SeasonActionCard(
                      key: const ValueKey('season-settings-import'),
                      icon: Icons.calendar_month_rounded,
                      title: l10n.settingsSeasonScheduleTitle,
                      meta: matchCount == null
                          ? null
                          : matchCount == 0
                              ? l10n.settingsSeasonScheduleEmpty
                              : l10n.settingsSeasonScheduleMeta(matchCount),
                      actionLabel: l10n.settingsSeasonImportAction,
                      loading: _isImporting,
                      onTap: _busy ? null : _importSchedule,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SeasonActionCard(
                      key: const ValueKey('season-settings-standings'),
                      icon: Icons.leaderboard_rounded,
                      title: l10n.settingsSeasonStandingsTitle,
                      meta: overview.loading && overview.standings == null
                          ? null
                          : syncedAt == null
                              ? l10n.settingsSeasonStandingsNever
                              : l10n.settingsSeasonStandingsUpdated(
                                  DateFormat.MMMd(localeName).format(syncedAt),
                                ),
                      actionLabel: l10n.settingsSeasonSyncAction,
                      loading: _isSyncingStandings,
                      onTap: _busy ? null : _syncStandings,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              child: Text(
                l10n.settingsSeasonDbuHint,
                style: styles.caption.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            SettingsSectionLabel(l10n.settingsSeasonChangeSection),
            _NextSeasonCard(
              outlook: overview.outlook,
              loading: _isStartingSeason,
              onStart: _busy ? null : _startNextSeason,
            ),
            const SizedBox(height: Spacing.lg),
            SettingsSection(
              title: l10n.settingsSeasonOtherSources,
              children: [
                SettingsRow(
                  key: const ValueKey('season-settings-create-match'),
                  icon: Icons.add_rounded,
                  tone: SettingsTone.neutral,
                  title: l10n.settingsSeasonCreateMatch,
                  subtitle: l10n.settingsSeasonCreateMatchSubtitle,
                  onTap: _busy ? null : _createMatch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMatchesChanged() {
    MatchRepository.invalidateMatchSummaries();
    context.read<MatchProgrammeRefreshNotifier>().notifyMatchesChanged();
    context.read<SeasonOverviewCubit>().load();
  }

  Future<void> _importSchedule() => _runImport(
        setLoading: (value) => _isImporting = value,
      );

  Future<void> _startNextSeason() {
    final outlook = context.read<SeasonOverviewCubit>().state.outlook;
    final candidate = outlook?.status == DbuSeasonOutlookStatus.ready
        ? outlook?.bestCandidate
        : null;
    return _runImport(
      setLoading: (value) => _isStartingSeason = value,
      startNewSeason: true,
      candidate: candidate,
    );
  }

  Future<void> _runImport({
    required void Function(bool value) setLoading,
    bool startNewSeason = false,
    DbuNextSeasonCandidate? candidate,
  }) async {
    setState(() {
      setLoading(true);
      _errorMessage = null;
    });

    try {
      final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
      final message = await DbuCalendarImportFlow.run(
        context,
        teamId: teamId,
        startNewSeason: startNewSeason,
        candidate: candidate,
      );
      if (!mounted) return;
      if (message != null) {
        _onMatchesChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      setState(() => setLoading(false));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        setLoading(false);
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _createMatch() async {
    final cubit = MatchProgrammeCubit()..loadMatches(showLoading: false);
    await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CreateMatchPage(
          matches: cubit.state.matches,
          eventType: KopaEventType.match,
        ),
      ),
    );
    await cubit.close();
    if (!mounted) return;
    _onMatchesChanged();
  }

  Future<void> _syncStandings() async {
    const operation = DbuWebviewOperation.standings;
    final user = context.read<AuthCubit>().state.user;
    final teamId = user?.teamDetails?.id;
    if (user?.isTeamOwner != true || teamId == null) return;

    setState(() {
      _isSyncingStandings = true;
      _errorMessage = null;
    });

    try {
      AppAnalytics.logEvent(
        'dbu_pool_sync_started',
        parameters: {'operation': operation.wireValue},
      );
      final result = await context.push<String>(
        AppRouter.dbuWebview,
        extra: operation,
      );
      if (!mounted) return;

      if (result == null) {
        setState(() => _isSyncingStandings = false);
        return;
      }

      final scrapedData = jsonDecode(result) as Map<String, dynamic>;
      final scraperError = scrapedData['error']?.toString();
      if (scraperError != null && scraperError.isNotEmpty) {
        throw Exception(scraperError);
      }

      await TeamDbuRepository.syncStandings(
        teamId: teamId,
        scrapedData: scrapedData,
      );
      if (!mounted) return;

      final count = (scrapedData['standings'] as List<dynamic>? ?? []).length;
      AppAnalytics.logEvent(
        'dbu_pool_sync_completed',
        parameters: {'operation': operation.wireValue, 'row_count': count},
      );
      setState(() => _isSyncingStandings = false);
      context.read<SeasonOverviewCubit>().load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .uiStandingsAndPoolTeamsAreSynced(count),
          ),
        ),
      );
    } catch (error) {
      AppAnalytics.logEvent(
        'dbu_pool_sync_failed',
        parameters: {'operation': operation.wireValue},
      );
      if (!mounted) return;
      setState(() {
        _isSyncingStandings = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }
}

/// Pitch-striped summary of the active season, as in the design.
class _SeasonHero extends StatelessWidget {
  final SeasonOverviewState overview;

  const _SeasonHero({required this.overview});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final season = overview.activeSeason;
    final seriesName = overview.standings?.seriesName?.trim();
    final poolSize = overview.poolSize;
    final subtitle = [
      if (seriesName != null && seriesName.isNotEmpty) seriesName,
      if (poolSize != null) l10n.settingsSeasonPoolTeams(poolSize),
    ].join(' · ');
    final position = overview.position;
    final onPitch = Color.alphaBlend(
      colors.white.withValues(alpha: .85),
      colors.pitch,
    );

    final stats = [
      if (overview.matchCount != null)
        (
          key: 'matches',
          value: '${overview.matchCount}',
          label: l10n.settingsSeasonStatMatches,
        ),
      if (overview.playedCount != null)
        (
          key: 'played',
          value: '${overview.playedCount}',
          label: l10n.settingsSeasonStatPlayed,
        ),
      if (position != null)
        (
          key: 'position',
          value: l10n.settingsSeasonPositionValue(position),
          label: l10n.settingsSeasonStatPosition,
        ),
    ];

    return Container(
      key: const ValueKey('season-settings-hero'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
        color: colors.pitch,
      ),
      child: CustomPaint(
        painter: _PitchStripesPainter(colors.pitchStripe),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsSeasonCurrentLabel.toUpperCase(),
                style: styles.caption.copyWith(
                  color: colors.lightGrass,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              if (season == null && overview.loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: CupertinoActivityIndicator(color: colors.white),
                )
              else
                Text(
                  season?.name ?? l10n.settingsSeasonNone,
                  style: styles.h3.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: styles.body3.copyWith(color: onPitch),
                ),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    for (var i = 0; i < stats.length; i++) ...[
                      if (i > 0) const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Container(
                          key: ValueKey('season-stat-${stats[i].key}'),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.black.withValues(alpha: .22),
                            borderRadius: BorderRadius.circular(
                              Spacing.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stats[i].value,
                                style: styles.h4.copyWith(
                                  color: colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                stats[i].label,
                                style: styles.caption.copyWith(color: onPitch),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchStripesPainter extends CustomPainter {
  final Color stripe;

  const _PitchStripesPainter(this.stripe);

  @override
  void paint(Canvas canvas, Size size) {
    const width = 44.0;
    final paint = Paint()..color = stripe;
    for (var x = width; x < size.width; x += width * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_PitchStripesPainter oldDelegate) =>
      oldDelegate.stripe != stripe;
}

class _NextSeasonCard extends StatelessWidget {
  final DbuSeasonOutlook? outlook;
  final bool loading;
  final VoidCallback? onStart;

  const _NextSeasonCard({
    required this.outlook,
    required this.loading,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final candidate = outlook?.status == DbuSeasonOutlookStatus.ready
        ? outlook?.bestCandidate
        : null;
    final body = candidate != null
        ? l10n.settingsSeasonNextReady(
            candidate.seasonLabel,
            candidate.upcomingMatchCount,
          )
        : outlook?.status == DbuSeasonOutlookStatus.waiting
            ? l10n.settingsSeasonNextWaiting
            : l10n.settingsSeasonNextUnknown;

    return Container(
      padding: Spacing.cardPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsIconTile(
                icon: Icons.autorenew_rounded,
                tone: SettingsTone.team,
              ),
              const SizedBox(width: Spacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsSeasonNextTitle,
                      style: styles.subtitle2.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: styles.body3.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.itemGap),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              key: const ValueKey('season-settings-next-season'),
              onPressed: onStart,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(
                  color: onStart == null ? colors.grey3 : colors.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Spacing.borderRadiusMedium),
                ),
              ),
              child: loading
                  ? const CupertinoActivityIndicator()
                  : Text(
                      candidate != null
                          ? l10n.settingsSeasonNextReadyButton(
                              candidate.seasonLabel,
                            )
                          : l10n.settingsSeasonNextButton,
                      style: styles.body3.copyWith(
                        color: onStart == null
                            ? colors.textSecondary
                            : colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? meta;
  final String actionLabel;
  final bool loading;
  final VoidCallback? onTap;

  const _SeasonActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.actionLabel,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(Spacing.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: Spacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsIconTile(icon: icon, tone: SettingsTone.season),
              const SizedBox(height: 10),
              Text(
                title,
                style: styles.subtitle2.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta ?? ' ',
                style: styles.body3.copyWith(color: colors.textSecondary),
              ),
              const Spacer(),
              const SizedBox(height: 10),
              SizedBox(
                height: 24,
                child: loading
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoActivityIndicator(),
                      )
                    : Text(
                        actionLabel,
                        style: styles.body3.copyWith(
                          color: onTap == null
                              ? colors.textSecondary
                              : colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
