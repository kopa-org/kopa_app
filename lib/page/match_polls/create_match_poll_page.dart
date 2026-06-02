import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/match_polls_cubit.dart';
import 'package:kopa/cubits/match_polls_state.dart';
import 'package:kopa/model/user_vote.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:provider/provider.dart';

PageRoute<T> createMatchPollPageRoute<T>({required Widget child}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

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
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final hasMatches = state.matches.isNotEmpty;
    final matchNames = state.matches.map((x) => x.matchName).toList();
    final safeIdx = _safeIndex(matchNames.length);

    return PageScaffold(
      title: 'Tilføj afstemning',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            KopaCard(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.lightSky.withValues(alpha: 0.45),
                      borderRadius:
                          BorderRadius.circular(Spacing.borderRadiusSmall),
                    ),
                    child: Icon(
                      CupertinoIcons.sportscourt,
                      color: appColors.sky,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamp',
                          style: appTextStyles.caption,
                        ),
                        Text(
                          hasMatches
                              ? matchNames[safeIdx]
                              : 'Ingen kampe tilgængelige',
                          style: appTextStyles.bodyBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasMatches)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      onPressed: () {
                        _showDialog(
                          CupertinoPicker(
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32.0,
                            scrollController: FixedExtentScrollController(
                              initialItem: safeIdx,
                            ),
                            onSelectedItemChanged: (int i) {
                              setState(() => selectedMatchIndex = i);
                            },
                            children: List<Widget>.generate(matchNames.length,
                                (int i) {
                              return Center(child: Text(matchNames[i]));
                            }),
                          ),
                        );
                      },
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        color: appColors.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            KopaCard(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appColors.lightGrass.withValues(alpha: 0.38),
                          borderRadius:
                              BorderRadius.circular(Spacing.borderRadiusSmall),
                        ),
                        child: Icon(
                          CupertinoIcons.star_fill,
                          color: appColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stem på kampens spiller',
                              style: appTextStyles.sectionHeader,
                            ),
                            Text(
                              'Fordel stemmer med + og -',
                              style: appTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  ...getMatchPollRowItems(state).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: item,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Button(
              buttonText:
                  state.isSubmitting ? 'Opretter...' : 'Opret afstemning',
              width: double.infinity,
              enabled: !state.isSubmitting && hasMatches,
              onPressed: () => _submitPoll(safeIdx, userVotes),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPoll(int safeIdx, List<UserVote> userVotes) async {
    final matchPollsCubit = context.read<MatchPollsCubit>();
    final userVotesState = context.read<UserVotesState>();
    final navigator = Navigator.of(context);
    final createdMatchPollDetails = await matchPollsCubit.createMatchPoll(
      selectedMatchIndex: safeIdx,
      userVotes: userVotes,
    );

    if (!mounted) return;

    final errorMessage = matchPollsCubit.state.formErrorMessage;
    if (createdMatchPollDetails != null) {
      userVotesState.removeAllUserVotes();
      navigator.pop(createdMatchPollDetails);
    } else if (errorMessage != null) {
      await _showError(errorMessage);
      if (mounted) {
        matchPollsCubit.clearFormError();
      }
    }
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
