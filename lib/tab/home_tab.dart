import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/player_plus_stat_tile.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/cubits/home_state.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_type.dart';
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
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final currentUser = context.read<AuthCubit>().state.user;
    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    return PageScaffold(
      title: 'Forside',
      showBackButton: false,
      showTopBar: false,
      backgroundColor: appColors.offWhite,
      body: RefreshIndicator(
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

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ColoredBox(
                color: appColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopIntro(
                      currentUser: currentUser,
                      matches: state.matches,
                    ),
                    const SizedBox(height: Spacing.xl),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.nextMatch != null) ...[
                            _NextMatchCard(
                              match: state.nextMatch!,
                              currentUser: currentUser,
                            ),
                            const SizedBox(height: Spacing.xl),
                          ],
                          if (state.lastMatch != null) ...[
                            _LatestMatchCard(match: state.lastMatch!),
                            const SizedBox(height: Spacing.xl),
                          ],
                          if (state.statistics != null) ...[
                            _SectionTitle('Placering'),
                            _PlacementCard(
                              stats: state.statistics!.club,
                              teamName:
                                  currentUser.teamDetails?.title ?? 'Hold',
                            ),
                            const SizedBox(height: Spacing.xl),
                            _SectionTitle('Statistik'),
                            _StatisticsStrip(
                              stats: state.statistics!,
                              currentUser: currentUser,
                            ),
                            const SizedBox(height: Spacing.xl),
                          ],
                          if (state.fineBox != null) ...[
                            _SectionTitle('Bødekassen'),
                            _FineBoxCard(
                              fineBox: state.fineBox!,
                              currentUser: currentUser,
                            ),
                            const SizedBox(height: Spacing.xl),
                          ],
                          if (state.matches.isNotEmpty) ...[
                            _AllGamesCard(matches: state.matches),
                            const SizedBox(height: Spacing.xl),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopIntro extends StatefulWidget {
  final UserDetails currentUser;
  final List<MatchDetails> matches;

  const _TopIntro({
    required this.currentUser,
    required this.matches,
  });

  @override
  State<_TopIntro> createState() => _TopIntroState();
}

class _TopIntroState extends State<_TopIntro> {
  static const _dayWidth = 44.0;

  late final DateTime _today;
  late final DateTime _calendarStart;
  late final int _todayIndex;
  late final int _dayCount;
  late final ScrollController _calendarController;
  late DateTime _firstVisibleDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _calendarStart = DateTime(_today.year - 10, _today.month, _today.day);
    final calendarEnd = DateTime(_today.year + 10, _today.month, _today.day);
    _todayIndex = _today.difference(_calendarStart).inDays;
    _dayCount = calendarEnd.difference(_calendarStart).inDays + 1;
    _firstVisibleDay = _today;
    _calendarController = ScrollController(
      initialScrollOffset: _todayIndex * _dayWidth,
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  bool _handleCalendarScroll(ScrollNotification notification) {
    final firstVisibleIndex =
        (notification.metrics.pixels / _dayWidth).floor().clamp(0, _dayCount);
    final firstVisibleDay =
        _calendarStart.add(Duration(days: firstVisibleIndex));
    if (!_sameDay(firstVisibleDay, _firstVisibleDay)) {
      setState(() => _firstVisibleDay = firstVisibleDay);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final firstName = widget.currentUser.name.split(' ').first;
    final sortedMatches = [...widget.matches]
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 0),
      decoration: BoxDecoration(
        color: appColors.offWhite,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Spacing.borderRadiusLargeIncreased),
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: appColors.sunset,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/illustrations/kopa_thumb.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  'Velkommen,\n$firstName!',
                  style: appTextStyles.h5.copyWith(color: appColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Divider(color: appColors.primary.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Text(
                _monthLabel(
                  _firstVisibleDay,
                  _firstVisibleDay.add(const Duration(days: 6)),
                ),
                style: appTextStyles.body3.copyWith(color: appColors.grey4),
              ),
              const Spacer(),
              _LegendDot(label: 'Kamp', color: appColors.sunset),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 66,
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleCalendarScroll,
              child: ListView.builder(
                controller: _calendarController,
                scrollDirection: Axis.horizontal,
                itemExtent: _dayWidth,
                itemCount: _dayCount,
                itemBuilder: (context, index) {
                  final day = _calendarStart.add(Duration(days: index));
                  return _CalendarDay(
                    date: day,
                    isToday: _sameDay(day, _today),
                    match: _matchOn(day, sortedMatches),
                    onMatchTap: (match) =>
                        _openMatch(context, match, 'home_calendar'),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.toLocal().year == b.toLocal().year &&
      a.toLocal().month == b.toLocal().month &&
      a.toLocal().day == b.toLocal().day;

  static MatchDetails? _matchOn(
    DateTime day,
    List<MatchDetails> sortedMatches,
  ) {
    for (final match in sortedMatches) {
      if (_sameDay(day, match.date)) return match;
    }
    return null;
  }

  static String _monthLabel(DateTime first, DateTime last) {
    final formatter = DateFormat.MMMM('da_DK');
    final firstMonth = formatter.format(first);
    if (first.month == last.month && first.year == last.year) {
      return firstMonth;
    }
    return '$firstMonth–${formatter.format(last)}';
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      children: [
        Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: appTextStyles.caption3.copyWith(color: appColors.grey4)),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final MatchDetails? match;
  final ValueChanged<MatchDetails> onMatchTap;

  const _CalendarDay({
    required this.date,
    required this.isToday,
    required this.match,
    required this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final hasMatch = match != null;

    return Semantics(
      button: hasMatch,
      label: hasMatch
          ? 'Åbn kamp ${DateFormat.yMMMMd('da_DK').format(date)}'
          : DateFormat.yMMMMd('da_DK').format(date),
      child: InkWell(
        onTap: hasMatch ? () => onMatchTap(match!) : null,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          width: 34,
          child: Column(
            children: [
              Text(
                DateFormat.E('da_DK')
                    .format(date)
                    .substring(0, 1)
                    .toUpperCase(),
                style: appTextStyles.caption3.copyWith(color: appColors.grey4),
              ),
              const SizedBox(height: Spacing.sm),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? appColors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(
                          color: appColors.primary.withValues(alpha: 0.2),
                        )
                      : null,
                ),
                child: Text(
                  '${date.day}',
                  style: appTextStyles.body3.copyWith(
                    color: appColors.primary,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: hasMatch ? appColors.sunset : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextMatchCard extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;

  const _NextMatchCard({required this.match, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final countdown = match.countdown;
    final isPast = countdown.isNegative;
    final days = countdown.inDays;
    final hours = countdown.inHours % 24;
    final minutes = countdown.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.grey2,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Næste kamp', style: appTextStyles.h5),
          ),
          const SizedBox(height: Spacing.sm),
          _MatchTimes(match: match),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.md),
            decoration: BoxDecoration(
              color: appColors.grass,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
            ),
            child: isPast
                ? Text(
                    'Kampen er startet',
                    style: appTextStyles.h5.copyWith(color: appColors.sun),
                    textAlign: TextAlign.center,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CountdownUnit(value: days, label: 'd'),
                      _CountdownUnit(value: hours, label: 't'),
                      _CountdownUnit(value: minutes, label: 'm'),
                    ],
                  ),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(child: _TeamBadge(name: match.homeTeam ?? 'Hjemme')),
              Text('vs', style: appTextStyles.body3),
              Expanded(child: _TeamBadge(name: match.awayTeam ?? 'Ude')),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Divider(color: appColors.divider.withValues(alpha: 0.45)),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: _MapPreview(
                  location: match.location,
                  onTap: () => _openNavigation(match),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _AttendancePanel(
                  match: match,
                  currentUser: currentUser,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Divider(color: appColors.divider.withValues(alpha: 0.45)),
          const SizedBox(height: Spacing.md),
          const _TaskList(),
          const SizedBox(height: Spacing.md),
          Divider(color: appColors.divider.withValues(alpha: 0.45)),
          const SizedBox(height: Spacing.md),
          _PrimaryFigmaButton(
            label: 'Se kampdetaljer',
            onTap: () => _openMatch(context, match, 'home_next_match'),
          ),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownUnit({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: appTextStyles.h4.copyWith(color: appColors.sun),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: appTextStyles.caption2.copyWith(color: appColors.sun),
        ),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final String name;

  const _TeamBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Column(
      children: [
        AppAvatar(initials: _initials(name), radius: 33),
        const SizedBox(height: Spacing.sm),
        Text(
          name,
          style: appTextStyles.caption1.copyWith(color: AppColors.light.dirt),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  final String location;
  final VoidCallback onTap;

  const _MapPreview({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: appColors.lightGrass55,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
          border: Border.all(color: appColors.grey3.withValues(alpha: 0.35)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapLinesPainter(appColors: appColors),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                location,
                style: appTextStyles.caption3.copyWith(color: appColors.sunset),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius:
                      BorderRadius.circular(Spacing.borderRadiusSmall),
                ),
                child: Icon(Icons.navigation_outlined,
                    color: appColors.grey7, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendancePanel extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;

  const _AttendancePanel({required this.match, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final state = context.watch<HomeCubit>().state;

    return Container(
      height: 96,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      ),
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
                    Text('Tilmeldte:',
                        style: appTextStyles.caption3
                            .copyWith(color: appColors.grey4)),
                    Text('${match.registeredCount}', style: appTextStyles.h3),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: match.isCurrentUserRegistered
                      ? appColors.lightGrass55
                      : appColors.lightSky65,
                  borderRadius:
                      BorderRadius.circular(Spacing.borderRadiusSmall),
                ),
                child: Text(
                  match.isCurrentUserRegistered
                      ? 'Du er\ntilmeldt'
                      : 'Ikke\ntilmeldt',
                  style: appTextStyles.caption3.copyWith(
                    color: match.isCurrentUserRegistered
                        ? appColors.primary
                        : appColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!match.isCurrentUserRegistered)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: state.isRegisteringForNextMatch
                    ? null
                    : () {
                        AppAnalytics.logEvent(
                          'match_registered',
                          parameters: {'source': 'home_next_match'},
                        );
                        final teamId = currentUser.teamDetails?.id ?? 0;
                        context
                            .read<HomeCubit>()
                            .registerForMatch(match.id, teamId);
                      },
                borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: appColors.lightSky65,
                    borderRadius:
                        BorderRadius.circular(Spacing.borderRadiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.isRegisteringForNextMatch
                            ? 'Tilmelder'
                            : 'Tilmeld',
                        style: appTextStyles.buttonSmall,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchTimes extends StatelessWidget {
  final MatchDetails match;

  const _MatchTimes({required this.match});

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat('dd-MM-yy HH:mm');
    final matchStart = match.date.toLocal();
    final meetingTime = match.meetingTime;
    final meetingDateTime = meetingTime == null
        ? null
        : DateTime(
            matchStart.year,
            matchStart.month,
            matchStart.day,
            meetingTime.hour,
            meetingTime.minute,
          );

    return Column(
      children: [
        _MatchTimeRow(
          label: 'Kampstart',
          value: dateTimeFormat.format(matchStart),
        ),
        const SizedBox(height: Spacing.xs),
        _MatchTimeRow(
          label: 'Mødetid',
          value: meetingDateTime == null
              ? 'Ikke angivet'
              : dateTimeFormat.format(meetingDateTime),
        ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList();

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
          'Opgaver:',
          style: appTextStyles.caption3.copyWith(color: appColors.grey4),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 10),
          decoration: BoxDecoration(
            color: appColors.white,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
          ),
          child: Text(
            'Ingen opgaver',
            style: appTextStyles.body3.copyWith(color: appColors.grey4),
          ),
        ),
      ],
    );
  }
}

class _MatchTimeRow extends StatelessWidget {
  final String label;
  final String value;

  const _MatchTimeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      children: [
        Text('$label:', style: appTextStyles.body4),
        const Spacer(),
        Text(
          value,
          style: appTextStyles.body3.copyWith(color: appColors.grey7),
        ),
      ],
    );
  }
}

class _PrimaryFigmaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryFigmaButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
        decoration: BoxDecoration(
          color: appColors.lightGrass,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        ),
        child: Row(
          children: [
            Text(label, style: appTextStyles.subtitle1),
            const Spacer(),
            Icon(Icons.arrow_forward, color: appColors.dirt),
          ],
        ),
      ),
    );
  }
}

class _LatestMatchCard extends StatelessWidget {
  final MatchDetails match;

  const _LatestMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final score = '${match.homeTeamScore ?? 0}:${match.awayTeamScore ?? 0}';
    final scorers = match.matchEventDetailsList
            ?.where((event) => event.type == MatchEventType.goal)
            .take(2)
            .map((event) => _goalLine(event.goalscorerUserName, event.minute))
            .toList() ??
        [];
    final motm =
        match.matchPollDetails?.playerOfTheMatchDetails.name ?? 'Ingen valgt';

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.lightSky95,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Seneste kamp', style: appTextStyles.h5),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEE dd.MM', 'da_DK').format(match.date),
            style: appTextStyles.caption2.copyWith(color: appColors.grey5),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _TeamBadge(name: match.homeTeam ?? 'Hjemme')),
              Text(score, style: appTextStyles.h2),
              Expanded(child: _TeamBadge(name: match.awayTeam ?? 'Ude')),
            ],
          ),
          if (scorers.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(child: _ScorerList(scorers: scorers)),
                Expanded(child: _ScorerList(scorers: scorers)),
              ],
            ),
          ],
          const SizedBox(height: Spacing.md),
          Divider(color: appColors.grey5.withValues(alpha: 0.4)),
          const SizedBox(height: Spacing.sm),
          Text('Kampens spiller', style: appTextStyles.body3),
          Text(motm,
              style: appTextStyles.caption2.copyWith(color: appColors.grey5)),
          const SizedBox(height: Spacing.md),
          _SecondaryFigmaButton(
            label: 'Se kampdetaljer',
            onTap: () => _openMatch(context, match, 'home_last_match'),
          ),
        ],
      ),
    );
  }
}

class _ScorerList extends StatelessWidget {
  final List<String> scorers;

  const _ScorerList({required this.scorers});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final scorer in scorers)
          Text(scorer,
              style:
                  appTextStyles.caption3.copyWith(color: AppColors.light.dirt)),
      ],
    );
  }
}

class _SecondaryFigmaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryFigmaButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 14),
        decoration: BoxDecoration(
          color: appColors.lightSky65,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
        ),
        child: Row(
          children: [
            Text(label, style: appTextStyles.subtitle1),
            const Spacer(),
            Icon(Icons.arrow_forward, color: appColors.dirt),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: appTextStyles.h5),
      ),
    );
  }
}

class _PlacementCard extends StatelessWidget {
  final ClubStats stats;
  final String teamName;

  const _PlacementCard({required this.stats, required this.teamName});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final rows = List.generate(10, (index) => index + 1);

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.primary,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      ),
      child: Column(
        children: [
          _PlacementRow(
            cells: const ['Placering', 'Hold', 'V', 'T', 'U', 'P'],
            isHeader: true,
            stats: stats,
            teamName: teamName,
          ),
          const SizedBox(height: Spacing.sm),
          for (final number in rows)
            _PlacementRow(
              cells: [
                '$number.',
                teamName,
                number == 1 ? '${stats.wins}' : '0',
                number == 1 ? '${stats.losses}' : '0',
                number == 1 ? '${stats.draws}' : '0',
                number == 1 ? '${stats.wins * 3 + stats.draws}' : '0',
              ],
              isHeader: false,
              stats: stats,
              teamName: teamName,
              shaded: number.isOdd,
            ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Målscore ${stats.goalsFor}-${stats.goalsAgainst}',
            style: appTextStyles.caption1.copyWith(color: appColors.lightGrass),
          ),
        ],
      ),
    );
  }
}

class _PlacementRow extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;
  final ClubStats stats;
  final String teamName;
  final bool shaded;

  const _PlacementRow({
    required this.cells,
    required this.isHeader,
    required this.stats,
    required this.teamName,
    this.shaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final style = (isHeader ? appTextStyles.caption2 : appTextStyles.body4)
        .copyWith(color: isHeader ? appColors.offWhite : appColors.lightGrass);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: shaded
            ? appColors.black.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
      ),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(cells[0], style: style)),
          Expanded(
            child: Row(
              children: [
                if (!isHeader) ...[
                  AppAvatar(initials: _initials(teamName), radius: 10),
                  const SizedBox(width: Spacing.xs),
                ],
                Expanded(
                  child: Text(cells[1],
                      style: style, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          for (final cell in cells.skip(2))
            SizedBox(
              width: 28,
              child: Text(cell, style: style, textAlign: TextAlign.right),
            ),
        ],
      ),
    );
  }
}

class _StatisticsStrip extends StatelessWidget {
  final StatisticsResponse stats;
  final UserDetails currentUser;

  const _StatisticsStrip({required this.stats, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
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
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              PlayerPlusStatTile(
                data: tiles[i],
                currentUserId: currentUser.id,
                locked: !hasPlayerPlus,
                width: 156,
                padding: const EdgeInsets.all(12),
                valueFontSize: 28,
                titleFontSize: 14,
                rankFontSize: 11,
                obscureValue: !hasPlayerPlus && i >= tiles.length - 2,
                obscureRank: !hasPlayerPlus,
                showShadow: true,
                backgroundColor: appColors.white,
              ),
            ],
          ],
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
    for (final row in rows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return row;
      }
    }
    return null;
  }

  int? _rankFor(List<LeaderboardRow> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }

  String _currentInFormValue() {
    for (final row in stats.inFormRows) {
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return '${row.points}';
      }
    }
    return '-';
  }

  int? _rankForInForm() {
    for (var i = 0; i < stats.inFormRows.length; i++) {
      final row = stats.inFormRows[i];
      if (row.userId == currentUser.id || row.userName == stats.player.name) {
        return i + 1;
      }
    }
    return null;
  }
}

