import 'package:flutter/cupertino.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:provider/provider.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_polls_repository.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/page/match_polls/create_match_poll_page.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MatchPollsListPage extends StatefulWidget {
  @override
  State<MatchPollsListPage> createState() => _MatchPollsListPageState();
}

class _MatchPollsListPageState extends State<MatchPollsListPage> {
  late Future<Map<String, dynamic>> matchPollsData;
  late Future<UserDetails> currentUser;

  @override
  void initState() {
    super.initState();

    // Hent afstemninger + trup
    matchPollsData = _fetchMatchPollsData();

    // Load logged in user via AuthCubit
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(
          Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
  }

  Future<Map<String, dynamic>> _fetchMatchPollsData() async {
    final results = await Future.wait([
      UsersRepository.getSquad(),
      MatchRepository.getMatches(),
      MatchPollsRepository.getMatchPolls(),
    ]);

    final squad = results[0] as List<UserDetails>;
    final matches = results[1] as List<MatchDetails>;
    final matchPolls = results[2] as List<MatchPollDetails>;

    return {
      'squad': squad,
      'matches': matches,
      'matchPolls': matchPolls.map((poll) {
        final user = squad.firstWhere(
          (user) => user.id == poll.playerOfTheMatchDetails.id,
        );
        return {
          'matchPoll': poll,
          'user': user,
        };
      }).toList(),
    };
  }

  Future<void> _refreshMatchPolls() async {
    setState(() {
      matchPollsData = _fetchMatchPollsData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(CupertinoIcons.chevron_left,
                semanticLabel: 'Tilbage'),
          ),
          trailing: FutureHandler<UserDetails>(
            future: currentUser,
            loadingIndicator: const SizedBox.shrink(),
            onError: (_) => const SizedBox.shrink(),
            onSuccess: (context, user) {
              if (!user.isTeamOwner) return const SizedBox.shrink();

              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final data = await matchPollsData;
                  final squad = data['squad'] as List<UserDetails>;
                  final matches = data['matches'] as List<MatchDetails>;
                  final matchPolls =
                      (data['matchPolls'] as List<Map<String, dynamic>>)
                          .map((e) => e['matchPoll'] as MatchPollDetails)
                          .toList();

                  if (!context.mounted) return;

                  final createdMatchPollDetails =
                      await showCupertinoModalBottomSheet(
                    expand: true,
                    context: context,
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => UserVotesState(),
                      child: CreateMatchPollPage(
                        squad: squad,
                        matches: matches,
                        matchPolls: matchPolls,
                      ),
                    ),
                  );

                  if (createdMatchPollDetails != null) {
                    _refreshMatchPolls();
                  }
                },
                child: const Icon(CupertinoIcons.add,
                    semanticLabel: 'Opret afstemning'),
              );
            },
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FutureHandler<Map<String, dynamic>>(
              future: matchPollsData,
              noDataFoundMessage: 'Ingen afstemninger fundet.',
              onSuccess: (context, data) {
                final matchPolls =
                    data['matchPolls'] as List<Map<String, dynamic>>;

                if (matchPolls.isEmpty) {
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

                return CupertinoListSection.insetGrouped(
                  dividerMargin: 0,
                  additionalDividerMargin: 0,
                  children: List.generate(matchPolls.length, (index) {
                    final row = matchPolls[index];
                    final matchPoll = row['matchPoll'] as MatchPollDetails;
                    final user = row['user'] as UserDetails;
                    final match =
                        (data['matches'] as List<MatchDetails>).firstWhere(
                      (m) => m.id == matchPoll.eventId,
                    );

                    return CupertinoListTile(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 20, right: 20),
                      title: Text(user.name),
                      subtitle: Text(
                        '${match.matchName} - d. ${DateHelper.getFormattedDate(matchPoll.createdAt)}',
                      ),
                      additionalInfo: Text(
                        '${matchPoll.playerOfTheMatchVotes} stemmer',
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
