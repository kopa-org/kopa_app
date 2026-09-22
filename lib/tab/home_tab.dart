import 'dart:async';
import 'dart:math' as math;

import 'package:flip_counter_plus/flip_counter_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/home/home_bento_card.dart';
import 'package:kopa/component/home/home_calendar_overlay.dart';
import 'package:kopa/component/home/home_fine_box_card.dart';
import 'package:kopa/component/home/home_statistics_strip.dart';
import 'package:kopa/component/home/latest_result_card.dart';
import 'package:kopa/component/match/match_result_reminder.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/standings/standings_preview_card.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/page/match/match_score_sheet.dart';
import 'package:kopa/page/profile/profile_settings_page.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

const double _homeHeaderActionSize = 40;

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

class _HomeTabView extends StatefulWidget {
  const _HomeTabView();

  @override
  State<_HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<_HomeTabView> {
  late final MatchProgrammeRefreshNotifier _matchRefreshNotifier;

  @override
  void initState() {
    super.initState();
    _matchRefreshNotifier = context.read<MatchProgrammeRefreshNotifier>();
    _matchRefreshNotifier.addListener(_refreshDashboardAfterImport);
  }

  @override
  void dispose() {
    _matchRefreshNotifier.removeListener(_refreshDashboardAfterImport);
    super.dispose();
  }

  void _refreshDashboardAfterImport() {
    final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
    if (teamId == null) return;

    context.read<HomeCubit>().fetchDashboardData(
          teamId,
          showLoading: false,
          forceRefresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final currentUser = context.watch<AuthCubit>().state.user;

    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    return PageScaffold.tab(
      title: 'Kopa',
      backgroundColor: appColors.offWhite,
      showTopBar: false,
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
            final latestMatch = state.lastMatch ??
                (playedMatches.isEmpty ? null : playedMatches.last);
            void openCalendar() {
              showHomeCalendarOverlay(
                context: context,
                events: state.matches,
                onEventTap: (match) =>
                    _openMatch(context, match, 'home_calendar'),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: appColors.offWhite,
                  foregroundColor: appColors.grass,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  pinned: false,
                  floating: false,
                  snap: false,
                  centerTitle: true,
                  title: Row(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/logos/logomark_outline_foreground.svg',
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          appColors.grass,
                          BlendMode.srcIn,
                        ),
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
                  actions: [
                    _HomeHeaderActionButton(
                      tooltip: 'Kalender',
                      icon: Icons.calendar_today_outlined,
                      onPressed: openCalendar,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.md),
                      child: _HomeHeaderActionButton(
                        tooltip: 'Profil',
                        icon: Icons.account_circle_outlined,
                        onPressed: () => _openProfileSettings(context),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _HeroMatchCarousel(
                    matches: upcomingMatches,
                    fallbackMatch: nextMatch,
                    currentUser: currentUser,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
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
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: mainTabBottomContentPadding(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final MatchDetails? nextMatch;

  const _HeroSection({
    required this.nextMatch,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final countdownLabel = nextMatch == null
        ? 'Ingen kommende kamp'
        : nextMatch!.isTraining
            ? l10n.homeTrainingCountdownLabel
            : l10n.homeMatchCountdownLabel;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.lg,
      ),
      decoration: BoxDecoration(color: appColors.offWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.sm),
          Text(
            countdownLabel,
            style: appTextStyles.caption2.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 38,
                    child: _HeroCountdown(
                      target: nextMatch?.date,
                      selectionKey: nextMatch?.id,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _HomeHeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(_homeHeaderActionSize),
        minimumSize: const Size.square(_homeHeaderActionSize),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        icon,
        color: appColors.dirt,
      ),
    );
  }
}

class _HeroCountdown extends StatefulWidget {
  final DateTime? target;
  final Object? selectionKey;

  const _HeroCountdown({
    required this.target,
    required this.selectionKey,
  });

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
    if (oldWidget.target != widget.target ||
        oldWidget.selectionKey != widget.selectionKey) {
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
    final styles = _displayStyle(context).copyWith(
      color: appColors.dirt,
      fontSize: 32,
      height: 0.98,
    );

    if (widget.target == null) {
      return Text(
        'Planen opdateres',
        style: styles.copyWith(fontSize: 30),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _HeroCountdownPart(
          value: _remaining.inDays,
          suffix: 'd',
          style: styles,
        ),
        const SizedBox(width: 24),
        _HeroCountdownPart(
          value: _remaining.inHours % 24,
          suffix: 't',
          style: styles,
        ),
        const SizedBox(width: 24),
        _HeroCountdownPart(
          value: _remaining.inMinutes % 60,
          suffix: 'm',
          style: styles,
        ),
      ],
    );
  }
}

class _HeroCountdownPart extends StatelessWidget {
  final int value;
  final String suffix;
  final TextStyle style;

  const _HeroCountdownPart({
    required this.value,
    required this.suffix,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRect(
            child: AnimatedFlipCounter(
              value: value,
              wholeDigits: 2,
              duration: const Duration(milliseconds: 300),
              transitionType: CounterTransitionType.roll,
              increasingColor: appColors.primary,
              decreasingColor: appColors.error,
              colorFadeDuration: const Duration(milliseconds: 500),
              textStyle: style,
              useTabularFigures: true,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            suffix,
            style: style.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
          _HeroSection(
            nextMatch: pages[_currentIndex],
          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _viewportFraction,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: _animationSlack,
                            ),
                            child: _HeroTeamPanel(
                              match: pages[index],
                              currentUser: widget.currentUser,
                              titleOverride: _heroPanelTitle(
                                pages[index],
                                isFirst: index == 0,
                              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                    ),
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
                          child: _HeroTeamPanel(
                            match: pages[index],
                            currentUser: widget.currentUser,
                            titleOverride: _heroPanelTitle(
                              pages[index],
                              isFirst: index == 0,
                            ),
                            logoHeroSource: 'home_hero',
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
  final bool enableLogoHeroes;
  final String? logoHeroSource;

  const _HeroTeamPanel({
    required this.match,
    required this.currentUser,
    this.titleOverride,
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
    final isTraining = match?.isTraining == true;
    final homeTeam =
        match?.homeTeam ?? currentUser.teamDetails?.title ?? 'Hold';
    final awayTeam = match?.awayTeam ?? 'Modstander';
    final ownTeamName = currentUser.teamDetails?.title;
    final ownTeamLogo = currentUser.teamDetails?.logoDesign;
    final title = titleOverride ??
        (match == null ? 'Ingen kamp' : _matchDate(match.date));
    final heroRadius = BorderRadius.circular(HomeBentoCard.cardRadius);
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
          borderRadius: heroRadius,
          child: InkWell(
            onTap: openDetails,
            borderRadius: heroRadius,
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
                borderRadius: heroRadius,
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
                    padding: isTraining
                        ? const EdgeInsets.fromLTRB(
                            Spacing.md,
                            14,
                            Spacing.md,
                            14,
                          )
                        : const EdgeInsets.fromLTRB(
                            Spacing.md,
                            14,
                            Spacing.md,
                            28,
                          ),
                    decoration: BoxDecoration(
                      color: isTraining
                          ? appColors.lightSky65
                          : appColors.lightGrass,
                      borderRadius: heroRadius,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: appTextStyles.caption.copyWith(
                                  color: appColors.dirt,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (match != null && currentUser.isTeamOwner)
                              MatchResultReminderButton(
                                match: match,
                                backgroundColor: appColors.sunset,
                                onPressed: () =>
                                    _openMatchResultReminder(context, match),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (isTraining)
                          _TrainingHeroEventContent(
                            category: match?.category,
                            colors: appColors,
                            textStyles: appTextStyles,
                          )
                        else
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: TeamBadgeLabel(
                                      teamName: homeTeam,
                                      teamId: stableTeamSeed(homeTeam),
                                      logoDesign: ownTeamName != null &&
                                              teamNamesMatch(
                                                  homeTeam, ownTeamName)
                                          ? ownTeamLogo
                                          : null,
                                      heroTag: cardHeroTag == null
                                          ? null
                                          : MatchHeroCard.logoHeroTag(
                                              cardHeroTag,
                                              TeamSide.home,
                                            ),
                                      width: 86,
                                      radius: 22,
                                      labelStyle:
                                          appTextStyles.caption.copyWith(
                                        color: appColors.dirt,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 54,
                                  child: Text(
                                    'VS',
                                    textAlign: TextAlign.center,
                                    style: appTextStyles.h5.copyWith(
                                      color: appColors.dirt,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: TeamBadgeLabel(
                                      teamName: awayTeam,
                                      teamId: stableTeamSeed(awayTeam),
                                      logoDesign: ownTeamName != null &&
                                              teamNamesMatch(
                                                  awayTeam, ownTeamName)
                                          ? ownTeamLogo
                                          : null,
                                      heroTag: cardHeroTag == null
                                          ? null
                                          : MatchHeroCard.logoHeroTag(
                                              cardHeroTag,
                                              TeamSide.away,
                                            ),
                                      width: 86,
                                      radius: 22,
                                      labelStyle:
                                          appTextStyles.caption.copyWith(
                                        color: appColors.dirt,
                                        fontWeight: FontWeight.w800,
                                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                      ),
                      child: _MatchInfoList(
                        match: match,
                        onOpenNavigation: match.location.isEmpty
                            ? null
                            : () => _openNavigation(match),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Divider(
                      color: appColors.grey3.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: Spacing.sm),
                    HomeMatchResponseCard(
                      match: match,
                      currentUser: currentUser,
                    ),
                    if (pinDetailsToBottom) const Spacer()
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

class _TrainingHeroEventContent extends StatelessWidget {
  final String? category;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _TrainingHeroEventContent({
    this.category,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Icon(Icons.fitness_center, color: colors.sky, size: 32),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.eventTraining,
          style: textStyles.h5.copyWith(
            color: colors.dirt,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (category?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            category!.trim(),
            style: textStyles.body3.copyWith(color: colors.grey5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _MatchInfoList extends StatelessWidget {
  static const _primaryTextColor = Color(0xFF111827);
  static const _labelTextColor = Color(0xFF4B5563);
  static const _mutedTextColor = Color(0xFF9CA3AF);
  static const _dividerColor = Color(0xFFE5E7EB);
  static const _actionColor = Color(0xFF059669);

  final MatchDetails match;
  final VoidCallback? onOpenNavigation;

  const _MatchInfoList({
    required this.match,
    required this.onOpenNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = AppLocalizations.of(context)!;
    final meetingTime = match.meetingTime;
    final location = match.location.isEmpty ? 'Ingen lokation' : match.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _MatchInfoListRow(
          icon: Icons.schedule_outlined,
          iconColor: appColors.sky,
          label: match.isTraining ? l10n.eventTrainingTime : 'Kampstart',
          value: _matchTime(match.date),
          valueColor: _primaryTextColor,
        ),
        if (!match.isTraining) ...[
          const _MatchInfoDivider(),
          _MatchInfoListRow(
            icon: Icons.access_time,
            iconColor: appColors.sunset,
            label: 'Mødetid',
            value: meetingTime == null ? '--:--' : _clockTime(meetingTime),
            valueColor:
                meetingTime == null ? _mutedTextColor : _primaryTextColor,
          ),
        ],
        const _MatchInfoDivider(),
        _MatchInfoListRow(
          icon: Icons.location_on_outlined,
          iconColor: appColors.error,
          label: location,
          actionLabel: 'Kort ›',
          onAction: onOpenNavigation,
        ),
      ],
    );
  }
}

class _MatchInfoListRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final Color? valueColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MatchInfoListRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final actionLabel = this.actionLabel;
    final value = this.value;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 22),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.body3.copyWith(
                color: _MatchInfoList._labelTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: _MatchInfoList._actionColor,
              ),
              child: Text(
                actionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appTextStyles.body4.copyWith(
                  color: _MatchInfoList._actionColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (value != null)
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: appTextStyles.subtitle2.copyWith(
                color: valueColor ?? _MatchInfoList._primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchInfoDivider extends StatelessWidget {
  const _MatchInfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _MatchInfoList._dividerColor,
      ),
    );
  }
}

class HomeMatchResponseCard extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;

  const HomeMatchResponseCard({
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
    final isUnavailable = match.isCurrentUserAttending == false;

    void register() {
      AppAnalytics.logEvent(
        'match_registered',
        parameters: {'source': 'home_next_match'},
      );
      final teamId = currentUser.teamDetails?.id ?? 0;
      context.read<HomeCubit>().registerForMatch(match.id, teamId);
    }

    void decline() {
      AppAnalytics.logEvent(
        'match_declined',
        parameters: {'source': 'home_next_match'},
      );
      final teamId = currentUser.teamDetails?.id ?? 0;
      context.read<HomeCubit>().declineMatch(match.id, teamId);
    }

    final l10n = AppLocalizations.of(context)!;
    final answered = isRegistered || isUnavailable;
    final statusColor = isUnavailable ? appColors.error : appColors.grass;

    Future<void> changeResponse() async {
      if (isRegistering) return;
      final response = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _AttendanceResponseSheet(
          currentResponse: isRegistered,
          colors: appColors,
          styles: appTextStyles,
          l10n: l10n,
        ),
      );

      if (!context.mounted || response == null || response == isRegistered) {
        return;
      }
      response ? register() : decline();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: answered
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Semantics(
                          button: true,
                          label: l10n.homeAttendanceChange,
                          child: Material(
                            color: statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(
                              Spacing.borderRadiusFull,
                            ),
                            child: InkWell(
                              key: const ValueKey('match_response_status'),
                              onTap: isRegistering ? null : changeResponse,
                              borderRadius: BorderRadius.circular(
                                Spacing.borderRadiusFull,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isRegistered ? Icons.check : Icons.close,
                                      size: 18,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        isRegistering
                                            ? l10n.homeAttendanceSaving
                                            : isRegistered
                                                ? l10n.homeAttendanceGoing
                                                : l10n.homeAttendanceDeclined,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: appTextStyles.body3.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Text(l10n.homeAttendanceQuestion,
                        style: appTextStyles.body3.copyWith(
                            color: appColors.dirt,
                            fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: Spacing.sm),
              _MatchSignupSummary(count: match.registeredCount),
            ],
          ),
          if (!answered) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: _KopaChoiceButton(
                    key: const ValueKey('match_response_decline'),
                    label: l10n.homeAttendanceNo,
                    icon: Icons.close,
                    outlined: true,
                    onPressed: isRegistering ? null : decline,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _KopaChoiceButton(
                    key: const ValueKey('match_response_accept'),
                    label: isRegistering
                        ? l10n.homeAttendanceSaving
                        : l10n.homeAttendanceYes,
                    icon: Icons.how_to_reg,
                    onPressed: isRegistering ? null : register,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceResponseSheet extends StatelessWidget {
  final bool currentResponse;
  final AppColors colors;
  final AppTextStyles styles;
  final AppLocalizations l10n;

  const _AttendanceResponseSheet({
    required this.currentResponse,
    required this.colors,
    required this.styles,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            12,
            Spacing.md,
            Spacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.grey4,
                    borderRadius: BorderRadius.circular(
                      Spacing.borderRadiusFull,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(l10n.homeAttendanceChange, style: styles.sectionHeader),
              const SizedBox(height: Spacing.sm),
              _AttendanceResponseOption(
                key: const ValueKey('attendance_response_yes'),
                label: l10n.homeAttendanceYes,
                icon: Icons.how_to_reg,
                color: colors.grass,
                selected: currentResponse,
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: Spacing.sm),
              _AttendanceResponseOption(
                key: const ValueKey('attendance_response_no'),
                label: l10n.homeAttendanceNo,
                icon: Icons.close,
                color: colors.error,
                selected: !currentResponse,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceResponseOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AttendanceResponseOption({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? color.withValues(alpha: 0.10) : colors.offWhite,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: styles.bodyBold.copyWith(color: colors.dirt),
                  ),
                ),
                if (selected) Icon(Icons.check, color: color, size: 22),
              ],
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
    super.key,
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
    final backgroundColor = outlined ? appColors.white : appColors.primary;
    final foregroundColor = outlined ? appColors.primary : appColors.white;

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
              border: Border.all(
                color: appColors.primary,
                width: outlined ? 1.5 : 0,
              ),
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
              fontWeight: FontWeight.w700,
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
    final featureFlags = context.watch<AppFeatureFlags>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (latestMatch != null) ...[
          const HomeBentoSectionTitle(title: 'Seneste kamp'),
          const SizedBox(height: Spacing.sm),
          HomeLatestResultCard(
            match: latestMatch,
            currentUser: currentUser,
            onOpenMatch: (match) => _openMatch(context, match, 'home_latest'),
            matchHeroTag: _matchHeroTag,
          ),
          const SizedBox(height: Spacing.lg),
        ],
        const HomeBentoSectionTitle(title: 'Stilling'),
        const SizedBox(height: Spacing.sm),
        StandingsPreviewCard(
          standings: standings,
          currentUser: currentUser,
        ),
        if (featureFlags.showStatistics) ...[
          const SizedBox(height: Spacing.lg),
          HomeBentoSectionTitle(
            title: 'Statistikker',
            onAction: () => _openStatistics(context),
          ),
          const SizedBox(height: Spacing.sm),
          HomeStatisticsStrip(
            stats: statistics,
            currentUser: currentUser,
          ),
        ],
        if (featureFlags.showFineBox) ...[
          const SizedBox(height: Spacing.lg),
          HomeBentoSectionTitle(
            title: 'Bødekasse',
            onAction: () => _openFineBox(context),
          ),
          const SizedBox(height: Spacing.sm),
          HomeFineBoxCard(
            fineBox: fineBox,
            currentUser: currentUser,
            onOpenFineBox: () => _openFineBox(context),
          ),
        ],
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
  return state.matches.where((match) => match.hasMatchBeenPlayed).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

Future<void> _openMatchResultReminder(
  BuildContext context,
  MatchDetails match,
) async {
  await showMatchResultReminderDialog(
    context,
    onEnterResult: () => _enterHomeMatchResult(context, match),
  );
}

Future<void> _enterHomeMatchResult(
  BuildContext context,
  MatchDetails match,
) async {
  final score = await showMatchScoreSheet(
    context: context,
    homeTeam: match.homeTeam,
    awayTeam: match.awayTeam,
    homeScore: match.homeTeamScore,
    awayScore: match.awayTeamScore,
    onSave: (home, away) =>
        MatchRepository.updateMatchScore(match.id, home, away),
  );

  if (score == null || !context.mounted) return;

  AppAnalytics.logEvent('match_score_updated');
  final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
  if (teamId == null) return;

  await context.read<HomeCubit>().fetchDashboardData(
        teamId,
        showLoading: false,
        forceRefresh: true,
      );
}

String _matchDate(DateTime date) {
  return DateHelper.getFormattedMatchDate(date);
}

String _matchTime(DateTime date) {
  return DateHelper.getFormattedTime(date);
}

String _clockTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

TextStyle _displayStyle(BuildContext context) {
  final appTextStyles =
      Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
  return appTextStyles.h2.copyWith(
    fontWeight: FontWeight.w700,
  );
}

Future<void> _openMatch(
  BuildContext context,
  MatchDetails match,
  String source,
) async {
  AppAnalytics.logEvent('match_opened', parameters: {'source': source});
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MatchDetailsPage(
        matchId: match.id,
        initialMatch: match,
        heroTag: _matchHeroTag(match, source),
        showBottomNavigationBar: false,
      ),
    ),
  );

  if (!context.mounted) return;

  final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
  if (teamId == null) return;

  await context.read<HomeCubit>().fetchDashboardData(
        teamId,
        showLoading: false,
        forceRefresh: true,
      );
}

String _matchHeroTag(MatchDetails match, String source) {
  return 'home-match-${match.id}-$source';
}

void _openFineBox(BuildContext context) {
  AppAnalytics.logEvent('fine_box_opened');
  context.go(AppRouter.fineBox);
}

void _openProfileSettings(BuildContext context) {
  AppAnalytics.logEvent('profile_settings_opened');
  Navigator.of(context).push(
    MaterialWithModalsPageRoute(
      builder: (context) => const ProfileSettingsPage(),
    ),
  );
}

void _openStatistics(BuildContext context) {
  AppAnalytics.logEvent('statistics_opened');
  context.go(AppRouter.statistics);
}

Future<void> _openNavigation(MatchDetails match) async {
  final query = Uri.encodeComponent(match.location);
  final uri =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
