import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:provider/provider.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/page/match_polls/create_match_poll_page.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/match_polls_cubit.dart';
import 'package:kopa/cubits/match_polls_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MatchPollsListPage extends StatefulWidget {
  const MatchPollsListPage({super.key});

  @override
  State<MatchPollsListPage> createState() => _MatchPollsListPageState();
}

class _MatchPollsListPageState extends State<MatchPollsListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchPollsCubit()..load(),
      child: const _MatchPollsListView(),
    );
  }
}

class _MatchPollsListView extends StatelessWidget {
  const _MatchPollsListView();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return SizedBox(
      height: double.infinity,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGrey6,
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          middle: const Text('Afstemninger'),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context)
                  .popUntil((route) => route.settings.name == '/');
            },
            child: const Icon(
              CupertinoIcons.chevron_left,
              semanticLabel: 'Tilbage',
            ),
          ),
          trailing: user?.isTeamOwner == true
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showCreateMatchPoll(context),
                  child: const Icon(
                    CupertinoIcons.add,
                    semanticLabel: 'Opret afstemning',
                  ),
                )
              : const SizedBox.shrink(),
        ),
        child: SafeArea(
          child: BlocBuilder<MatchPollsCubit, MatchPollsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (state.status == MatchPollsStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      state.errorMessage ?? 'Kunne ikke hente afstemninger.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state.rows.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Ingen afstemninger fundet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: CupertinoListSection.insetGrouped(
                  dividerMargin: 0,
                  additionalDividerMargin: 0,
                  children: List.generate(state.rows.length, (index) {
                    final row = state.rows[index];
                    final matchPoll = row.matchPoll;
                    final user = row.user;

                    return CupertinoListTile(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 20,
                        right: 20,
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        '${_matchNameFor(state, matchPoll.eventId)} - d. ${DateHelper.getFormattedDate(matchPoll.createdAt)}',
                      ),
                      additionalInfo: Text(
                        '${matchPoll.playerOfTheMatchVotes} stemmer',
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateMatchPoll(BuildContext context) async {
    await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<MatchPollsCubit>(),
        child: ChangeNotifierProvider(
          create: (context) => UserVotesState(),
          child: const CreateMatchPollPage(),
        ),
      ),
    );
  }

  String _matchNameFor(MatchPollsState state, int matchId) {
    for (final match in state.matches) {
      if (match.id == matchId) {
        return match.matchName;
      }
    }
    return 'Ukendt kamp';
  }
}
