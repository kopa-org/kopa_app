import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/match_programme_cubit.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/create_match_page.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
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

  final appColors = AppColors.light;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchProgrammeCubit()..loadMatches(),
      child: PageScaffold.tab(
        title: 'Kampprogram',
        floatingActionButton: FutureHandler<UserDetails>(
          future: currentUser,
          loadingIndicator: const SizedBox.shrink(),
          onError: (_) => const SizedBox.shrink(),
          onSuccess: (context, user) {
            if (!user.isTeamOwner) return const SizedBox.shrink();

            return FloatingActionButton(
              heroTag: 'create-match-fab',
              tooltip: 'Opret kamp',
              backgroundColor:
                  Theme.of(context).extension<AppColors>()?.lightGrass ??
                      Colors.green,
              onPressed: () => _showCreateMatch(context),
              child: Icon(Icons.add, color: appColors.dirt),
            );
          },
        ),
        body: const _MatchProgrammeRefreshListener(
          child: _MatchList(),
        ),
      ),
    );
  }

  Future<void> _showCreateMatch(BuildContext context) async {
    final cubit = context.read<MatchProgrammeCubit>();
    await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (modalContext) => BlocProvider.value(
        value: cubit,
        child: CreateMatchPage(matches: cubit.state.matches),
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
    _matchRefreshNotifier.addListener(_refreshMatchesAfterImport);
  }

  @override
  void dispose() {
    _matchRefreshNotifier.removeListener(_refreshMatchesAfterImport);
    super.dispose();
  }

  void _refreshMatchesAfterImport() {
    context.read<MatchProgrammeCubit>().loadMatches(showLoading: false);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchProgrammeCubit, MatchProgrammeState>(
      builder: (context, state) {
        if (state.status == MatchProgrammeStatus.failure) {
          return const ErrorMessage(
            message: 'Der skete en fejl. Prøv venligst igen senere.',
          );
        }

        if (state.isLoading) {
          return const LoadingIndicator();
        }

        _syncMatchKeys(state.matches);
        _scheduleInitialScroll(state.matches);

        return _buildMatchList(context, state.matches);
      },
    );
  }

  Widget _buildMatchList(BuildContext context, List<MatchDetails> matches) {
    if (matches.isEmpty) {
      return const Center(child: Text('Ingen kampe fundet.'));
    }

    final ownTeamName =
        context.read<AuthCubit>().state.user?.teamDetails?.title;

    return ListView(
      key: _listViewKey,
      controller: _scrollController,
      padding: Spacing.screenPadding,
      children: [
        AllGamesCard(
          matches: matches,
          ownTeamName: ownTeamName,
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
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (context.mounted) {
      context.read<MatchProgrammeCubit>().loadMatches(showLoading: false);
    }
  }
}
