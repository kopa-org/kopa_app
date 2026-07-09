import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

const double _heroPanelGradientOverlap = 32;

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final teamId =
            context.read<AuthCubit>().state.user?.teamDetails?.id ?? 0;
        return HomeCubit()..fetchDashboardData(teamId);
      },
      child: const _HomeTabView(),
    );
  }
}

class _HomeTabView extends StatelessWidget {
  const _HomeTabView();

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final currentUser = context.read<AuthCubit>().state.user;

    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    return PageScaffold(
      title: 'Forside',
      showBackButton: false,
      showTopBar: false,
      backgroundColor: appColors.white,
      body: RefreshIndicator(
        color: appColors.primary,
        onRefresh: () async {
          await context
              .read<HomeCubit>()
              .fetchDashboardData(currentUser.teamDetails!.id);
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.initial ||
                state.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == HomeStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Text(
                    state.errorMessage ?? 'Kunne ikke hente dashboard data',
                    style: appTextStyles.body.copyWith(color: appColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final upcomingMatches = _upcomingMatches(state);
            final playedMatches = _playedMatches(state);
            final nextMatch = upcomingMatches.isEmpty
                ? state.nextMatch
                : upcomingMatches.first;
            final latestMatch =
                playedMatches.isEmpty ? null : playedMatches.last;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HomeTopBar(currentUser: currentUser),
                  _HeroSection(
                    currentUser: currentUser,
                    nextMatch: nextMatch,
                  ),
                  _HeroPanelCutover(
                    overlap: _heroPanelGradientOverlap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: _HeroTeamPanel(
                        match: nextMatch,
                        currentUser: currentUser,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      Spacing.md,
                      Spacing.md,
                      0,
                    ),
                    child: _BentoGrid(
                      currentUser: currentUser,
                      latestMatch: latestMatch,
                      standings: state.dbuStandings,
                      statistics: state.statistics,
                      fineBox: state.fineBox,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final UserDetails currentUser;

  const _HomeTopBar({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        color: appColors.grass,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/logos/logomark_outline_foreground.svg',
            height: 30,
            colorFilter: ColorFilter.mode(appColors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            'Kopa',
            style: appTextStyles.h5.copyWith(
              color: appColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifikationer',
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: appColors.white,
          ),
          IconButton(
            tooltip: 'Indstillinger',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: appColors.white,
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final UserDetails currentUser;
  final MatchDetails? nextMatch;

  const _HeroSection({
    required this.currentUser,
    required this.nextMatch,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final firstName = currentUser.name.split(' ').first;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.lg,
        Spacing.md,
        Spacing.lg + _heroPanelGradientOverlap,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.heroStart, palette.heroEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(initials: _initials(currentUser.name), radius: 24),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  'Hej $firstName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.h4.copyWith(
                    color: appColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            nextMatch == null ? 'Ingen kommende kamp' : 'Næste kamp om',
            style: appTextStyles.caption2.copyWith(
              color: appColors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _HeroCountdown(target: nextMatch?.date),
        ],
      ),
    );
  }
}

class _HeroPanelCutover extends StatefulWidget {
  final Widget child;
  final double overlap;

  const _HeroPanelCutover({
    required this.child,
    required this.overlap,
  });

  @override
  State<_HeroPanelCutover> createState() => _HeroPanelCutoverState();
}

class _HeroPanelCutoverState extends State<_HeroPanelCutover> {
  Size _childSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    final height = math.max(0.0, _childSize.height - widget.overlap);

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -widget.overlap,
            child: _MeasureSize(
              onChange: (size) {
                if (!mounted || size == _childSize) return;
                setState(() => _childSize = size);
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = size;
    if (_oldSize == newSize) return;

    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}

class _HeroCountdown extends StatefulWidget {
  final DateTime? target;

  const _HeroCountdown({required this.target});

  @override
  State<_HeroCountdown> createState() => _HeroCountdownState();
}

class _HeroCountdownState extends State<_HeroCountdown> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant _HeroCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _remaining = _calculateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemaining() {
    final target = widget.target;
    if (target == null) return Duration.zero;
    final remaining = target.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _remaining = _calculateRemaining());
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    if (widget.target == null) {
      return Text(
        'Planen opdateres',
        style: _displayStyle(context).copyWith(
          fontSize: 36,
          color: appColors.white,
        ),
      );
    }

    return Row(
      children: [
        _HeroCountdownBlock(
          value: _remaining.inDays,
          label: 'Dag',
        ),
        const SizedBox(width: 22),
        _HeroCountdownBlock(
          value: _remaining.inHours % 24,
          label: 'Timer',
        ),
        const SizedBox(width: 22),
        _HeroCountdownBlock(
          value: _remaining.inMinutes % 60,
          label: 'Min',
        ),
      ],
    );
  }
}

class _HeroCountdownBlock extends StatelessWidget {
  final int value;
  final String label;

  const _HeroCountdownBlock({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: _displayStyle(context).copyWith(
            color: appColors.white,
            fontSize: 50,
            height: 0.98,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          style: appTextStyles.label.copyWith(
            color: appColors.white.withValues(alpha: 0.62),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroTeamPanel extends StatelessWidget {
  final MatchDetails? match;
  final UserDetails currentUser;

  const _HeroTeamPanel({
    required this.match,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final homeTeam =
        match?.homeTeam ?? currentUser.teamDetails?.title ?? 'Hold';
    final awayTeam = match?.awayTeam ?? 'Modstander';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: appColors.lightGrass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: appColors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _HeroTeam(
                      name: homeTeam,
                      teamId: currentUser.teamDetails?.id ?? 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Text(
                      'vs',
                      style: appTextStyles.subtitle2.copyWith(
                        color: appColors.grass.withValues(alpha: 0.48),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _HeroTeam(
                      name: awayTeam,
                      teamId: _stableTeamSeed(awayTeam),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              if (match == null)
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: appColors.grass,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Ingen kamp planlagt',
                    style: appTextStyles.buttonSmall.copyWith(
                      color: appColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                _HeroMatchCta(
                  match: match!,
                  currentUser: currentUser,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTeam extends StatelessWidget {
  final String name;
  final int? teamId;

  const _HeroTeam({
    required this.name,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TeamAvatar(
            teamName: name,
            teamId: teamId ?? 0,
            radius: 21,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          _shortName(name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: appTextStyles.caption2.copyWith(
            color: appColors.grass,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroMatchCta extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;

  const _HeroMatchCta({
    required this.match,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final state = context.watch<HomeCubit>().state;
    final isRegistering = state.isRegisteringForNextMatch;
    final isRegistered = match.isCurrentUserRegistered;

    return Material(
      color: appColors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isRegistered
            ? () => _openMatch(context, match, 'home_hero')
            : isRegistering
                ? null
                : () {
                    AppAnalytics.logEvent(
                      'match_registered',
                      parameters: {'source': 'home_hero'},
                    );
                    final teamId = currentUser.teamDetails?.id ?? 0;
                    context
                        .read<HomeCubit>()
                        .registerForMatch(match.id, teamId);
                  },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isRegistered
                    ? 'SE KAMPDETALJER'
                    : isRegistering
                        ? 'TILMELDES'
                        : 'TILMELD NU',
                style: appTextStyles.buttonSmall.copyWith(
                  color: appColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(
                isRegistered ? Icons.arrow_forward : Icons.how_to_reg,
                color: appColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final UserDetails currentUser;
  final MatchDetails? latestMatch;
  final DbuStandings? standings;
  final StatisticsResponse? statistics;
  final FineBoxDetails? fineBox;

  const _BentoGrid({
    required this.currentUser,
    required this.latestMatch,
    required this.standings,
    required this.statistics,
    required this.fineBox,
  });

  @override
  Widget build(BuildContext context) {
    final currentStanding = _currentStandingRow(standings, currentUser);
    final topScorer = _topScorer(statistics);

    return Column(
      children: [
        _LatestResultCard(
          match: latestMatch,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(child: _TopScorerCard(row: topScorer)),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _PlacementMiniCard(
                standing: currentStanding,
                poolId: standings?.poolId?.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        _TasksCard(),
        const SizedBox(height: Spacing.md),
        _QuickTableCard(
          standings: standings,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        _FineBoxBentoCard(
          fineBox: fineBox,
          currentUser: currentUser,
        ),
      ],
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  final MatchDetails? match;
  final UserDetails currentUser;

  const _LatestResultCard({
    required this.match,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final score = match == null
        ? '-:-'
        : '${match!.homeTeamScore ?? 0}:${match!.awayTeamScore ?? 0}';
    final resultLabel = _resultLabel(match, currentUser);
    final motm = match?.matchPollDetails?.playerOfTheMatchDetails.name;

    return _BentoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      color: palette.surfaceLow,
      child: InkWell(
        onTap: match == null
            ? null
            : () => _openMatch(context, match!, 'home_latest'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SENESTE RESULTAT',
                    style: appTextStyles.label.copyWith(
                      color: palette.onSurfaceMuted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (resultLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.lightGrass,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      resultLabel,
                      style: appTextStyles.label.copyWith(
                        color: appColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SmallTeamMark(
                  name: match?.homeTeam ?? 'Hjemme',
                  teamId: _stableTeamSeed(match?.homeTeam ?? 'Hjemme'),
                ),
                Text(
                  score,
                  style: _displayStyle(context).copyWith(
                    color: palette.onSurface,
                    fontSize: 42,
                  ),
                ),
                _SmallTeamMark(
                  name: match?.awayTeam ?? 'Ude',
                  teamId: _stableTeamSeed(match?.awayTeam ?? 'Ude'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              motm == null
                  ? 'Ingen kampens spiller valgt endnu'
                  : '$motm valgt til kampens spiller',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: appTextStyles.caption1.copyWith(
                color: palette.onSurfaceMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTeamMark extends StatelessWidget {
  final String name;
  final int? teamId;

  const _SmallTeamMark({
    required this.name,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.62,
      child: TeamAvatar(
        teamName: name,
        teamId: teamId ?? 0,
        radius: 22,
      ),
    );
  }
}

class _TopScorerCard extends StatelessWidget {
  final LeaderboardRow? row;

  const _TopScorerCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final name = row?.userName.split(' ').first ?? '-';
    final goals = row?.value.toInt() ?? 0;

    return _BentoCard(
      color: palette.statCard,
      padding: const EdgeInsets.all(Spacing.md),
      child: SizedBox(
        height: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOPSCORER',
              style: appTextStyles.label.copyWith(
                color: appColors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.subtitle1.copyWith(
                color: appColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$goals mål',
              style: appTextStyles.caption3.copyWith(
                color: appColors.white.withValues(alpha: 0.78),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.track_changes,
                color: appColors.white.withValues(alpha: 0.20),
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacementMiniCard extends StatelessWidget {
  final DbuStandingRow? standing;
  final String? poolId;

  const _PlacementMiniCard({
    required this.standing,
    required this.poolId,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    return _BentoCard(
      color: palette.highlightCard,
      padding: const EdgeInsets.all(Spacing.md),
      child: SizedBox(
        height: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLACERING',
              style: appTextStyles.label.copyWith(
                color: palette.onHighlight.withValues(alpha: 0.72),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              standing == null ? '-' : '${standing!.position}.',
              style: _displayStyle(context).copyWith(
                color: palette.onHighlight,
                fontSize: 36,
              ),
            ),
            Text(
              poolId == null ? 'Serie' : 'Serie $poolId',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.label.copyWith(
                color: palette.onHighlight,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.leaderboard_outlined,
                color: palette.onHighlight.withValues(alpha: 0.18),
                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    return _BentoCard(
      color: palette.surfaceRaised,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPGAVER',
            style: appTextStyles.label.copyWith(
              color: palette.onSurfaceMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: Spacing.md),
          _TaskEmptyRow(),
          const SizedBox(height: Spacing.md),
          Center(
            child: Text(
              'SE ALLE OPGAVER',
              style: appTextStyles.label.copyWith(
                color: palette.onSurfaceMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskEmptyRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: appColors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_outlined, color: appColors.primary, size: 18),
          const SizedBox(width: Spacing.sm),
          Text(
            'Ingen opgaver',
            style: appTextStyles.caption2.copyWith(
              color: palette.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTableCard extends StatelessWidget {
  final DbuStandings? standings;
  final UserDetails currentUser;

  const _QuickTableCard({
    required this.standings,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final rows = standings?.rows.take(4).toList() ?? const <DbuStandingRow>[];

    return _BentoCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            color: palette.statCard,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'STILLING - SERIE ${standings?.poolId ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.label.copyWith(
                      color: appColors.white,
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
                _TableHeader(),
                Divider(color: palette.outline),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                    child: Text(
                      'Ingen stilling tilgængelig',
                      style: appTextStyles.caption1.copyWith(
                        color: palette.onSurfaceMuted,
                      ),
                    ),
                  )
                else
                  for (final row in rows)
                    _StandingPreviewRow(
                      row: row,
                      isCurrentTeam: _isCurrentTeam(row, currentUser),
                    ),
                const SizedBox(height: Spacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.outline),
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
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final style = appTextStyles.label.copyWith(
      color: palette.onSurfaceMuted,
      fontWeight: FontWeight.w800,
    );

    return Row(
      children: [
        SizedBox(width: 28, child: Text('#', style: style)),
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
    final palette = _HomePalette(appColors);
    final color = isCurrentTeam ? appColors.primary : palette.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: isCurrentTeam
            ? appColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
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
            child: Row(
              children: [
                if (isCurrentTeam) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: appColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                ],
                Expanded(
                  child: Text(
                    row.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.caption2.copyWith(
                      color: color,
                      fontWeight:
                          isCurrentTeam ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
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

class _FineBoxBentoCard extends StatelessWidget {
  final FineBoxDetails? fineBox;
  final UserDetails currentUser;

  const _FineBoxBentoCard({
    required this.fineBox,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final personalAmounts = fineBox == null
        ? (0.0, 0.0)
        : _personalFineAmounts(fineBox!, currentUser);
    final totalBalance = fineBox == null
        ? 0.0
        : fineBox!.currentAmount + fineBox!.totalOwedAmount;
    final primaryAmount =
        currentUser.isTeamOwner ? totalBalance : personalAmounts.$2;
    final collected = fineBox?.currentAmount ?? 0;
    final target = math.max(totalBalance, 1);
    final progress = (collected / target).clamp(0.0, 1.0);

    return _BentoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: InkWell(
        onTap: fineBox == null ? null : () => _openFineBox(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BØDEKASSEN',
                        style: appTextStyles.label.copyWith(
                          color: palette.onSurfaceMuted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        '${primaryAmount.toStringAsFixed(0)},-',
                        style: _displayStyle(context).copyWith(
                          color: appColors.primary,
                          fontSize: 42,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.savings_outlined, color: appColors.primary),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Text(
                  currentUser.isTeamOwner ? 'Indsamlet' : 'Samlet bøder',
                  style: appTextStyles.caption2.copyWith(
                    color: palette.onSurfaceMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  currentUser.isTeamOwner
                      ? '${collected.toStringAsFixed(0)},-'
                      : '${personalAmounts.$1.toStringAsFixed(0)},-',
                  style: appTextStyles.caption2.copyWith(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: palette.surfaceRaised,
                valueColor: AlwaysStoppedAnimation<Color>(appColors.primary),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Text(
                  currentUser.isTeamOwner ? 'Gå til bødekassen' : 'Betal nu',
                  style: appTextStyles.buttonSmall.copyWith(
                    color: appColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: appColors.primary, size: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool clip;

  const _BentoCard({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.color,
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final palette = _HomePalette(appColors);

    return Container(
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

List<MatchDetails> _upcomingMatches(HomeState state) {
  final now = DateTime.now();
  final matches = state.matches
      .where(
        (match) =>
            !match.hasMatchBeenPlayed &&
            match.date.isAfter(now.subtract(const Duration(days: 1))),
      )
      .map(
        (match) => match.id == state.nextMatch?.id ? state.nextMatch! : match,
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  if (matches.isEmpty && state.nextMatch != null) {
    return [state.nextMatch!];
  }
  return matches;
}

List<MatchDetails> _playedMatches(HomeState state) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return state.matches
      .where(
        (match) => match.hasMatchBeenPlayed && match.date.isBefore(today),
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

DbuStandingRow? _currentStandingRow(
  DbuStandings? standings,
  UserDetails currentUser,
) {
  if (standings == null) {
    return null;
  }

  final currentTeamId = standings.currentTeamId;
  final currentTeamName = currentUser.teamDetails?.title.toLowerCase();
  return standings.rows.cast<DbuStandingRow?>().firstWhere(
        (row) =>
            row?.dbuTeamId == currentTeamId ||
            row?.teamName.toLowerCase() == currentTeamName,
        orElse: () => null,
      );
}

LeaderboardRow? _topScorer(StatisticsResponse? statistics) {
  final rows = statistics?.leaderboards.topScorers;
  if (rows == null || rows.isEmpty) {
    return null;
  }
  return rows.first;
}

(double, double) _personalFineAmounts(
  FineBoxDetails fineBox,
  UserDetails currentUser,
) {
  try {
    final myFineDetails = fineBox.userFineDetails
        .firstWhere((userFine) => userFine.userDetails.id == currentUser.id);
    final totalAmount = myFineDetails.fineDetailsList
        .fold(0.0, (sum, fine) => sum + fine.owedAmount);
    final owedAmount = myFineDetails.fineDetailsList
        .where((fine) => !fine.hasBeenPaid)
        .fold(0.0, (sum, fine) => sum + fine.owedAmount);
    return (totalAmount, owedAmount);
  } catch (_) {
    return (0.0, 0.0);
  }
}

bool _isCurrentTeam(DbuStandingRow row, UserDetails currentUser) {
  final currentTeamName = currentUser.teamDetails?.title.toLowerCase();
  return row.teamName.toLowerCase() == currentTeamName;
}

int _stableTeamSeed(String name) {
  var hash = 0;
  for (final codeUnit in name.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

String? _resultLabel(MatchDetails? match, UserDetails currentUser) {
  if (match == null ||
      match.homeTeamScore == null ||
      match.awayTeamScore == null) {
    return null;
  }

  final currentTeamName = currentUser.teamDetails?.title.toLowerCase();
  final isHome = match.homeTeam?.toLowerCase() == currentTeamName;
  final currentScore = isHome ? match.homeTeamScore! : match.awayTeamScore!;
  final opponentScore = isHome ? match.awayTeamScore! : match.homeTeamScore!;

  if (currentScore > opponentScore) return 'SEJR';
  if (currentScore == opponentScore) return 'UAFGJORT';
  return 'TABT';
}

String _shortName(String name) {
  final trimmed = name.trim();
  if (trimmed.length <= 12) return trimmed;
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length > 1) {
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }
  return trimmed;
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

TextStyle _displayStyle(BuildContext context) {
  final appTextStyles =
      Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
  return appTextStyles.h2.copyWith(
    fontWeight: FontWeight.w900,
  );
}

void _openMatch(BuildContext context, MatchDetails match, String source) {
  AppAnalytics.logEvent('match_opened', parameters: {'source': source});
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MatchDetailsPage(
        matchId: match.id,
        initialMatch: match,
        heroTag: 'home-match-${match.id}-$source',
      ),
    ),
  );
}

void _openFineBox(BuildContext context) {
  AppAnalytics.logEvent('fine_box_opened');
  Navigator.of(context).push(MaterialWithModalsPageRoute(
    builder: (context) => const TeamFinesPage(),
  ));
}

class _HomePalette {
  final AppColors colors;

  const _HomePalette(this.colors);

  Color get surface => colors.white;
  Color get surfaceLow => colors.lightGrass55;
  Color get surfaceRaised => colors.grey2;
  Color get highlightCard => colors.lightGrass;
  Color get statCard => colors.grass;
  Color get heroStart => colors.grass;
  Color get heroEnd => colors.white;
  Color get onSurface => colors.dirt;
  Color get onSurfaceMuted => colors.grey5;
  Color get onHighlight => colors.dirt;
  Color get outline => colors.grey3;
}
