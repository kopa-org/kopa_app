import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/page/standings/standings_page.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

const double _heroPanelGradientOverlap = 80;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PageScaffold(
        title: 'Forside',
        showBackButton: false,
        showTopBar: false,
        useTopSafeArea: false,
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
                      style:
                          appTextStyles.body.copyWith(color: appColors.error),
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
                      child: _HeroMatchCarousel(
                        matches: upcomingMatches,
                        fallbackMatch: nextMatch,
                        currentUser: currentUser,
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

    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      height: 64 + topInset,
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        topInset,
        Spacing.md,
        0,
      ),
      decoration: BoxDecoration(
        color: appColors.white,
        boxShadow: [
          BoxShadow(
            color: appColors.black,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/logos/logomark_outline_foreground.svg',
            height: 40,
            colorFilter: ColorFilter.mode(appColors.grass, BlendMode.srcIn),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            'Kopa',
            style: appTextStyles.h3.copyWith(
              color: appColors.grass,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifikationer',
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: appColors.grass,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.lg + _heroPanelGradientOverlap,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surface, palette.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Row(
            children: [
              AppAvatar(initials: _initials(currentUser.name), radius: 16),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  'Hej $firstName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.body4.copyWith(
                    color: appColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),*/
          const SizedBox(height: Spacing.sm),
          Text(
            nextMatch == null ? 'Ingen kommende kamp' : 'Næste kamp om',
            style: appTextStyles.caption2.copyWith(
              color: appColors.grass.withValues(alpha: 0.78),
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
            color: appColors.grass.withValues(alpha: 0.62),
            fontSize: 28,
            height: 0.98,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          style: appTextStyles.label.copyWith(
            color: appColors.grass.withValues(alpha: 0.62),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroMatchCarousel extends StatefulWidget {
  final List<MatchDetails> matches;
  final MatchDetails? fallbackMatch;
  final UserDetails currentUser;

  const _HeroMatchCarousel({
    required this.matches,
    required this.fallbackMatch,
    required this.currentUser,
  });

  @override
  State<_HeroMatchCarousel> createState() => _HeroMatchCarouselState();
}

class _HeroMatchCarouselState extends State<_HeroMatchCarousel> {
  static const double _animationSlack = 0;
  static const double _viewportFraction = 1;

  late final PageController _controller;
  int _currentIndex = 0;

  List<MatchDetails?> get _pages {
    if (widget.matches.isNotEmpty) return widget.matches;
    return <MatchDetails?>[widget.fallbackMatch];
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void didUpdateWidget(covariant _HeroMatchCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pageCount = _pages.length;
    if (_currentIndex >= pageCount) {
      _currentIndex = math.max(0, pageCount - 1);
      if (_controller.hasClients) {
        _controller.jumpToPage(_currentIndex);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                ...List.generate(
                  pages.length,
                  (index) => Opacity(
                    opacity: 0,
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(left: Spacing.md),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _viewportFraction,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: Spacing.sm,
                              bottom: _animationSlack,
                            ),
                            child: _HeroTeamPanel(
                              match: pages[index],
                              currentUser: widget.currentUser,
                              titleOverride: _heroPanelTitle(
                                pages[index],
                                isFirst: index == 0,
                              ),
                              reserveRegistrationActions: true,
                              enableLogoHeroes: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(left: Spacing.md),
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      padEnds: false,
                      clipBehavior: Clip.none,
                      allowImplicitScrolling: true,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _controller,
                          child: Padding(
                            padding: const EdgeInsets.only(right: Spacing.sm),
                            child: _HeroTeamPanel(
                              match: pages[index],
                              currentUser: widget.currentUser,
                              titleOverride: _heroPanelTitle(
                                pages[index],
                                isFirst: index == 0,
                              ),
                              reserveRegistrationActions: true,
                              logoHeroSource: 'home_hero',
                            ),
                          ),
                          builder: (context, child) {
                            var page = _currentIndex.toDouble();
                            if (_controller.hasClients &&
                                _controller.position.haveDimensions) {
                              page = _controller.page ?? page;
                            }

                            final distance =
                                (page - index).abs().clamp(0.0, 1.0);
                            final eased = Curves.easeOutCubic.transform(
                              1 - distance,
                            );
                            final scale = 0.95 + (0.05 * eased);
                            final translateY = 14 * (1 - eased);

                            return Transform.translate(
                              offset: Offset(0, translateY),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.topCenter,
                                child: Opacity(
                                  opacity: 0.72 + (0.28 * eased),
                                  child: child,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (pages.length > 1) ...[
            const SizedBox(height: Spacing.sm),
            _CarouselDots(
              count: pages.length,
              currentIndex: _currentIndex,
            ),
          ],
        ],
      ),
    );
  }

  String? _heroPanelTitle(MatchDetails? match, {required bool isFirst}) {
    if (match == null || match.hasMatchBeenPlayed || isFirst) return null;
    return _matchDate(match.date);
  }
}

class _CarouselDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _CarouselDots({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive
                ? appColors.grass
                : appColors.grass.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _HeroTeamPanel extends StatelessWidget {
  final MatchDetails? match;
  final UserDetails currentUser;
  final String? titleOverride;
  final bool reserveRegistrationActions;
  final bool enableLogoHeroes;
  final String? logoHeroSource;

  const _HeroTeamPanel({
    required this.match,
    required this.currentUser,
    this.titleOverride,
    this.reserveRegistrationActions = false,
    this.enableLogoHeroes = true,
    this.logoHeroSource,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final match = this.match;
    final homeTeam =
        match?.homeTeam ?? currentUser.teamDetails?.title ?? 'Hold';
    final awayTeam = match?.awayTeam ?? 'Modstander';
    final title = titleOverride ??
        (match == null
            ? 'Ingen kamp'
            : match.hasMatchBeenPlayed
                ? _matchDate(match.date)
                : 'Næste kamp');
    final cardHeroTag = match == null || !enableLogoHeroes
        ? null
        : _matchHeroTag(match, logoHeroSource ?? 'home_hero');

    return LayoutBuilder(
      builder: (context, constraints) {
        final pinDetailsToBottom =
            match != null && constraints.hasBoundedHeight;
        final openDetails = match == null
            ? null
            : () => _openMatch(context, match, 'home_hero');

        return Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: openDetails,
            borderRadius: BorderRadius.circular(28),
            child: CustomPaint(
              foregroundPainter: _SideAndBottomBorderPainter(
                color: appColors.grass,
                fadeColor: appColors.white,
                radius: 40,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  Spacing.md,
                ),
                decoration: BoxDecoration(
                  color: appColors.lightGrass55,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.md,
                        Spacing.lg,
                        Spacing.md,
                        Spacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.lightGrass,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: appTextStyles.label.copyWith(
                                color: appColors.grass,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _SmallTeamMark(
                                    name: homeTeam,
                                    teamId: _stableTeamSeed(homeTeam),
                                    heroTag: cardHeroTag == null
                                        ? null
                                        : MatchHeroCard.logoHeroTag(
                                            cardHeroTag,
                                            TeamSide.home,
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  width: 54,
                                  child: Text(
                                    'VS',
                                    textAlign: TextAlign.center,
                                    style: appTextStyles.h5.copyWith(
                                      color: appColors.grass,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _SmallTeamMark(
                                    name: awayTeam,
                                    teamId: _stableTeamSeed(awayTeam),
                                    heroTag: cardHeroTag == null
                                        ? null
                                        : MatchHeroCard.logoHeroTag(
                                            cardHeroTag,
                                            TeamSide.away,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (match == null)
                            Padding(
                              padding: const EdgeInsets.only(top: Spacing.md),
                              child: Text(
                                'Ingen kamp planlagt',
                                style: appTextStyles.buttonSmall.copyWith(
                                  color: appColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    if (match != null) ...[
                      const SizedBox(height: Spacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _FactIcon(
                              icon: Icons.schedule,
                              color: appColors.sky,
                            ),
                            const SizedBox(width: Spacing.md),
                            Expanded(
                              child: _MatchFactColumn(
                                label: 'KAMPSTART',
                                value: _matchTime(match.date),
                              ),
                            ),
                            Expanded(
                              child: _MatchFactColumn(
                                label: 'MØDETID',
                                value: match.meetingTime == null
                                    ? '--:--'
                                    : _clockTime(match.meetingTime!),
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      //Divider(color: appColors.grey3.withValues(alpha: 0.5), height: 1),
                      //const SizedBox(height: Spacing.md),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                        child: Row(
                          children: [
                            _FactIcon(
                              icon: Icons.location_on,
                              color: appColors.error,
                            ),
                            const SizedBox(width: Spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    match.location.isEmpty
                                        ? 'Ingen lokation'
                                        : match.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: appTextStyles.subtitle2.copyWith(
                                      color: appColors.dirt,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _matchDate(match.date),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: appTextStyles.caption2.copyWith(
                                      color: appColors.grey5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: match.location.isEmpty
                                  ? null
                                  : () => _openNavigation(match),
                              child: Text(
                                'Kort ›',
                                style: appTextStyles.buttonSmall.copyWith(
                                  color: appColors.grass,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Divider(
                        color: appColors.grey3.withValues(alpha: 0.5),
                        height: 1,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _MatchResponseCard(
                        match: match,
                        currentUser: currentUser,
                        reserveRegistrationActions: reserveRegistrationActions,
                      ),
                      if (pinDetailsToBottom)
                        const Spacer()
                      else
                        const SizedBox(height: Spacing.sm),
                      _QuietDetailsLink(onPressed: openDetails!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SideAndBottomBorderPainter extends CustomPainter {
  final Color color;
  final Color fadeColor;
  final double radius;

  static const double _strokeWidth = 1;
  static const double _sideTopInset = 20;
  static const double _bottomInset = 0;
  static const double _topFadeLength = 48;

  const _SideAndBottomBorderPainter({
    required this.color,
    required this.fadeColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = _strokeWidth;
    const inset = strokeWidth / 2;
    final effectiveRadius = math.max(0.0, radius - inset);
    final left = inset;
    final right = size.width - inset;
    final bottom = math.max(inset, size.height - _bottomInset - inset);
    final sideStart = _sideTopInset.clamp(0.0, bottom);
    final sideHeight = math.max(1.0, bottom - sideStart);
    final fadeStop = (_topFadeLength / sideHeight).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final sidePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fadeColor,
          color,
          color,
        ],
        stops: [
          0,
          fadeStop,
          1,
        ],
      ).createShader(Rect.fromLTRB(0, sideStart, size.width, bottom));

    canvas.drawLine(
      Offset(left, sideStart),
      Offset(left, bottom - effectiveRadius),
      sidePaint,
    );
    canvas.drawLine(
      Offset(right, sideStart),
      Offset(right, bottom - effectiveRadius),
      sidePaint,
    );

    final bottomPath = Path()
      ..moveTo(left, bottom - effectiveRadius)
      ..quadraticBezierTo(left, bottom, left + effectiveRadius, bottom)
      ..lineTo(right - effectiveRadius, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - effectiveRadius);

    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SideAndBottomBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.fadeColor != fadeColor ||
        oldDelegate.radius != radius;
  }
}

class _FactIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FactIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 17, color: color);
  }
}

class _MatchFactColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _MatchFactColumn({
    required this.label,
    required this.value,
    this.alignEnd = false,
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
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: appTextStyles.label.copyWith(
            color: appColors.grey5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: appTextStyles.subtitle2.copyWith(
            color: appColors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MatchResponseCard extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;
  final bool reserveRegistrationActions;

  const _MatchResponseCard({
    required this.match,
    required this.currentUser,
    this.reserveRegistrationActions = false,
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

    void register() {
      AppAnalytics.logEvent(
        'match_registered',
        parameters: {'source': 'home_next_match'},
      );
      final teamId = currentUser.teamDetails?.id ?? 0;
      context.read<HomeCubit>().registerForMatch(match.id, teamId);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.lightGrass55,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isRegistered ? 'Du er tilmeldt' : 'Kommer du?',
                  style: appTextStyles.body3.copyWith(
                    color: appColors.grass,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _MatchSignupSummary(
                count: match.registeredCount,
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Stack(
            children: [
              if (reserveRegistrationActions)
                Opacity(
                  opacity: 0,
                  child: IgnorePointer(
                    child: Row(
                      children: [
                        Expanded(
                          child: _KopaChoiceButton(
                            label: 'Ja, jeg kommer',
                            icon: Icons.how_to_reg,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: _KopaChoiceButton(
                            label: 'Nej',
                            icon: Icons.close,
                            outlined: true,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isRegistered)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ingen opgaver',
                    style: appTextStyles.caption2.copyWith(
                      color: appColors.dirt,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _KopaChoiceButton(
                        label: isRegistering ? 'Tilmeldes' : 'Ja, jeg kommer',
                        icon: Icons.how_to_reg,
                        onPressed: isRegistering ? null : register,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: _KopaChoiceButton(
                        label: 'Nej',
                        icon: Icons.close,
                        outlined: true,
                        onPressed: () =>
                            _openMatch(context, match, 'home_decline'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchSignupSummary extends StatelessWidget {
  final int count;

  const _MatchSignupSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: appColors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.statCard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_2_outlined, size: 16, color: appColors.primary),
          const SizedBox(width: Spacing.xs),
          Text(
            '$count',
            style: appTextStyles.subtitle2.copyWith(
              color: palette.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'tilmeldt',
            style: appTextStyles.caption3.copyWith(
              color: palette.onSurfaceMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietDetailsLink extends StatelessWidget {
  final VoidCallback onPressed;

  const _QuietDetailsLink({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Text(
              'Se kampdetaljer →',
              style: appTextStyles.buttonSmall.copyWith(
                color: appColors.grass,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KopaChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;

  const _KopaChoiceButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final enabled = onPressed != null;
    final backgroundColor = outlined ? appColors.white : appColors.grass;
    final foregroundColor = outlined ? appColors.grass : appColors.white;
    final borderColor = outlined ? appColors.grass : appColors.grass;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
              border: Border.all(color: borderColor, width: outlined ? 1.5 : 0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 18),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.buttonSmall.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BentoSectionTitle(title: 'Seneste kamp'),
        const SizedBox(height: Spacing.sm),
        _LatestResultCard(
          match: latestMatch,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        const _BentoSectionTitle(title: 'Stilling'),
        const SizedBox(height: Spacing.sm),
        _QuickTableCard(
          standings: standings,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        const _BentoSectionTitle(title: 'Statistikker'),
        const SizedBox(height: Spacing.sm),
        _StatisticsStrip(
          stats: statistics,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        const _BentoSectionTitle(title: 'Bødekasse'),
        const SizedBox(height: Spacing.sm),
        _FineBoxBentoCard(
          fineBox: fineBox,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}

class _BentoSectionTitle extends StatelessWidget {
  final String title;

  const _BentoSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: appTextStyles.h5.copyWith(
          color: palette.onSurface,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatisticsStrip extends StatelessWidget {
  final StatisticsResponse? stats;
  final UserDetails currentUser;

  const _StatisticsStrip({
    required this.stats,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final stats = this.stats;

    if (stats == null) {
      return _BentoCard(
        color: appColors.grey2,
        padding: const EdgeInsets.all(Spacing.lg),
        child: Text(
          'Ingen statistik tilgængelig',
          style: appTextStyles.caption1.copyWith(color: appColors.grey5),
        ),
      );
    }

    final tiles = [
      PlayerPlusStatTileData(
        title: 'Pointsnit',
        value: _currentLeaderboardValue(
          stats.leaderboards.bestPointsAverage,
          decimal: true,
        ),
        rank: _rankFor(stats.leaderboards.bestPointsAverage),
        rows: _leaderboardRows(
          stats.leaderboards.bestPointsAverage,
          decimal: true,
        ),
        icon: Icons.trending_up,
        accentColor: appColors.grass,
      ),
      PlayerPlusStatTileData(
        title: 'Mål',
        value: stats.player.goalsScored.toString(),
        rank: _rankFor(stats.leaderboards.topScorers),
        rows: _leaderboardRows(stats.leaderboards.topScorers),
        icon: Icons.sports_score,
        accentColor: appColors.sky,
      ),
      PlayerPlusStatTileData(
        title: 'Assists',
        value: stats.player.assists.toString(),
        rank: _rankFor(stats.leaderboards.assists),
        rows: _leaderboardRows(stats.leaderboards.assists),
        icon: Icons.handshake,
        accentColor: appColors.success,
      ),
      PlayerPlusStatTileData(
        title: 'Kampe',
        value: stats.player.matchesPlayed.toString(),
        rank: _rankFor(stats.leaderboards.matchesPlayed),
        rows: _leaderboardRows(stats.leaderboards.matchesPlayed),
        icon: Icons.sports_soccer,
        accentColor: appColors.sunset,
      ),
      PlayerPlusStatTileData(
        title: 'Stemmer',
        value: _currentLeaderboardValue(stats.leaderboards.mostVotes),
        rank: _rankFor(stats.leaderboards.mostVotes),
        rows: _leaderboardRows(stats.leaderboards.mostVotes),
        icon: Icons.how_to_vote,
        accentColor: appColors.dirt,
      ),
      PlayerPlusStatTileData(
        title: 'In-form',
        value: _currentInFormValue(),
        rank: _rankForInForm(),
        rows: _inFormRows(),
        icon: Icons.local_fire_department,
        accentColor: appColors.error,
      ),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: PlayerPlusAccess.temporaryUnlocked,
      builder: (context, hasPlayerPlus, _) => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: tiles.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: Spacing.md),
          itemBuilder: (context, index) => PlayerPlusStatTile(
            data: tiles[index],
            currentUserId: currentUser.id,
            locked: !hasPlayerPlus,
            width: 156,
            padding: const EdgeInsets.all(12),
            valueFontSize: 28,
            titleFontSize: 14,
            rankFontSize: 11,
            obscureValue: !hasPlayerPlus && index >= tiles.length - 2,
            obscureRank: !hasPlayerPlus,
            showShadow: true,
            backgroundColor: appColors.white,
          ),
        ),
      ),
    );
  }

  List<PlayerPlusStatRankingRow> _leaderboardRows(
    List<LeaderboardRow> rows, {
    bool decimal = false,
  }) {
    return rows
        .map(
          (row) => PlayerPlusStatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: decimal
                ? row.value.toDouble().toStringAsFixed(1)
                : '${row.value}',
          ),
        )
        .toList();
  }

  List<PlayerPlusStatRankingRow> _inFormRows() {
    final stats = this.stats;
    if (stats == null) return const [];

    return stats.inFormRows
        .map(
          (row) => PlayerPlusStatRankingRow(
            userId: row.userId,
            userName: row.userName,
            value: '${row.points}',
            suffix: 'point',
          ),
        )
        .toList();
  }

  String _currentLeaderboardValue(
    List<LeaderboardRow> rows, {
    bool decimal = false,
  }) {
    final row = _currentLeaderboardRow(rows);
    if (row == null) return '-';
    return decimal ? row.value.toDouble().toStringAsFixed(1) : '${row.value}';
  }

  LeaderboardRow? _currentLeaderboardRow(List<LeaderboardRow> rows) {
    final stats = this.stats;
    if (stats == null) return null;

    for (final row in rows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return row;
      }
    }
    return null;
  }

  int? _rankFor(List<LeaderboardRow> rows) {
    final stats = this.stats;
    if (stats == null) return null;

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }

  String _currentInFormValue() {
    final stats = this.stats;
    if (stats == null) return '-';

    for (final row in stats.inFormRows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return '${row.points}';
      }
    }
    return '-';
  }

  int? _rankForInForm() {
    final stats = this.stats;
    if (stats == null) return null;

    for (var i = 0; i < stats.inFormRows.length; i++) {
      final row = stats.inFormRows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }
}

class _LatestResultCard extends StatefulWidget {
  final MatchDetails? match;
  final UserDetails currentUser;

  const _LatestResultCard({
    required this.match,
    required this.currentUser,
  });

  @override
  State<_LatestResultCard> createState() => _LatestResultCardState();
}

class _LatestResultCardState extends State<_LatestResultCard> {
  bool _showAllEvents = false;

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);
    final match = widget.match;
    final score = match == null
        ? '--'
        : '${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0}';
    final resultLabel = _resultLabel(match, widget.currentUser);
    final motm = match?.matchPollDetails?.playerOfTheMatchDetails.name;
    final events = [...?match?.matchEventDetailsList]
      ..sort((a, b) => (b.minute ?? 0).compareTo(a.minute ?? 0));
    final goalCount =
        events.where((event) => event.type == MatchEventType.goal).length;
    final yellowCardCount =
        events.where((event) => event.type == MatchEventType.yellowCard).length;
    final redCardCount =
        events.where((event) => event.type == MatchEventType.redCard).length;
    final cardHeroTag =
        match == null ? null : _matchHeroTag(match, 'home_latest');

    return _BentoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      color: palette.surfaceLow,
      child: InkWell(
        onTap: match == null
            ? null
            : () => _openMatch(context, match, 'home_latest'),
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
                  heroTag: cardHeroTag == null
                      ? null
                      : MatchHeroCard.logoHeroTag(
                          cardHeroTag,
                          TeamSide.home,
                        ),
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
                  heroTag: cardHeroTag == null
                      ? null
                      : MatchHeroCard.logoHeroTag(
                          cardHeroTag,
                          TeamSide.away,
                        ),
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
            if (match != null) ...[
              const SizedBox(height: Spacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kamphistorik',
                  style: appTextStyles.label.copyWith(
                    color: palette.onSurfaceMuted,
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
                      color: palette.onSurfaceMuted,
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
                      foregroundColor: palette.onSurface,
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
    final palette = _HomePalette(appColors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: appColors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.outline.withValues(alpha: 0.32)),
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
                  color: palette.onSurface,
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
              color: palette.onSurfaceMuted,
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
    final palette = _HomePalette(appColors);

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
                color: palette.onSurfaceMuted,
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
                color: palette.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: appTextStyles.caption3.copyWith(
              color: palette.onSurfaceMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _latestResultEventLabel(MatchEventDetails event) {
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

class _SmallTeamMark extends StatelessWidget {
  final String name;
  final int? teamId;
  final String? heroTag;

  const _SmallTeamMark({
    required this.name,
    required this.teamId,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final palette = _HomePalette(appColors);

    final badge = Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appColors.white.withValues(alpha: 0.74),
        boxShadow: [
          BoxShadow(
            color: appColors.dirt.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: appColors.dirt.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TeamAvatar(
        teamName: name,
        teamId: teamId ?? 0,
        radius: 22,
      ),
    );

    return SizedBox(
      width: 86,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallLogoHero(tag: heroTag, child: badge),
          const SizedBox(height: Spacing.xs),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: appTextStyles.caption3.copyWith(
              color: palette.onSurfaceMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLogoHero extends StatelessWidget {
  final String? tag;
  final Widget child;

  const _SmallLogoHero({
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    if (tag == null) return child;

    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: Material(
        type: MaterialType.transparency,
        child: child,
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
    final allRows = standings?.rows ?? const <DbuStandingRow>[];
    final topRows = allRows.take(3).toList();
    final standingsLabel = standings?.seriesName?.trim().isNotEmpty == true
        ? standings!.seriesName!.trim()
        : standings?.poolId == null
            ? 'Serie'
            : 'Serie ${standings!.poolId}';
    final currentTeamRow = allRows.cast<DbuStandingRow?>().firstWhere(
          (row) => row != null && _isCurrentTeam(row, currentUser, standings),
          orElse: () => null,
        );
    final showCurrentTeamBelow = currentTeamRow != null &&
        !topRows.any((row) => _isSameStandingRow(row, currentTeamRow));

    return _BentoCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openStandings(context, standings, currentUser),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                color: palette.statCard,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'STILLING - $standingsLabel',
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
        ),
      ),
    );
  }
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
    final palette = _HomePalette(appColors);
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
            child: Row(
              children: [
                TeamAvatar(
                  teamName: row.teamName,
                  teamId: row.dbuTeamId,
                  colorSourceUrl: row.logoUrl,
                  radius: 10,
                ),
                const SizedBox(width: Spacing.sm),
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
        border: Border.all(color: palette.statCard),
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

String _matchDate(DateTime date) {
  final localDate = date.toLocal();
  final weekday = DateFormat('EEEE', 'da_DK').format(localDate);
  final capitalizedWeekday =
      '${weekday.substring(0, 1).toUpperCase()}${weekday.substring(1)}';
  return '$capitalizedWeekday ${DateFormat('d. MMMM', 'da_DK').format(localDate)}';
}

String _matchTime(DateTime date) {
  return DateFormat('HH:mm').format(date.toLocal());
}

String _clockTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
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
        heroTag: _matchHeroTag(match, source),
      ),
    ),
  );
}

String _matchHeroTag(MatchDetails match, String source) {
  return 'home-match-${match.id}-$source';
}

void _openFineBox(BuildContext context) {
  AppAnalytics.logEvent('fine_box_opened');
  Navigator.of(context).push(MaterialWithModalsPageRoute(
    builder: (context) => const TeamFinesPage(),
  ));
}

Future<void> _openNavigation(MatchDetails match) async {
  final query = Uri.encodeComponent(match.location);
  final uri =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _HomePalette {
  final AppColors colors;

  const _HomePalette(this.colors);

  Color get surface => colors.white;
  Color get surfaceLow => colors.lightGrass55;
  Color get surfaceRaised => colors.grey2;
  Color get highlightCard => colors.lightGrass;
  Color get statCard => colors.grass;
  Color get heroStart => colors.lightGrass;
  Color get heroEnd => colors.white;
  Color get onSurface => colors.dirt;
  Color get onSurfaceMuted => colors.grey5;
  Color get onHighlight => colors.dirt;
  Color get outline => colors.grey3;
}
