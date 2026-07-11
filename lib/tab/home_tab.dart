import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/component/home/home_calendar_overlay.dart';
import 'package:kopa/component/home/home_fine_box_card.dart';
import 'package:kopa/component/home/home_statistics_strip.dart';
import 'package:kopa/component/home/latest_result_card.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/standings/standings_preview_card.dart';
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

    return PageScaffold.tab(
      title: 'Kopa',
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/logos/logomark_outline_foreground.svg',
            height: 32,
            colorFilter: ColorFilter.mode(appColors.grass, BlendMode.srcIn),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            'Kopa',
            style: appTextStyles.h5.copyWith(
              color: appColors.grass,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      trailing: [
        BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) => previous.matches != current.matches,
          builder: (context, state) => IconButton(
            tooltip: 'Kalender',
            onPressed: () => showHomeCalendarOverlay(
              context: context,
              events: state.matches,
              onEventTap: (match) =>
                  _openMatch(context, match, 'home_calendar'),
            ),
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ),
        IconButton(
          tooltip: 'Notifikationer',
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.lg + _heroPanelGradientOverlap,
      ),
      decoration: BoxDecoration(color: appColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            color: appColors.grass,
            fontSize: 28,
            height: 0.98,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label.toUpperCase(),
          style: appTextStyles.label.copyWith(
            color: appColors.grass,
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
                    padding: const EdgeInsets.only(left: Spacing.sm),
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                0,
                0,
                0,
                Spacing.md,
              ),
              decoration: BoxDecoration(
                color: appColors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: appColors.grass),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TeamBadgeLabel(
                                  teamName: homeTeam,
                                  teamId: stableTeamSeed(homeTeam),
                                  heroTag: cardHeroTag == null
                                      ? null
                                      : MatchHeroCard.logoHeroTag(
                                          cardHeroTag,
                                          TeamSide.home,
                                        ),
                                  width: 86,
                                  radius: 22,
                                  labelStyle: appTextStyles.caption3.copyWith(
                                    color: appColors.grey5,
                                    fontWeight: FontWeight.w700,
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
                                child: TeamBadgeLabel(
                                  teamName: awayTeam,
                                  teamId: stableTeamSeed(awayTeam),
                                  heroTag: cardHeroTag == null
                                      ? null
                                      : MatchHeroCard.logoHeroTag(
                                          cardHeroTag,
                                          TeamSide.away,
                                        ),
                                  width: 86,
                                  radius: 22,
                                  labelStyle: appTextStyles.caption3.copyWith(
                                    color: appColors.grey5,
                                    fontWeight: FontWeight.w700,
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
        );
      },
    );
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
        color: appColors.white,
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: appColors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColors.grass,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_2_outlined, size: 16, color: appColors.primary),
          const SizedBox(width: Spacing.xs),
          Text(
            '$count',
            style: appTextStyles.subtitle2.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            'tilmeldt',
            style: appTextStyles.caption3.copyWith(
              color: appColors.grey5,
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
        const HomeBentoSectionTitle(title: 'Seneste kamp'),
        const SizedBox(height: Spacing.sm),
        HomeLatestResultCard(
          match: latestMatch,
          currentUser: currentUser,
          onOpenMatch: (match) => _openMatch(context, match, 'home_latest'),
          matchHeroTag: _matchHeroTag,
        ),
        const SizedBox(height: Spacing.md),
        const HomeBentoSectionTitle(title: 'Stilling'),
        const SizedBox(height: Spacing.sm),
        StandingsPreviewCard(
          standings: standings,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        const HomeBentoSectionTitle(title: 'Statistikker'),
        const SizedBox(height: Spacing.sm),
        HomeStatisticsStrip(
          stats: statistics,
          currentUser: currentUser,
        ),
        const SizedBox(height: Spacing.md),
        const HomeBentoSectionTitle(title: 'Bødekasse'),
        const SizedBox(height: Spacing.sm),
        HomeFineBoxCard(
          fineBox: fineBox,
          currentUser: currentUser,
          onOpenFineBox: () => _openFineBox(context),
        ),
        const SizedBox(height: Spacing.sm),
      ],
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
