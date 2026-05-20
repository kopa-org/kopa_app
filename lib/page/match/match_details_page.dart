import 'package:flutter/cupertino.dart';
import 'package:kopa/state/user_votes_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match_polls/create_match_poll_page.dart';
import 'package:kopa/page/match/add_match_event_modal.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/crash_reporting.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/info_row/info_row.dart';
import 'package:kopa/component/voting/voting_module.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:kopa/component/timeline/timeline_item.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;
  final MatchDetails? initialMatch;

  const MatchDetailsPage({
    super.key,
    required this.matchId,
    this.initialMatch,
  });

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  Map<String, dynamic>? _matchAndSquadData;
  Object? _loadError;
  UserDetails? _currentUser;
  Object? _currentUserError;
  bool _showLoadedContent = false;
  bool _isManOfTheMatchVoted = false;
  MatchPollDetails? matchPollDetails;
  int _homeGoals = 0;
  int _awayGoals = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      _currentUserError =
          Exception('Ingen bruger fundet. Log venligst ind igen.');
    } else {
      _currentUser = user;
    }
    _loadMatchAndSquad();
    _showLoadedContentAfterTransition();
  }

  Future<void> _loadMatchAndSquad() async {
    try {
      final data = await _fetchMatchAndSquad();
      if (!mounted) return;
      setState(() {
        _matchAndSquadData = data;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
      });
    }
  }

  void _showLoadedContentAfterTransition() {
    if (widget.initialMatch == null) {
      _showLoadedContent = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _showLoadedContent = true;
      });
    });
  }

  Future<Map<String, dynamic>> _fetchMatchAndSquad() async {
    final squad = await UsersRepository.getSquad();
    final matchDetails = await MatchRepository.getMatch(widget.matchId);
    if (matchDetails.matchPollDetails != null) {
      _setMatchPollDetails(matchDetails.matchPollDetails);
    }
    return {
      'squad': squad,
      'matchDetails': matchDetails,
    };
  }

  Future<void> _refreshMatchAndSquad() async {
    final data = await _fetchMatchAndSquad();
    if (!mounted) return;
    setState(() {
      _matchAndSquadData = data;
      _loadError = null;
    });
  }

  void _setMatchPollDetails(MatchPollDetails? matchPollDetailsToSet) {
    _isManOfTheMatchVoted = true;
    matchPollDetails = matchPollDetailsToSet;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    if (_loadError != null || _currentUserError != null) {
      return const ErrorMessage(
        message: 'Der skete en fejl. Prøv venligst igen senere.',
      );
    }

    final data = _matchAndSquadData;
    if (data == null || !_showLoadedContent) {
      final initialMatch = widget.initialMatch;
      if (initialMatch != null) {
        return _buildInitialLoadingState(initialMatch);
      }

      return const LoadingIndicator();
    }

    final user = _currentUser;
    if (user == null) {
      return const Center(child: Text('Ingen bruger fundet.'));
    }

    final matchDetails = data['matchDetails'] as MatchDetails;
    final squad = data['squad'] as List<UserDetails>;

    return MatchDetailTemplate(
      onRefresh: _refreshMatchAndSquad,
      heroCard: MatchHeroCard(
        match: matchDetails,
        onTap: user.isTeamOwner && !matchDetails.hasMatchBeenPlayed
            ? () => setMatchScore(matchDetails.id)
            : null,
      ),
      infoRows: [
        InfoRow(
          icon: CupertinoIcons.calendar,
          title: 'Dato',
          value: DateHelper.getFormattedDate(matchDetails.date),
        ),
        InfoRow(
          icon: CupertinoIcons.time,
          title: 'Tidspunkt',
          value:
              '${DateHelper.getFormattedTime(matchDetails.date)} (Mødetid: ${DateHelper.getFormattedTime(matchDetails.meetingTime)})',
        ),
        InfoRow(
          icon: CupertinoIcons.location_solid,
          title: 'Lokation',
          value: matchDetails.location,
        ),
        InfoRow(
          icon: CupertinoIcons.pencil,
          title: 'Noter',
          value: matchDetails.notes ?? 'Ingen noter',
        ),
      ],
      votingModule:
          _buildVotingModule(matchDetails, squad, appColors, appTextStyles),
      attendanceList: _buildAttendanceList(matchDetails, squad),
      timelineItems: _buildTimelineItems(matchDetails, user),
    );
  }

  Widget _buildInitialLoadingState(MatchDetails match) {
    return MatchDetailTemplate(
      heroCard: MatchHeroCard(match: match),
    );
  }

  Widget? _buildVotingModule(MatchDetails match, List<UserDetails> squad,
      AppColors colors, AppTextStyles styles) {
    if (!_isManOfTheMatchVoted || matchPollDetails == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Button(
            buttonText: 'Stem på kampens spiller',
            onPressed: () async {
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => UserVotesState(),
                  child: CreateMatchPollPage(squad: squad, matches: [match]),
                ),
              );
              if (result != null) _setMatchPollDetails(result);
            },
          ),
        ),
      );
    }

    if (matchPollDetails == null) return const SizedBox.shrink();

    final poll = matchPollDetails!;
    final totalVotes = poll.matchPollUserVotesDetails
        .fold<int>(0, (sum, v) => sum + v.numberOfVotes);
    final options = poll.matchPollUserVotesDetails.map((v) {
      final player =
          squad.firstWhere((s) => s.id == v.userId, orElse: () => squad.first);
      return VotingOption(
        id: v.userId,
        label: player.name,
        votes: v.numberOfVotes,
        totalVotes: totalVotes,
        isSelected: poll.playerOfTheMatchDetails.id == v.userId,
      );
    }).toList();

    options.sort((a, b) => b.votes.compareTo(a.votes));

    return VotingModule(
      title: 'Kampens spiller',
      options: options,
      hasVoted: true,
    );
  }

  List<Widget> _buildAttendanceList(
      MatchDetails match, List<UserDetails> squad) {
    final attending =
        match.attendanceDetailsList?.where((a) => a.isAttending).toList() ?? [];
    return attending
        .map((a) => PlayerListItem(
              name: a.userDetails.name,
              subtitle: a.userDetails.email,
            ))
        .toList();
  }

  List<Widget> _buildTimelineItems(MatchDetails match, UserDetails user) {
    final List<MatchEventDetails> events =
        List.from(match.matchEventDetailsList ?? []);
    events.sort((a, b) => (b.minute ?? 0).compareTo(a.minute ?? 0));

    if (events.isEmpty && !user.isTeamOwner) return [];

    final List<Widget> items = [];

    if (user.isTeamOwner) {
      items.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Button(
              buttonText: 'Tilføj begivenhed',
              onPressed: () => addMatchEvent(user),
              icon: CupertinoIcons.add,
            ),
          ),
        ),
      );
    }

    for (var i = 0; i < events.length; i++) {
      final e = events[i];

      String title = e.goalscorerUserName;
      String timeLabel = '';
      IconData icon = Icons.circle;
      Color? iconColor;
      String subtitle = '';

      if (e.type == MatchEventType.goal) {
        if (e.assistMakerUserName != null) {
          title += ' (Assist: ${e.assistMakerUserName})';
        }
        timeLabel = e.minute != null ? '${e.minute}\'' : 'MÅL';
        icon = Icons.sports_soccer;
        subtitle = 'Mål';
      } else if (e.type == MatchEventType.yellowCard) {
        timeLabel = e.minute != null ? '${e.minute}\'' : 'KORT';
        icon = Icons.square;
        iconColor = Colors.yellow;
        subtitle = 'Gult kort';
      } else if (e.type == MatchEventType.redCard) {
        timeLabel = e.minute != null ? '${e.minute}\'' : 'KORT';
        icon = Icons.square;
        iconColor = Colors.red;
        subtitle = 'Rødt kort';
      } else if (e.type == MatchEventType.substitution) {
        title =
            '${e.goalscorerUserName} (Ind) / ${e.assistMakerUserName ?? '?'} (Ud)';
        timeLabel = e.minute != null ? '${e.minute}\'' : 'UDSK.';
        icon = Icons.swap_horiz;
        subtitle = 'Udskiftning';
      } else if (e.type == MatchEventType.penaltyKick) {
        timeLabel = e.minute != null ? '${e.minute}\'' : 'STRAFFE';
        icon = Icons.sports_soccer;
        iconColor = Colors.orange;
        subtitle = 'Straffespark';
      }

      items.add(
        TimelineItem(
          title: title,
          time: timeLabel,
          icon: icon,
          iconColor: iconColor,
          isLast: i == events.length - 1,
          subtitle: subtitle,
        ),
      );
    }

    return items;
  }

  Future<void> setMatchScore(int matchDetailsId) async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final homeCtl = TextEditingController(text: _homeGoals.toString());
    final awayCtl = TextEditingController(text: _awayGoals.toString());
    final homeNode = FocusNode();
    final awayNode = FocusNode();
    bool isSaving = false;

    await showCupertinoModalPopup(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          bool valid(String v) => v.isNotEmpty && int.tryParse(v) != null;
          final canSave = valid(homeCtl.text) && valid(awayCtl.text);

          Future<void> onOk() async {
            if (!canSave || isSaving) return;
            setModalState(() => isSaving = true);
            try {
              final h = int.parse(homeCtl.text);
              final a = int.parse(awayCtl.text);
              await MatchRepository.updateMatchScore(matchDetailsId, h, a);
              if (mounted) {
                setState(() {
                  _homeGoals = h;
                  _awayGoals = a;
                });
                _refreshMatchAndSquad();
                if (modalContext.mounted) {
                  Navigator.of(modalContext).pop();
                }
              }
            } catch (e) {
              setModalState(() => isSaving = false);
            }
          }

          return Container(
            color: appColors.surface,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoNavigationBar(
                      backgroundColor: appColors.surface,
                      middle: Text('Indtast resultat',
                          style: appTextStyles.sectionHeader),
                      leading: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text('Annullér',
                              style: TextStyle(color: appColors.error)),
                          onPressed: () => Navigator.of(modalContext).pop()),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: canSave && !isSaving ? onOk : null,
                        child: isSaving
                            ? const CupertinoActivityIndicator()
                            : Text('OK',
                                style: TextStyle(
                                    color: canSave
                                        ? appColors.primary
                                        : appColors.divider)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildScoreField(
                                  homeCtl, homeNode, awayNode, appColors)),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('—', style: appTextStyles.pageTitle)),
                          Expanded(
                              child: _buildScoreField(
                                  awayCtl, awayNode, null, appColors,
                                  onSubmitted: onOk)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreField(TextEditingController ctl, FocusNode node,
      FocusNode? next, AppColors appColors,
      {VoidCallback? onSubmitted}) {
    return CupertinoTextField(
      controller: ctl,
      focusNode: node,
      autofocus: next != null,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: appColors.black, width: 2),
          borderRadius: BorderRadius.circular(8)),
      onSubmitted: (_) =>
          next != null ? next.requestFocus() : onSubmitted?.call(),
    );
  }

  Future<void> addMatchEvent(UserDetails currentUserData) async {
    try {
      final data = _matchAndSquadData ?? await _fetchMatchAndSquad();
      if (!mounted) return;

      final squadRaw = data['squad'];
      if (squadRaw == null || squadRaw is! List) {
        throw Exception('Squad data is missing or invalid');
      }
      final squad = List<UserDetails>.from(squadRaw);

      await showAddMatchEventModal(
        context,
        widget.matchId,
        squad,
        currentUserData,
        _refreshMatchAndSquad,
      );
    } catch (e, stack) {
      CrashReporting.logWebError(e, stack);
    }
  }
}
