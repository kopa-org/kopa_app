import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/expandable_fab.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/scaffold/tab_page_header.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/match_programme_cubit.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/event_type.dart';
import 'package:kopa/page/match/create_match_page.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/component/season/season_selector.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MatchProgrammePage extends StatefulWidget {
  const MatchProgrammePage({super.key});

  @override
  State<MatchProgrammePage> createState() => _MatchProgrammePageState();
}

class _MatchProgrammePageState extends State<MatchProgrammePage> {
  late Future<UserDetails> currentUser;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(
          Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
    return BlocProvider(
      create: (_) {
        final cubit = MatchProgrammeCubit()..loadMatches();
        if (teamId != null) cubit.loadSeasons(teamId);
        return cubit;
      },
      child: PageScaffold.tab(
        title: AppLocalizations.of(context)!.uiMatchSchedule,
        floatingActionButton: FutureHandler<UserDetails>(
          future: currentUser,
          loadingIndicator: const SizedBox.shrink(),
          onError: (_) => const SizedBox.shrink(),
          // Everybody on the team can add matches and trainings.
          onSuccess: (context, user) {
            if (user.teamDetails == null) return const SizedBox.shrink();
            final l10n = AppLocalizations.of(context)!;

            // Finished seasons are read-only, so hide the create actions.
            final isViewingPastSeason = context.select(
              (MatchProgrammeCubit cubit) => cubit.state.isViewingPastSeason,
            );
            if (isViewingPastSeason) return const SizedBox.shrink();

            // Arc of icon actions, styled like the match details FAB.
            return ExpandableFab(
              distance: 104,
              openButtonKey: const ValueKey('create-match-fab'),
              heroTag: 'create-match-fab',
              tooltip: l10n.eventCreateTitle,
              backgroundColor: AppColors.matchDetailsHeader,
              foregroundColor: colors.white,
              children: [
                FloatingActionButton(
                  heroTag: 'create-match-fab-match',
                  tooltip: l10n.eventCreateMatch,
                  backgroundColor: colors.surface,
                  foregroundColor: AppColors.matchDetailsHeader,
                  onPressed: () =>
                      _showCreateEvent(context, KopaEventType.match),
                  child: const Icon(Icons.sports_soccer),
                ),
                FloatingActionButton(
                  heroTag: 'create-match-fab-training',
                  tooltip: l10n.eventCreateTraining,
                  backgroundColor: colors.surface,
                  foregroundColor: colors.sky,
                  onPressed: () =>
                      _showCreateEvent(context, KopaEventType.training),
                  child: const Icon(Icons.fitness_center),
                ),
              ],
            );
          },
        ),
        body: const _MatchProgrammeRefreshListener(
          child: _MatchList(),
        ),
      ),
    );
  }

  Future<void> _showCreateEvent(
    BuildContext context,
    KopaEventType eventType,
  ) async {
    final cubit = context.read<MatchProgrammeCubit>();
    if (!context.mounted) return;

    await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (modalContext) => BlocProvider.value(
        value: cubit,
        child: CreateMatchPage(
          matches: cubit.state.matches,
          eventType: eventType,
        ),
      ),
    );
  }
}

class _MatchProgrammeRefreshListener extends StatefulWidget {
  final Widget child;

  const _MatchProgrammeRefreshListener({required this.child});

  @override
  State<_MatchProgrammeRefreshListener> createState() =>
      _MatchProgrammeRefreshListenerState();
}