class _FineBoxCard extends StatelessWidget {
  final FineBoxDetails fineBox;
  final UserDetails currentUser;

  const _FineBoxCard({required this.fineBox, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final personalFines = _personalFines(fineBox, currentUser);

    if (!currentUser.isTeamOwner) {
      return _PlayerFineBoxCard(
        totalAmount: personalFines.$1,
        owedAmount: personalFines.$2,
      );
    }

    final personalAmount = personalFines.$2;
    final projectedTotal = fineBox.currentAmount + fineBox.totalOwedAmount;

    return InkWell(
      onTap: () {
        AppAnalytics.logEvent('fine_box_opened');
        Navigator.of(context).push(MaterialWithModalsPageRoute(
          builder: (context) => const TeamFinesPage(),
        ));
      },
      borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      child: Container(
        height: 278,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: appColors.lightSky55,
          borderRadius:
              BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: CustomPaint(
                painter: _FineGaugePainter(
                  appColors: appColors,
                  currentAmount: fineBox.currentAmount,
                  owedAmount: fineBox.totalOwedAmount,
                  personalAmount: personalAmount,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total saldo:',
                      style: appTextStyles.caption3
                          .copyWith(color: appColors.grey4)),
                  Text('${projectedTotal.toStringAsFixed(0)},-',
                      style: appTextStyles.h3),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FineChip(
                      label: 'Nuværende saldo',
                      color: appColors.lightGrass,
                      value: fineBox.currentAmount),
                  _FineChip(
                      label: 'Manglende beløb',
                      color: appColors.sunset,
                      value: fineBox.totalOwedAmount),
                  _FineChip(
                      label: 'Din bødekasse',
                      color: appColors.sky,
                      value: personalAmount),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  Text('Gå til bødekassen', style: appTextStyles.buttonSmall),
                  const SizedBox(width: Spacing.sm),
                  Icon(Icons.arrow_forward, color: appColors.dirt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (double, double) _personalFines(
      FineBoxDetails fineBox, UserDetails currentUser) {
    try {
      final myFineDetails = fineBox.userFineDetails
          .firstWhere((u) => u.userDetails.id == currentUser.id);
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
}

class _PlayerFineBoxCard extends StatelessWidget {
  final double totalAmount;
  final double owedAmount;

  const _PlayerFineBoxCard({
    required this.totalAmount,
    required this.owedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InkWell(
      onTap: () {
        AppAnalytics.logEvent('fine_box_opened');
        Navigator.of(context).push(MaterialWithModalsPageRoute(
          builder: (context) => const TeamFinesPage(),
        ));
      },
      borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: appColors.lightSky55,
          borderRadius:
              BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Din bødekasse', style: appTextStyles.h3),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: _PersonalFineMetric(
                    label: 'Samlet beløb i bøder',
                    value: totalAmount,
                    color: appColors.sky,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _PersonalFineMetric(
                    label: 'Du skylder',
                    value: owedAmount,
                    color: appColors.sunset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gå til bødekassen', style: appTextStyles.buttonSmall),
                  const SizedBox(width: Spacing.sm),
                  Icon(Icons.arrow_forward, color: appColors.dirt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalFineMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _PersonalFineMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${value.toStringAsFixed(0)},-',
            style: appTextStyles.h3.copyWith(color: appColors.dirt),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: appTextStyles.caption3.copyWith(color: appColors.dirt),
          ),
        ],
      ),
    );
  }
}

class _FineChip extends StatelessWidget {
  final String label;
  final Color color;
  final double value;

  const _FineChip(
      {required this.label, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Tooltip(
      message: '${value.toStringAsFixed(0)} kr.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
        ),
        child: Text(
          label.toUpperCase(),
          style: appTextStyles.label.copyWith(color: AppColors.light.dirt),
        ),
      ),
    );
  }
}

class _AllGamesCard extends StatelessWidget {
  final List<MatchDetails> matches;

  const _AllGamesCard({required this.matches});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final sortedMatches = [...matches]
      ..sort((a, b) => b.date.compareTo(a.date));
    final rows = sortedMatches.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.grey2,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Alle kampe', style: appTextStyles.h5),
          ),
          const SizedBox(height: Spacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Serie 1',
                style: appTextStyles.caption3.copyWith(color: appColors.grey3)),
          ),
          const SizedBox(height: Spacing.md),
          if (rows.isEmpty)
            Text('Ingen kampe endnu', style: appTextStyles.body3)
          else
            ...rows.indexed.expand((entry) sync* {
              final index = entry.$1;
              final match = entry.$2;
              yield _GameResultRow(match: match);
              if (index != rows.length - 1) {
                yield const SizedBox(height: Spacing.md);
              }
            }),
        ],
      ),
    );
  }
}

class _GameResultRow extends StatelessWidget {
  final MatchDetails match;

