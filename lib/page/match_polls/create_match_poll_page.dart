import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/match_polls_cubit.dart';
import 'package:kopa/cubits/match_polls_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_poll_details.dart';
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
  final MatchPollDetails? initialPoll;
  final bool loadFullMatch;

  const CreateMatchPollPage({
    super.key,
    this.initialPoll,
    this.loadFullMatch = false,
  });

  bool get isEditing => initialPoll != null;

  @override
  State<CreateMatchPollPage> createState() => _CreateMatchPollPageState();
}

class _CreateMatchPollPageState extends State<CreateMatchPollPage> {
  int selectedMatchIndex = 0;
  bool _loadingFullMatch = false;

  @override
  void initState() {
    super.initState();
    if (widget.loadFullMatch) {
      _loadingFullMatch = true;
      _loadFullMatch();
    }
  }

  Future<void> _loadFullMatch() async {
    try {
      await context.read<MatchPollsCubit>().loadFullMatchForPoll();
    } catch (_) {
      if (mounted) {
        await _showError(
            AppLocalizations.of(context)!.matchPollLoadPlayersFailed);
        if (mounted) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _loadingFullMatch = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userVotes = context.watch<UserVotesState>().userVotes;
    final state = context.watch<MatchPollsCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final hasMatches = state.matches.isNotEmpty;
    final safeIdx = _safeIndex(state.matches.length);

    return PageScaffold(
      title: widget.isEditing
          ? l10n.matchPollEditTitle
          : l10n.matchPollCreateTitle,
      showBackButton: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              112,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                              color:
                                  appColors.lightGrass.withValues(alpha: 0.38),
                              borderRadius: BorderRadius.circular(
                                Spacing.borderRadiusSmall,
                              ),
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
                                  l10n.matchPollTitle,
                                  style: appTextStyles.sectionHeader,
                                ),
                                Text(
                                  l10n.matchPollInstruction,
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
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: appColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  Spacing.md,
                ),
                child: Button(
                  buttonText: state.isSubmitting
                      ? (widget.isEditing
                          ? l10n.matchPollSaving
                          : l10n.matchPollCreating)
                      : (widget.isEditing
                          ? l10n.matchPollSaveAction
                          : l10n.matchPollCreateAction),
                  width: double.infinity,
                  enabled:
                      !state.isSubmitting && hasMatches && !_loadingFullMatch,
                  onPressed: () => _submitPoll(safeIdx, userVotes),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPoll(int safeIdx, List<UserVote> userVotes) async {
    final matchPollsCubit = context.read<MatchPollsCubit>();
    final userVotesState = context.read<UserVotesState>();
    final navigator = Navigator.of(context);
    final updatedOrCreatedPoll = widget.initialPoll == null
        ? await matchPollsCubit.createMatchPoll(
            selectedMatchIndex: safeIdx,
            userVotes: userVotes,
          )
        : await matchPollsCubit.updateMatchPoll(
            matchPollId: widget.initialPoll!.id,
            userVotes: userVotes,
          );

    if (!mounted) return;

    final errorMessage = matchPollsCubit.state.formErrorMessage;
    if (updatedOrCreatedPoll != null) {
      userVotesState.removeAllUserVotes();
      navigator.pop(updatedOrCreatedPoll);
    } else if (errorMessage != null) {
      await _showError(errorMessage);
      if (mounted) {
        matchPollsCubit.clearFormError();
      }
    }
  }

  Future<void> _showError(String message) {
    final l10n = AppLocalizations.of(context)!;

    return showCupertinoDialog(
      context: context,
      builder: (BuildContext modalContext) => CupertinoAlertDialog(
        title: Text(l10n.matchPollErrorTitle),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.commonOk),
            onPressed: () => Navigator.of(modalContext).pop(),
          ),
        ],
      ),
    );
  }

  List<MatchPollRowItem> getMatchPollRowItems(MatchPollsState state) {
    List<MatchPollRowItem> matchPollRowItems = [];

    for (var user in state.squad) {
      var matchPollItem = MatchPollRowItem(
        userId: user.id,
        userName: user.name,
        isUserPlayerOfTheMatch:
            widget.initialPoll?.playerOfTheMatchDetails?.id == user.id,
      );

      matchPollRowItems.add(matchPollItem);
    }

    if (state.matches.isNotEmpty) {
      final match = state.matches[_safeIndex(state.matches.length)];
      for (final player in match.externalPlayerDetailsList ?? const []) {
        matchPollRowItems.add(MatchPollRowItem(
          userId: player.id,
          userName: player.name,
          isExternal: true,
          isUserPlayerOfTheMatch:
              widget.initialPoll?.playerOfTheMatchExternalPlayerDetails?.id ==
                  player.id,
        ));
      }
    }

    return matchPollRowItems;
  }

  int _safeIndex(int length) {
    if (length <= 0) return 0;
    return selectedMatchIndex.clamp(0, length - 1);
  }
}
