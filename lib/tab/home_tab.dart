import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/card/stat_card.dart';
import 'package:kopa/component/card/task_card.dart';
import 'package:kopa/component/chip/status_chip.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/statistics_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<Map<String, dynamic>> _dashboardData;
  late UserDetails _currentUser;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user != null) {
      _currentUser = user;
      _dashboardData = _fetchDashboardData(user.teamDetails.id);
    } else {
      _dashboardData = Future.error(Exception('User not logged in'));
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardData = _fetchDashboardData(_currentUser.teamDetails.id);
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData(int teamId) async {
    final results = await Future.wait([
      MatchRepository.getMatches(),
      _safeFetchStats(teamId),
      _safeFetchFineBox(),
    ]);

    final matches = results[0] as List<MatchDetails>;
    final statistics = results[1] as StatisticsResponse?;
    final fineBox = results[2] as FineBoxDetails?;

    MatchDetails? nextMatch;
    MatchDetails? lastMatch;

    final now = DateTime.now();
    final unplayedMatches = matches
        .where((m) =>
            !m.hasMatchBeenPlayed &&
            m.date.isAfter(now.subtract(const Duration(days: 1))))
        .toList();
    unplayedMatches.sort((a, b) => a.date.compareTo(b.date));
    if (unplayedMatches.isNotEmpty) {
      nextMatch = unplayedMatches.first;
    }

    final playedMatches = matches.where((m) => m.hasMatchBeenPlayed).toList();
    playedMatches.sort((a, b) => b.date.compareTo(a.date));
    if (playedMatches.isNotEmpty) {
      lastMatch = playedMatches.first;
    }

    return {
      'nextMatch': nextMatch,
      'lastMatch': lastMatch,
      'statistics': statistics,
      'fineBox': fineBox,
    };
  }

  Future<StatisticsResponse?> _safeFetchStats(int teamId) async {
    try {
      return await StatisticsRepository.getStatistics(teamId);
    } catch (e) {
      return StatisticsResponse(
        player: MockData.playerStats,
        club: MockData.clubStats,
      );
    }
  }

  Future<FineBoxDetails?> _safeFetchFineBox() async {
    try {
      return await FinesRepository.getFineBox();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Kopa',
      showBackButton: false,
      backgroundColor: appColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureHandler<Map<String, dynamic>>(
            future: _dashboardData,
            noDataFoundMessage: 'Kunne ikke hente dashboard data',
            onSuccess: (context, data) {
              final nextMatch = data['nextMatch'] as MatchDetails?;
              final lastMatch = data['lastMatch'] as MatchDetails?;
              final stats = data['statistics'] as StatisticsResponse?;
              final fineBox = data['fineBox'] as FineBoxDetails?;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(appColors, appTextStyles),
                    const SizedBox(height: 32),
                    if (nextMatch != null) ...[
                      SectionHeader(
                        title: 'Næste Kamp',
                        actionText: 'Se alle',
                        onActionPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      MatchHeroCard(
                        match: nextMatch,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialWithModalsPageRoute(
                            builder: (context) =>
                                MatchDetailsPage(matchId: nextMatch.id),
                          ))
                              .then((_) => _refreshData());
                        },
                      ),
                      const SizedBox(height: 12),
                      if (!nextMatch.isCurrentUserRegistered)
                        FullWidthButton(
                          buttonText: 'Tilmeld til kamp',
                          onPressed: () async {
                            await MatchRepository.registerForMatch(
                                nextMatch.id);
                            _refreshData();
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                    const SectionHeader(title: 'Praktiske opgaver'),
                    const SizedBox(height: 12),
                    _buildTasksSection(),
                    const SizedBox(height: 32),
                    if (lastMatch != null) ...[
                      const SectionHeader(title: 'Seneste kamp'),
                      const SizedBox(height: 12),
                      _buildLastMatchCard(lastMatch, appColors, appTextStyles),
                      const SizedBox(height: 32),
                    ],
                    if (stats != null) ...[
                      const SectionHeader(title: 'Statistisk highlights'),
                      const SizedBox(height: 12),
                      _buildStatsRow(stats.player),
                      const SizedBox(height: 32),
                    ],
                    if (fineBox != null) ...[
                      const SectionHeader(title: 'Bødekasse'),
                      const SizedBox(height: 12),
                      _buildFineBoxCard(fineBox, appColors, appTextStyles),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(AppColors colors, AppTextStyles styles) {
    final firstName = _currentUser.name.split(' ').first;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Personlig velkommen til\n$firstName',
            style: styles.pageTitle.copyWith(fontSize: 24),
          ),
        ),
        CircleAvatar(
          radius: 36,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, size: 40, color: colors.primary),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Column(
      children: const [
        TaskCard(
          title: 'Snacks',
          statusLabel: 'Manglet',
          status: ChipStatus.warning,
          assignedPersonName: 'Jonas',
        ),
        SizedBox(height: 8),
        TaskCard(
          title: 'Tøjvask',
          statusLabel: 'Klar',
          status: ChipStatus.success,
          assignedPersonName: 'Emil',
        ),
        SizedBox(height: 8),
        TaskCard(
          title: 'Carpool (3 pladser)',
          statusLabel: 'Åben',
          status: ChipStatus.info,
          assignedPersonName: 'Peter',
        ),
      ],
    );
  }

  Widget _buildLastMatchCard(
      MatchDetails match, AppColors colors, AppTextStyles styles) {
    final resultStr =
        '${match.homeTeam ?? "Hjemme"} ${match.homeTeamScore ?? 0} - ${match.awayTeamScore ?? 0} ${match.awayTeam ?? "Ude"}';

    final motm =
        match.matchPollDetails?.playerOfTheMatchDetails.name ?? 'Ingen valgt';

    final goalScorers = match.matchEventDetailsList
            ?.where((e) => e.type == MatchEventType.goal)
            .map((e) => e.goalscorerUserName)
            .toList() ??
        [];

    final goalStr = goalScorers.isEmpty ? 'Ingen mål' : goalScorers.join(', ');

    return KopaCard(
      onTap: () {
        Navigator.of(context).push(MaterialWithModalsPageRoute(
          builder: (context) => MatchDetailsPage(matchId: match.id),
        ));
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resultStr,
              style: styles.bodyBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              DateHelper.getFormattedDate(match.date),
              style: styles.caption,
            ),
            const SizedBox(height: 16),
            Text('Kampens spiller: $motm', style: styles.body),
            const SizedBox(height: 4),
            Text('Mål: $goalStr', style: styles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(PlayerStats stats) {
    return Row(
      children: [
        Expanded(
            child: StatCard(
          label: 'Mål',
          value: '${stats.goalsScored}',
          icon: Icons.sports_soccer,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: StatCard(
          label: 'Assist',
          value: '${stats.assists}',
          icon: Icons.handshake,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: StatCard(
          label: 'Kampe',
          value: '${stats.matchesPlayed}',
          icon: Icons.calendar_today,
        )),
      ],
    );
  }

  Widget _buildFineBoxCard(
      FineBoxDetails fineBox, AppColors colors, AppTextStyles styles) {
    double myFines = 0.0;
    try {
      final myFineDetails = fineBox.userFineDetails
          .firstWhere((u) => u.userDetails.id == _currentUser.id);
      myFines = myFineDetails.fineDetailsList
          .where((f) => !f.hasBeenPaid)
          .fold(0.0, (sum, f) => sum + f.owedAmount);
    } catch (_) {
      // User not found in finebox or no fines
    }

    return KopaCard(
      onTap: () {
        Navigator.of(context).push(MaterialWithModalsPageRoute(
          builder: (context) => const TeamFinesPage(),
        ));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFineRow('Nuværende saldo:',
              '${fineBox.currentAmount.toStringAsFixed(0)} kr.', styles),
          const SizedBox(height: 8),
          _buildFineRow('Din saldo:', '${myFines.toStringAsFixed(0)} kr.',
              styles,
              highlight: myFines > 0),
          const SizedBox(height: 8),
          _buildFineRow('Total manglende betaling:',
              '${fineBox.totalOwedAmount.toStringAsFixed(0)} kr.', styles),
        ],
      ),
    );
  }

  Widget _buildFineRow(String label, String value, AppTextStyles styles,
      {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: styles.body),
        Text(value,
            style: styles.bodyBold
                .copyWith(color: highlight ? Colors.red : null)),
      ],
    );
  }
}