  const _GameResultRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final homeScore = match.homeTeamScore;
    final awayScore = match.awayTeamScore;
    final homeScoreValue = homeScore ?? 0;
    final awayScoreValue = awayScore ?? 0;
    final result = homeScoreValue == awayScoreValue
        ? 'UAFGJORT'
        : homeScoreValue > awayScoreValue
            ? 'SEJR'
            : 'TABT';
    final resultColor = result == 'SEJR'
        ? appColors.success
        : result == 'TABT'
            ? appColors.error
            : appColors.sunset;
    final resultTextColor =
        result == 'SEJR' ? appColors.lightGrass : appColors.offWhite;

    return InkWell(
      onTap: () => _openMatch(context, match, 'home_all_games'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE dd.MM', 'da_DK').format(match.date),
            style: appTextStyles.caption3.copyWith(color: appColors.grey5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                child: match.hasMatchBeenPlayed
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: resultColor,
                            borderRadius:
                                BorderRadius.circular(Spacing.borderRadiusFull),
                          ),
                          child: Text(result,
                              style: appTextStyles.label
                                  .copyWith(color: resultTextColor)),
                        ),
                      )
                    : Text(DateHelper.getFormattedTime(match.date),
                        style: appTextStyles.buttonSmall
                            .copyWith(color: appColors.grey5)),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GameTeamLine(
                        name: match.homeTeam ?? 'Hjemme', score: homeScore),
                    const SizedBox(height: 6),
                    _GameTeamLine(
                        name: match.awayTeam ?? 'Ude', score: awayScore),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameTeamLine extends StatelessWidget {
  final String name;
  final int? score;

  const _GameTeamLine({required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Row(
      children: [
        AppAvatar(initials: _initials(name), radius: 10),
        const SizedBox(width: Spacing.sm),
        Expanded(
            child: Text(name,
                style: appTextStyles.caption1.copyWith(color: appColors.dirt),
                overflow: TextOverflow.ellipsis)),
        if (score != null)
          Text('$score',
              style: appTextStyles.caption1.copyWith(color: appColors.dirt)),
      ],
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  final AppColors appColors;

  _MapLinesPainter({required this.appColors});

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = appColors.grey3.withValues(alpha: 0.45)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = appColors.sunset
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * .25),
        Offset(size.width, size.height * .1), road);
    canvas.drawLine(
        Offset(size.width * .1, size.height), Offset(size.width * .8, 0), road);
    canvas.drawLine(Offset(0, size.height * .75),
        Offset(size.width, size.height * .85), road);
    canvas.drawCircle(Offset(size.width * .18, size.height * .35), 4, accent);
    canvas.drawCircle(Offset(size.width * .72, size.height * .55), 4, accent);
  }

  @override
  bool shouldRepaint(covariant _MapLinesPainter oldDelegate) => false;
}

class _FineGaugePainter extends CustomPainter {
  final AppColors appColors;
  final double currentAmount;
  final double owedAmount;
  final double personalAmount;

