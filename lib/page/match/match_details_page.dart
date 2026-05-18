import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/match_poll_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match_polls/create_match_poll_page.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/info_row/info_row.dart';
import 'package:kopa/component/voting/voting_module.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:kopa/model/create_match_event_command.dart';

enum _PickRole { scorer, assist }

class _GoalDraft {
  int? scorerId;
  int? assistId;
  _GoalDraft({this.scorerId, this.assistId});
}

class MatchDetailsPage extends StatefulWidget {
  final int matchId;

  const MatchDetailsPage({super.key, required this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  late Future<Map<String, dynamic>> matchAndSquadData;
  late Future<UserDetails> currentUser;
  bool _isManOfTheMatchVoted = false;
  MatchPollDetails? matchPollDetails;
  int _homeGoals = 0;
  int _awayGoals = 0;

  @override
  void initState() {
    super.initState();
    matchAndSquadData = _fetchMatchAndSquad();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
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
    setState(() {
      matchAndSquadData = _fetchMatchAndSquad();
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
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return FutureHandler<Map<String, dynamic>>(
      future: matchAndSquadData,
      noDataFoundMessage: 'Ingen kamp fundet.',
      onSuccess: (context, data) {
        final matchDetails = data['matchDetails'] as MatchDetails;
        final squad = data['squad'] as List<UserDetails>;

        return FutureHandler<UserDetails>(
          future: currentUser,
          noDataFoundMessage: 'Ingen bruger fundet.',
          onSuccess: (context, user) {
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
                  value: '${DateHelper.getFormattedTime(matchDetails.date)} (Mødetid: ${DateHelper.getFormattedTime(matchDetails.meetingTime)})',
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
              votingModule: _buildVotingModule(matchDetails, squad, appColors, appTextStyles),
              attendanceList: _buildAttendanceList(matchDetails, squad),
              timelineItems: _buildTimelineItems(matchDetails, user),
            );
          },
        );
      },
    );
  }

  Widget? _buildVotingModule(MatchDetails match, List<UserDetails> squad, AppColors colors, AppTextStyles styles) {
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
                builder: (context) => CreateMatchPollPage(squad: squad, matches: [match]),
              );
              if (result != null) _setMatchPollDetails(result);
            },
          ),
        ),
      );
    }

    if (matchPollDetails == null) return const SizedBox.shrink();

    final totalVotes = matchPollDetails!.matchPollUserVotesDetails.fold<int>(0, (sum, v) => sum + v.numberOfVotes);
    final options = matchPollDetails!.matchPollUserVotesDetails.map((v) {
      final player = squad.firstWhere((s) => s.id == v.userId);
      return VotingOption(
        id: v.userId,
        label: player.name,
        votes: v.numberOfVotes,
        totalVotes: totalVotes,
        isSelected: matchPollDetails!.playerOfTheMatchDetails.id == v.userId,
      );
    }).toList();

    options.sort((a, b) => b.votes.compareTo(a.votes));

    return VotingModule(
      title: 'Kampens spiller',
      options: options,
      hasVoted: true,
    );
  }

  List<Widget> _buildAttendanceList(MatchDetails match, List<UserDetails> squad) {
    final attending = match.attendanceDetailsList?.where((a) => a.isAttending).toList() ?? [];
    return attending.map((a) => PlayerListItem(
      name: a.userDetails.name,
      subtitle: a.userDetails.email,
    )).toList();
  }

  List<Widget> _buildTimelineItems(MatchDetails match, UserDetails user) {
    final events = match.matchEventDetailsList ?? [];
    if (events.isEmpty && !user.isTeamOwner) return [];

    final List<Widget> items = [];
    
    if (user.isTeamOwner) {
      items.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Button(
              buttonText: 'Tilføj begivenhed',
              onPressed: () => addGoalscorer(user),
              icon: CupertinoIcons.add,
            ),
          ),
        ),
      );
    }

    for (var i = 0; i < events.length; i++) {
      final e = events[i];
      items.add(
        TimelineItem(
          title: '${e.goalscorerUserName}${e.assistMakerUserName != null ? ' (Assist: ${e.assistMakerUserName})' : ''}',
          time: e.type == MatchEventType.goal ? 'MÅL' : 'KORT',
          icon: e.type == MatchEventType.goal ? Icons.sports_soccer : Icons.square,
          iconColor: e.type == MatchEventType.goal ? null : (e.cardType == null ? Colors.yellow : (e.cardType == CardType.red ? Colors.red : Colors.yellow)),
          isLast: i == events.length - 1,
          subtitle: e.type == MatchEventType.goal ? 'Flot mål!' : 'Advarsel',
        ),
      );
    }

    return items;
  }

  Future<void> setMatchScore(int matchDetailsId) async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

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
                setState(() { _homeGoals = h; _awayGoals = a; });
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoNavigationBar(
                      backgroundColor: appColors.surface,
                      middle: Text('Indtast resultat', style: appTextStyles.sectionHeader),
                      leading: CupertinoButton(padding: EdgeInsets.zero, child: Text('Annullér', style: TextStyle(color: appColors.error)), onPressed: () => Navigator.of(modalContext).pop()),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: canSave && !isSaving ? onOk : null,
                        child: isSaving ? const CupertinoActivityIndicator() : Text('OK', style: TextStyle(color: canSave ? appColors.primary : appColors.divider)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(child: _buildScoreField(homeCtl, homeNode, awayNode, appColors)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('—', style: appTextStyles.pageTitle)),
                          Expanded(child: _buildScoreField(awayCtl, awayNode, null, appColors, onSubmitted: onOk)),
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

  Widget _buildScoreField(TextEditingController ctl, FocusNode node, FocusNode? next, AppColors appColors, {VoidCallback? onSubmitted}) {
    return CupertinoTextField(
      controller: ctl,
      focusNode: node,
      autofocus: next != null,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: appColors.black, width: 2), borderRadius: BorderRadius.circular(8)),
      onSubmitted: (_) => next != null ? next.requestFocus() : onSubmitted?.call(),
    );
  }

  Future<void> addGoalscorer(UserDetails currentUserData) async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final data = await matchAndSquadData;
    if (!mounted) return;
    final squad = (data['squad'] as List<UserDetails>);

    _PickRole activeRole = _PickRole.scorer;
    _GoalDraft current = _GoalDraft();
    final List<_GoalDraft> staged = [];
    bool isSaving = false;

    await showCupertinoModalPopup(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          Future<void> saveAll() async {
            if (staged.isEmpty || isSaving) return;
            setModalState(() => isSaving = true);
            try {
              await MatchRepository.createMatchEvents(staged.map((d) => CreateMatchEventCommand(
                  eventId: widget.matchId,
                  type: MatchEventType.goal,
                  teamId: currentUserData.teamDetails.id,
                  goalscorerUserId: d.scorerId!,
                  assistMakerUserId: d.assistId,
                )).toList());
              if (!mounted) return;
              await _refreshMatchAndSquad();
              if (!mounted) return;
              if (modalContext.mounted) {
                Navigator.of(modalContext).pop();
              }
            } catch (e) { setModalState(() => isSaving = false); }
          }

          String getUserName(int? id) {
            if (id == null) return '';
            try {
              return squad.firstWhere((u) => u.id == id).name;
            } catch (_) {
              return 'Ukendt';
            }
          }

          return Material(
            color: appColors.surface,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoNavigationBar(
                    backgroundColor: appColors.surface,
                    middle: Text('Tilføj mål', style: appTextStyles.sectionHeader),
                    leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Luk'), onPressed: () => Navigator.of(modalContext).pop()),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: (!isSaving && staged.isNotEmpty) ? saveAll : null,
                      child: isSaving ? const CupertinoActivityIndicator() : Text('Gem', style: TextStyle(color: staged.isNotEmpty ? appColors.primary : appColors.divider)),
                    ),
                  ),
                  
                  // Staged Goals Section
                  if (staged.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColors.divider.withValues(alpha: 0.1),
                        border: Border(bottom: BorderSide(color: appColors.divider)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: staged.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final s = staged[i];
                          return Row(
                            children: [
                              Icon(Icons.sports_soccer, size: 16, color: appColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${getUserName(s.scorerId)}${s.assistId != null ? ' (Assist: ${getUserName(s.assistId)})' : ''}',
                                  style: appTextStyles.body,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Icon(CupertinoIcons.minus_circle_fill, color: appColors.error, size: 20),
                                onPressed: () => setModalState(() => staged.removeAt(i)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  
                  // Current Selection Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SelectionBox(
                          label: 'Målscorer',
                          name: getUserName(current.scorerId),
                          isActive: activeRole == _PickRole.scorer,
                          onTap: () => setModalState(() => activeRole = _PickRole.scorer),
                        ),
                        _SelectionBox(
                          label: 'Assist',
                          name: getUserName(current.assistId),
                          isActive: activeRole == _PickRole.assist,
                          onTap: () => setModalState(() => activeRole = _PickRole.assist),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  CupertinoSlidingSegmentedControl<_PickRole>(
                    backgroundColor: appColors.divider,
                    thumbColor: appColors.surface,
                    groupValue: activeRole,
                    children: {
                      _PickRole.scorer: Text('Vælg målscorer', style: appTextStyles.caption),
                      _PickRole.assist: Text('Vælg assist', style: appTextStyles.caption),
                    },
                    onValueChanged: (v) { if (v != null) setModalState(() => activeRole = v); },
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: squad.length,
                      itemBuilder: (context, index) {
                        final u = squad[index];
                        final isScorer = current.scorerId == u.id;
                        final isAssist = current.assistId == u.id;
                        
                        return PlayerListItem(
                          name: u.name,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isScorer) _Badge(label: 'Mål'),
                              if (isAssist) _Badge(label: 'Assist'),
                            ],
                          ),
                          onTap: () => setModalState(() {
                            if (activeRole == _PickRole.scorer) {
                              current.scorerId = u.id;
                              activeRole = _PickRole.assist; // Auto-advance to assist
                            } else {
                              if (current.scorerId == u.id) {
                                // Can't assist yourself
                                return;
                              }
                              current.assistId = (current.assistId == u.id) ? null : u.id;
                            }
                          }),
                        );
                      },
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Button(
                      buttonText: 'Tilføj mål',
                      onPressed: () {
                        if (current.scorerId != null) {
                          setModalState(() {
                            staged.add(_GoalDraft(scorerId: current.scorerId, assistId: current.assistId));
                            current = _GoalDraft();
                            activeRole = _PickRole.scorer;
                          });
                        }
                      },
                      enabled: current.scorerId != null,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final String label;
  final String name;
  final bool isActive;
  final VoidCallback onTap;

  const _SelectionBox({
    required this.label,
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? appColors.primary.withValues(alpha: 0.1) : appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? appColors.primary : appColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: appTextStyles.caption.copyWith(color: isActive ? appColors.primary : appColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              name.isEmpty ? 'Vælg...' : name,
              style: appTextStyles.bodyBold.copyWith(
                color: name.isEmpty ? appColors.textSecondary.withValues(alpha: 0.5) : appColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: appColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