class _MatchProgrammeRefreshListenerState
    extends State<_MatchProgrammeRefreshListener> {
  late final MatchProgrammeRefreshNotifier _matchRefreshNotifier;

  @override
  void initState() {
    super.initState();
    _matchRefreshNotifier = context.read<MatchProgrammeRefreshNotifier>();
    _matchRefreshNotifier.addListener(_refreshMatchesAfterChange);
  }

  @override
  void dispose() {
    _matchRefreshNotifier.removeListener(_refreshMatchesAfterChange);
    super.dispose();
  }

  void _refreshMatchesAfterChange() {
    final cubit = context.read<MatchProgrammeCubit>();
    cubit.loadMatches(
      showLoading: false,
      forceRefresh: true,
    );
    // A change elsewhere may have started a new season.
    final teamId = context.read<AuthCubit>().state.user?.teamDetails?.id;
    if (teamId != null) cubit.loadSeasons(teamId);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MatchList extends StatefulWidget {
  const _MatchList();

  @override
  State<_MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<_MatchList> {
  final _scrollController = ScrollController();
  final _listViewKey = GlobalKey();
  final Map<int, GlobalKey> _matchKeys = {};
  bool _hasScheduledInitialScroll = false;
  int? _scrolledSeasonId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchProgrammeCubit, MatchProgrammeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MatchProgrammeHeader(state: state),
            Expanded(child: _buildContent(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MatchProgrammeState state) {
    if (state.status == MatchProgrammeStatus.failure) {
      return ErrorMessage(
        message:
            AppLocalizations.of(context)!.uiSomethingWentWrongPleaseTryAgain,
      );
    }

    if (state.isLoading) {
      return const LoadingIndicator();
    }

    // Each season opens at its start, then (for the active season) scrolls to
    // the latest played match.
    if (_scrolledSeasonId != state.selectedSeasonId) {
      _scrolledSeasonId = state.selectedSeasonId;
      _hasScheduledInitialScroll = false;
    }
    _syncMatchKeys(state.matches);
    if (!state.isViewingPastSeason) _scheduleInitialScroll(state.matches);

    return _buildMatchList(context, state);
  }

  Widget _buildMatchList(BuildContext context, MatchProgrammeState state) {
    final matches = state.matches;
    final pastSeason = state.isViewingPastSeason ? state.selectedSeason : null;
    final l10n = AppLocalizations.of(context)!;
    final ownTeamName =
        context.read<AuthCubit>().state.user?.teamDetails?.title;
    final ownTeamLogoDesign =
        context.read<AuthCubit>().state.user?.teamDetails?.logoDesign;
    final currentUserId = context.read<AuthCubit>().state.user?.id;
    final canManageTeam =
        context.read<AuthCubit>().state.user?.canManageTeam ?? false;

    if (matches.isEmpty && pastSeason == null) {
      return Center(child: Text(l10n.uiNoMatchesFound));
    }

    return ListView(
      key: _listViewKey,
      controller: _scrollController,
      padding: Spacing.screenPadding.copyWith(
        top: Spacing.sm,
        bottom:
            Spacing.screenPadding.bottom + mainTabBottomContentPadding(context),
      ),
      children: [
        if (pastSeason != null) ...[
          PastSeasonBanner(
            season: pastSeason,
            onBackToCurrent: () =>
                context.read<MatchProgrammeCubit>().showActiveSeason(),
          ),
          const SizedBox(height: Spacing.sm),
          SeasonResultSummary(matches: matches, ownTeamName: ownTeamName),
          const SizedBox(height: Spacing.itemGap),
        ],
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
            child: Text(
              l10n.matchSeasonNoMatches,
              textAlign: TextAlign.center,
            ),
          )
        else
          AllGamesCard(
            matches: matches,
            ownTeamName: ownTeamName,
            ownTeamLogoDesign: ownTeamLogoDesign,
            currentUserId: currentUserId,
            canManageTeam: canManageTeam,
            matchItemKeys: _matchKeys,
            onMatchTap: (match) => _openMatch(context, match),
          ),
      ],
    );
  }

  void _syncMatchKeys(List<MatchDetails> matches) {
    final matchIds = matches.map((match) => match.id).toSet();
    _matchKeys.removeWhere((matchId, _) => !matchIds.contains(matchId));

    for (final match in matches) {
      _matchKeys.putIfAbsent(match.id, GlobalKey.new);
    }
  }

  void _scheduleInitialScroll(List<MatchDetails> matches) {
    if (_hasScheduledInitialScroll || matches.isEmpty) return;

    _hasScheduledInitialScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToLatestPlayedMatchIfNeeded(matches);
    });
  }

  void _scrollToLatestPlayedMatchIfNeeded(List<MatchDetails> matches) {
    if (!_scrollController.hasClients) return;

    final sortedMatches = matches.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final unplayedMatches = sortedMatches
        .where((match) => !match.hasMatchBeenPlayed)
        .toList(growable: false);

    if (unplayedMatches.isNotEmpty &&
        _areAllMatchesFullyVisible(unplayedMatches)) {
      return;
    }

    final targetMatch = _latestPlayedMatch(sortedMatches);
    if (targetMatch == null) return;

    final targetContext = _matchKeys[targetMatch.id]?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  bool _areAllMatchesFullyVisible(List<MatchDetails> matches) {
    final listRenderObject = _listViewKey.currentContext?.findRenderObject();
    if (listRenderObject is! RenderBox) return false;

    final viewportTop = listRenderObject.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + listRenderObject.size.height;

    for (final match in matches) {
      final renderObject =
          _matchKeys[match.id]?.currentContext?.findRenderObject();
      if (renderObject is! RenderBox) return false;

      final itemTop = renderObject.localToGlobal(Offset.zero).dy;
      final itemBottom = itemTop + renderObject.size.height;
      if (itemTop < viewportTop || itemBottom > viewportBottom) return false;
    }

    return true;
  }

  MatchDetails? _latestPlayedMatch(List<MatchDetails> sortedMatches) {
    for (final match in sortedMatches.reversed) {
      if (match.hasMatchBeenPlayed) return match;
    }

    return null;
  }

  Future<void> _openMatch(
    BuildContext context,
    MatchDetails matchDetails,
  ) async {
    AppAnalytics.logEvent(
      'match_opened',
      parameters: {'source': 'match_programme'},
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(
          matchId: matchDetails.id,
          initialMatch: matchDetails,
          showBottomNavigationBar: false,
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (context.mounted) {
      context.read<MatchProgrammeCubit>().loadMatches(
            showLoading: false,
            forceRefresh: true,
          );
    }
  }
}

/// Page title with the season selector underneath.
class _MatchProgrammeHeader extends StatelessWidget {
  final MatchProgrammeState state;

  const _MatchProgrammeHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final season = state.selectedSeason;
    final canChangeSeason = state.seasons.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.sm,
      ),
      child: TabPageHeader(
        title: AppLocalizations.of(context)!.uiMatchSchedule,
        bottom: season == null
            ? null
            : SeasonSelectorButton(
                season: season,
                onTap: canChangeSeason ? () => _pickSeason(context) : null,
              ),
      ),
    );
  }

  Future<void> _pickSeason(BuildContext context) async {
    final cubit = context.read<MatchProgrammeCubit>();
    final picked = await showSeasonPicker(
      context,
      seasons: cubit.state.seasons,
      selected: cubit.state.selectedSeason,
    );
    if (picked != null) await cubit.selectSeason(picked);
  }
}