  _FineGaugePainter({
    required this.appColors,
    required this.currentAmount,
    required this.owedAmount,
    required this.personalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0;
    const visibleGap = 5.0;
    final diameter = math.min(size.width - strokeWidth, size.height * 2);
    final radius = diameter / 2;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height),
      width: diameter,
      height: diameter,
    );
    final trackPaint = Paint()
      ..color = appColors.white.withValues(alpha: 0.7)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    final segments = <(double, Color)>[
      (math.max(0, currentAmount), appColors.lightGrass),
      (math.max(0, owedAmount), appColors.sunset),
      (math.max(0, personalAmount), appColors.sky),
    ];
    final total = segments.fold<double>(0, (sum, segment) => sum + segment.$1);
    if (total == 0) {
      return;
    }

    final visibleSegments =
        segments.where((segment) => segment.$1 > 0).toList();
    final gapAngle = (strokeWidth + visibleGap) / radius;
    final totalGapAngle = gapAngle * (visibleSegments.length - 1);
    final availableSweep = math.pi - totalGapAngle;
    var startAngle = math.pi;
    for (final segment in visibleSegments) {
      final sweepAngle = availableSweep * (segment.$1 / total);
      final segmentPaint = Paint()
        ..color = segment.$2
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, segmentPaint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _FineGaugePainter oldDelegate) {
    return oldDelegate.appColors != appColors ||
        oldDelegate.currentAmount != currentAmount ||
        oldDelegate.owedAmount != owedAmount ||
        oldDelegate.personalAmount != personalAmount;
  }
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _goalLine(String name, int? minute) {
  if (minute == null) return name;
  return '$name   $minute\'';
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

Future<void> _openNavigation(MatchDetails match) async {
  final query = Uri.encodeComponent(match.location);
  final uri =
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
