import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/button/button_small.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/match_poll_row_item.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/card_type.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
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

enum MatchDetailsSegments { registration, events, manOfTheMatch, fines }

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

  MatchDetailsSegments _selectedSegment = MatchDetailsSegments.registration;

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

    return PageScaffold(
      title: 'Kampdetaljer',
      showBackButton: true,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        child: FutureHandler<Map<String, dynamic>>(
          future: matchAndSquadData,
          noDataFoundMessage: 'Ingen kamp fundet.',
          onSuccess: (context, data) {
            final matchDetails = data['matchDetails'] as MatchDetails;
            final squad = data['squad'] as List<UserDetails>;

            return FutureHandler<UserDetails>(
              future: currentUser,
              noDataFoundMessage: 'Ingen bruger fundet.',
              onSuccess: (context, user) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  matchDetails.homeTeam ?? '?',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: appTextStyles.sectionHeader,
                                ),
                              ),
                              if (user.isTeamOwner && !matchDetails.hasMatchBeenPlayed)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: ButtonSmall(
                                    buttonText: 'Indberet',
                                    onPressed: () async => setMatchScore(matchDetails.id),
                                    outlined: true,
                                  ),
                                )
                              else if (!matchDetails.hasMatchBeenPlayed)
                                Text('-', style: appTextStyles.pageTitle)
                              else
                                Text(
                                  '${matchDetails.homeTeamScore} - ${matchDetails.awayTeamScore}',
                                  style: appTextStyles.pageTitle,
                                ),
                              Expanded(
                                child: Text(
                                  matchDetails.awayTeam ?? '?',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: appTextStyles.sectionHeader,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const _LabeledDivider(label: 'Detaljer'),
                          const SizedBox(height: 30),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double chipMax = (constraints.maxWidth - 10) / 2;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _InfoPill(
                                        icon: CupertinoIcons.calendar,
                                        text: DateHelper.getFormattedDate(matchDetails.date),
                                        maxWidth: chipMax,
                                      ),
                                      _InfoPill(
                                        icon: CupertinoIcons.time,
                                        text: '${DateHelper.getFormattedTime(matchDetails.date)} (${DateHelper.getFormattedTime(matchDetails.meetingTime)})',
                                        maxWidth: chipMax,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoBar(
                                    icon: CupertinoIcons.location_solid,
                                    text: matchDetails.location,
                                    maxWidth: constraints.maxWidth,
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoBar(
                                      icon: CupertinoIcons.pencil,
                                      text: matchDetails.notes ?? 'Ingen noter',
                                      maxWidth: constraints.maxWidth),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<MatchDetailsSegments>(
                        backgroundColor: appColors.divider,
                        thumbColor: appColors.surface,
                        groupValue: _selectedSegment,
                        onValueChanged: (MatchDetailsSegments? value) {
                          if (value != null) {
                            setState(() {
                              _selectedSegment = value;
                            });
                          }
                        },
                        children: <MatchDetailsSegments, Widget>{
                          MatchDetailsSegments.registration: Text(
                            'Tilmelding',
                            style: appTextStyles.caption.copyWith(
                              fontWeight: _selectedSegment == MatchDetailsSegments.registration ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          MatchDetailsSegments.events: Text(
                            'Begivenheder',
                            style: appTextStyles.caption.copyWith(
                              fontWeight: _selectedSegment == MatchDetailsSegments.events ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          MatchDetailsSegments.manOfTheMatch: Text(
                            'MOTM',
                            style: appTextStyles.caption.copyWith(
                              fontWeight: _selectedSegment == MatchDetailsSegments.manOfTheMatch ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        },
                      ),
                    ),
                    Center(child: getMatchDetailSegment(matchDetails, squad, user, appColors, appTextStyles)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget getMatchDetailSegment(MatchDetails matchDetails, List<UserDetails> squad, UserDetails currentUserData, AppColors appColors, AppTextStyles appTextStyles) {
    if (_selectedSegment == MatchDetailsSegments.registration) {
      return Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildActionButtonsInfo(matchDetails, appColors, appTextStyles),
              const SizedBox(height: 20),
              _buildAttendanceList('Tilmeldte', matchDetails.attendanceDetailsList!.where((a) => a.isAttending).map((a) => a.userDetails.name).toList(), appColors, appTextStyles),
              const SizedBox(height: 20),
              _buildAttendanceList('Frameldte', matchDetails.attendanceDetailsList!.where((a) => !a.isAttending).map((a) => a.userDetails.name).toList(), appColors, appTextStyles),
              const SizedBox(height: 20),
              _buildAttendanceList('Ej tilkendegivet', squad.where((player) => !matchDetails.attendanceDetailsList!.any((a) => a.userDetails.id == player.id)).map((p) => p.name).toList(), appColors, appTextStyles),
            ],
          ));
    } else if (_selectedSegment == MatchDetailsSegments.manOfTheMatch) {
      return Container(
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isManOfTheMatchVoted && matchPollDetails!.matchPollUserVotesDetails.isNotEmpty) ...[
                CupertinoListSection.insetGrouped(
                    header: Text('Stemmer', style: appTextStyles.caption),
                    backgroundColor: Colors.transparent,
                    margin: EdgeInsets.zero,
                    children: getMatchPollRowItems(squad)),
              ] else ...[
                Text('Ingen afstemning endnu', style: appTextStyles.body),
                const SizedBox(height: 20),
                Button(
                    buttonText: 'Stem på kampens spiller',
                    onPressed: () async {
                      final data = await matchAndSquadData;
                      final squad = data['squad'] as List<UserDetails>;
                      final matchDetails = data['matchDetails'] as MatchDetails;
                      if (mounted) {
                        final createdMatchPollDetails = await showCupertinoModalBottomSheet(
                          expand: true,
                          context: context,
                          builder: (context) => CreateMatchPollPage(squad: squad, matches: [matchDetails]),
                        );
                        if (createdMatchPollDetails != null) _setMatchPollDetails(createdMatchPollDetails);
                      }
                    }),
              ],
            ],
          ),
        ),
      );
    } else if (_selectedSegment == MatchDetailsSegments.events) {
      final events = matchDetails.matchEventDetailsList ?? <MatchEventDetails>[];
      return Container(
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ButtonSmall(
                buttonText: 'Tilføj begivenhed',
                onPressed: () => addGoalscorer(currentUserData),
                outlined: true,
                icon: CupertinoIcons.add,
              ),
            ),
            const SizedBox(height: 30),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('Ingen begivenheder endnu', style: appTextStyles.caption.copyWith(color: appColors.textSecondary)),
                ),
              )
            else
              Column(
                children: [
                  const _LabeledDivider(label: 'Begivenheder'),
                  const SizedBox(height: 12),
                  ...events.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _EventTile(
                          event: e,
                          showDelete: currentUserData.isTeamOwner,
                          isDeleting: false,
                          onDelete: () => _confirmAndDeleteEvent(e.id),
                        ),
                      )),
                ],
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAttendanceList(String title, List<String> names, AppColors appColors, AppTextStyles appTextStyles) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title - ${names.length}', style: appTextStyles.sectionHeader),
          if (names.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...names.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(name, style: appTextStyles.body),
                )),
          ] else ...[
            const SizedBox(height: 10),
            Text('Ingen', style: appTextStyles.caption.copyWith(color: appColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtonsInfo(MatchDetails matchDetails, AppColors appColors, AppTextStyles appTextStyles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getButtonItem('Tilmeld', CupertinoIcons.add_circled, appColors.success, Colors.white, appTextStyles,
            onTap: () async {
          if (await registerForMatch()) _refreshMatchAndSquad();
        }),
        const SizedBox(width: 30),
        getButtonItem('Afmeld', CupertinoIcons.minus_circle, appColors.error, Colors.white, appTextStyles,
            onTap: () async {
          if (await unregisterFromMatch()) _refreshMatchAndSquad();
        }),
      ],
    );
  }

  Widget getButtonItem(String buttonText, IconData buttonIcon, Color backgroundColor, Color textColor, AppTextStyles appTextStyles, {Function()? onTap}) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 100,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12.0)),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          children: [
            Icon(buttonIcon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(buttonText, style: appTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  List<MatchPollRowItem> getMatchPollRowItems(List<UserDetails> squad) {
    var matchPollRowItems = matchPollDetails!.matchPollUserVotesDetails
        .map((v) => MatchPollRowItem(
            disabled: true,
            userId: v.userId,
            userName: squad.firstWhere((e) => e.id == v.userId).name,
            votes: v.numberOfVotes,
            isUserPlayerOfTheMatch: matchPollDetails!.playerOfTheMatchDetails.id == v.userId))
        .toList();
    matchPollRowItems.sort((a, b) => b.votes.compareTo(a.votes));
    return matchPollRowItems;
  }

  Future<bool> registerForMatch() async {
    return await MatchRepository.registerForMatch(widget.matchId) > 0;
  }

  Future<bool> unregisterFromMatch() async {
    return await MatchRepository.unregisterFromMatch(widget.matchId) > 0;
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

          return Container(
            color: appColors.surface,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  CupertinoNavigationBar(
                    backgroundColor: appColors.surface,
                    middle: Text('Tilføj målscorer', style: appTextStyles.sectionHeader),
                    leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Luk'), onPressed: () => Navigator.of(modalContext).pop()),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: (!isSaving && staged.isNotEmpty) ? saveAll : null,
                      child: isSaving ? const CupertinoActivityIndicator() : Text('Gem', style: TextStyle(color: staged.isNotEmpty ? appColors.primary : appColors.divider)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CupertinoSlidingSegmentedControl<_PickRole>(
                    backgroundColor: appColors.divider,
                    thumbColor: appColors.surface,
                    groupValue: activeRole,
                    children: {
                      _PickRole.scorer: Text('Målscorer', style: appTextStyles.caption),
                      _PickRole.assist: Text('Assist', style: appTextStyles.caption),
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
                        return ListTile(
                          title: Text(u.name, style: appTextStyles.body),
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
                            } else {
                              current.assistId = u.id;
                            }
                          }),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Button(
                      buttonText: 'Tilføj til liste',
                      onPressed: () {
                        if (current.scorerId != null) {
                          setModalState(() {
                            staged.add(_GoalDraft(scorerId: current.scorerId, assistId: current.assistId));
                            current = _GoalDraft();
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

  Future<void> _confirmAndDeleteEvent(int eventId) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Slet begivenhed?'),
        content: const Text('Dette kan ikke fortrydes.'),
        actions: [
          CupertinoDialogAction(isDestructiveAction: true, child: const Text('Slet'), onPressed: () => Navigator.of(ctx).pop(true)),
          CupertinoDialogAction(child: const Text('Annullér'), onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    );
    if (ok == true) {
      await MatchRepository.deleteMatchEvent(eventId);
      _refreshMatchAndSquad();
    }
  }
}

class _LabeledDivider extends StatelessWidget {
  final String label;
  const _LabeledDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final appColors = theme.extension<AppColors>() ?? AppColors.light;

    return Row(
      children: [
        Expanded(child: Divider(color: appColors.divider)),
        const SizedBox(width: 12),
        Text(label, style: appTextStyles.bodyBold),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: appColors.divider)),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? maxWidth;
  const _InfoPill({required this.icon, required this.text, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: appColors.lightGrass.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: appColors.grass),
          const SizedBox(width: 8),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final double? maxWidth;
  const _InfoBar({required this.icon, required this.text, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: appColors.lightSky.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: appColors.sky),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14))),
        ],
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
      decoration: BoxDecoration(color: appColors.primary, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _EventTile extends StatelessWidget {
  final MatchEventDetails event;
  final bool showDelete;
  final bool isDeleting;
  final VoidCallback? onDelete;
  const _EventTile({required this.event, this.showDelete = false, this.isDeleting = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: appColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: appColors.divider)),
      child: Row(
        children: [
          _EventLeadingIcon(event: event),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.goalscorerUserName, style: appTextStyles.bodyBold),
                if (event.type == MatchEventType.goal)
                  Text(event.assistMakerUserName == null ? 'Ingen assist' : 'Assist: ${event.assistMakerUserName}', style: appTextStyles.caption.copyWith(color: appColors.textSecondary)),
              ],
            ),
          ),
          if (showDelete) CupertinoButton(padding: EdgeInsets.zero, onPressed: onDelete, child: Icon(CupertinoIcons.delete, color: appColors.error, size: 20)),
        ],
      ),
    );
  }
}

class _EventLeadingIcon extends StatelessWidget {
  final MatchEventDetails event;
  const _EventLeadingIcon({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.type == MatchEventType.goal) return const Icon(Icons.sports_soccer, size: 24);
    return Container(width: 16, height: 22, decoration: BoxDecoration(color: event.cardType == CardType.red ? Colors.red : Colors.yellow, borderRadius: BorderRadius.circular(2)));
  }
}