import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/cubits/match_polls_cubit.dart';
import 'package:kopa/cubits/match_polls_state.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:provider/provider.dart';

class CreateMatchPollPage extends StatefulWidget {
  const CreateMatchPollPage({super.key});

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
    final state = context.watch<MatchPollsCubit>().state;

    final hasMatches = state.matches.isNotEmpty;
    final matchNames = state.matches.map((x) => x.matchName).toList();
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
            onPressed: state.isSubmitting
                ? null
                : () async {
                    final createdMatchPollDetails =
                        await context.read<MatchPollsCubit>().createMatchPoll(
                              selectedMatchIndex: safeIdx,
                              userVotes: userVotes,
                            );

                    if (context.mounted) {
                      final errorMessage = context
                          .read<MatchPollsCubit>()
                          .state
                          .formErrorMessage;
                      if (createdMatchPollDetails != null) {
                        context.read<UserVotesState>().removeAllUserVotes();
                        Navigator.pop(context, createdMatchPollDetails);
                      } else if (errorMessage != null) {
                        await _showError(errorMessage);
                        if (context.mounted) {
                          context.read<MatchPollsCubit>().clearFormError();
                        }
                      }
                    }
                  },
            child: state.isSubmitting
                ? const CupertinoActivityIndicator()
                : Text('Opret',
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
                  children: getMatchPollRowItems(state)),
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

  Future<void> _showError(String message) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext modalContext) => CupertinoAlertDialog(
        title: const Text('Fejl'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(modalContext).pop(),
          ),
        ],
      ),
    );
  }

  List<MatchPollRowItem> getMatchPollRowItems(MatchPollsState state) {
    List<MatchPollRowItem> matchPollRowItems = [];

    for (var user in state.squad) {
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
