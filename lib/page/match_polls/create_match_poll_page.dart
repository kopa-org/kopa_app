import 'package:flutter/cupertino.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_polls_repository.dart';
import 'package:kopa/model/user_vote.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:provider/provider.dart';

class CreateMatchPollPage extends StatefulWidget {
  final List<UserDetails> squad;
  final List<MatchDetails> matches;
  final List<MatchPollDetails> matchPolls;

  CreateMatchPollPage(
      {required this.squad,
      this.matches = const [],
      this.matchPolls = const []});

  @override
  State<CreateMatchPollPage> createState() => _CreateMatchPollPageState();
}

class _CreateMatchPollPageState extends State<CreateMatchPollPage> {
  int selectedMatchIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userVotes = context.watch<UserVotesState>().userVotes;

    final hasMatches = widget.matches.isNotEmpty;
    final matchNames = widget.matches.map((x) => x.matchName).toList();
    final safeIdx = _safeIndex(matchNames.length);

    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGrey6,
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context,
                    false); // Return false to indicate no user was added
              },
              child: Icon(
                semanticLabel: 'Annullér',
                CupertinoIcons.clear,
              )),
          middle: Text('Tilføj afstemning'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              var createdMatchPollDetails =
                  await createMatchPoll(context, userVotes);

              if (createdMatchPollDetails != null && context.mounted) {
                Navigator.pop(context, createdMatchPollDetails);
              }
            },
            child: Text('Opret',
                style: TextStyle(
                    color: CupertinoColors.systemIndigo,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: CupertinoFormSection.insetGrouped(children: <Widget>[
                    _DatePickerItem(
                      children: <Widget>[
                        const Text('Kamp'),
                        hasMatches
                            ? CupertinoButton(
                                onPressed: () {
                                  _showDialog(
                                    CupertinoPicker(
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32.0,
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: safeIdx,
                                      ),
                                      onSelectedItemChanged: (int i) {
                                        setState(() => selectedMatchIndex = i);
                                      },
                                      children: List<Widget>.generate(
                                          matchNames.length, (int i) {
                                        return Center(
                                            child: Text(matchNames[i]));
                                      }),
                                    ),
                                  );
                                },
                                child: Text(matchNames[safeIdx]),
                              )
                            : const Text(
                                'Ingen kampe tilgængelige',
                                style: TextStyle(
                                    color: CupertinoColors.inactiveGray),
                              ),
                      ],
                    ),
                  ])),

              // Vote on the player of the match
              CupertinoListSection.insetGrouped(
                  dividerMargin: 0,
                  additionalDividerMargin: 0,
                  margin: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 30.0),
                  header: const Text('Stem på kampens spiller'),
                  children: getMatchPollRowItems()),
            ],
          ),
        )));
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          Container(
            height: 250,
            // The Bottom margin is provided to align the popup above the system navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: CupertinoColors.systemBackground.resolveFrom(context),
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Luk'),
        ),
      ),
    );
  }

  Future<MatchPollDetails?> createMatchPoll(
      BuildContext context, List<UserVote> userVotes) async {
    if (widget.matches.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Ingen kampe'),
          content: Text('Der er ingen kampe at oprette en afstemning for.'),
        ),
      );
      return null;
    }

    final idx = _safeIndex(widget.matches.length);
    final matchId = widget.matches[idx].id;

    final exists = widget.matchPolls.any((x) => x.eventId == matchId);
    if (exists) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext modalContext) => CupertinoAlertDialog(
          title: const Text('Fejl'),
          content: const Text(
              'Afstemning til kampen eksisterer allerede. Vælg en anden kamp.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
          ],
        ),
      );
      return null;
    }

    if (userVotes.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext modalContext) => CupertinoAlertDialog(
          title: Text('Fejl'),
          content: Text('Afgiv mindst én stemme for at oprette en afstemning.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(modalContext).pop(),
            ),
          ],
        ),
      );
      return null;
    }

    final matchPollId =
        await MatchPollsRepository.createMatchPoll(matchId, userVotes);
    AppAnalytics.logEvent(
      'match_poll_created',
      parameters: {'vote_count': userVotes.length},
    );

    if (context.mounted) {
      Provider.of<UserVotesState>(context, listen: false).removeAllUserVotes();
    }

    return await MatchPollsRepository.getMatchPoll(matchPollId);
  }

  List<MatchPollRowItem> getMatchPollRowItems() {
    List<MatchPollRowItem> matchPollRowItems = [];

    for (var user in widget.squad) {
      var matchPollItem =
          MatchPollRowItem(userId: user.id, userName: user.name);

      matchPollRowItems.add(matchPollItem);
    }

    return matchPollRowItems;
  }

  int _safeIndex(int length) {
    if (length <= 0) return 0;
    return selectedMatchIndex.clamp(0, length - 1);
  }
}

class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
          bottom: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
