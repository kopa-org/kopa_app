import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/card/player_positions_card.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/add_match_event_modal.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:kopa/utils/crash_reporting.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/info_row/info_row.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;
  final MatchDetails? initialMatch;
  final String? heroTag;

  const MatchDetailsPage({
    super.key,
    required this.matchId,
    this.initialMatch,
    this.heroTag,
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
  bool _enableHeroCardActions = false;
  final Set<int> _savingAttendanceSelectionIds = {};
  bool _isApprovingAllAttendances = false;
  int _homeGoals = 0;
  int _awayGoals = 0;
  MatchDetailSegment _selectedSegment = MatchDetailSegment.overview;

  @override
  void initState() {
    super.initState();
    AppAnalytics.logScreenView('match_details');
    AppAnalytics.logEvent('match_opened');
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
      _enableHeroCardActions = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _showLoadedContent = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _enableHeroCardActions = true;
      });
    });
  }

  Future<Map<String, dynamic>> _fetchMatchAndSquad() async {
    final squad = await UsersRepository.getSquad();
    final matchDetails = await MatchRepository.getMatch(widget.matchId);
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

  @override
  Widget build(BuildContext context) {
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
    final hasBeenPlayed = matchDetails.hasMatchBeenPlayed;

    return MatchDetailTemplate(
      onRefresh: _refreshMatchAndSquad,
      selectedSegment: _selectedSegment,
      onSegmentChanged: _selectSegment,
      heroCard: MatchHeroCard(
        match: matchDetails,
        heroTag: widget.heroTag,
        animateCard: widget.heroTag != null,
        onTap: _enableHeroCardActions &&
                user.isTeamOwner &&
                !matchDetails.hasMatchBeenPlayed
            ? () => setMatchScore(matchDetails.id)
            : null,
      ),
      overviewTitle: hasBeenPlayed ? 'Efter kampen' : 'Praktisk information',
      attendanceTitle: hasBeenPlayed ? 'Tilmeldte' : 'Tilmeldte spillere',
      timelineTitle: hasBeenPlayed ? 'Kampbegivenheder' : 'Kampforløb',
      attendanceSegmentLabel: 'Tilmeldte',
      timelineSegmentLabel: hasBeenPlayed ? 'Begivenheder' : 'Kampforløb',
      showTimelineSegment: !hasBeenPlayed,
      timelineEmptyMessage: hasBeenPlayed
          ? 'Ingen kampbegivenheder registreret endnu.'
          : 'Ingen begivenheder registreret.',
      overviewWidgets: hasBeenPlayed
          ? _buildPlayedMatchOverview(matchDetails, user)
          : const [],
      infoRows:
          hasBeenPlayed ? const [] : _buildPracticalInfoRows(matchDetails),
      votingModule: null,
      playerPositions: hasBeenPlayed
          ? null
          : PlayerPositionsCard(
              playerCount: _teamPlayerCount(matchDetails, user),
              formation: matchDetails.formation,
              players: _lineupPlayers(matchDetails),
              onEditFormation: user.isTeamOwner
                  ? () => _showFormationPicker(matchDetails, user)
                  : null,
            ),
      attendanceList: _buildAttendanceList(matchDetails, squad, user),
      ratingsSection: hasBeenPlayed ? null : _buildRatingsSection(matchDetails),
      timelineItems:
          hasBeenPlayed ? const [] : _buildTimelineItems(matchDetails, user),
    );
  }

  void _selectSegment(MatchDetailSegment segment) {
    AppAnalytics.logEvent(
      'match_details_segment_selected',
      parameters: {'segment': segment.name},
    );
    setState(() {
      _selectedSegment = segment;
    });
  }

  Widget _buildInitialLoadingState(MatchDetails match) {
    return MatchDetailTemplate(
      selectedSegment: _selectedSegment,
      onSegmentChanged: _selectSegment,
      heroCard: MatchHeroCard(
        match: match,
        heroTag: widget.heroTag,
        animateCard: widget.heroTag != null,
      ),
    );
  }

  List<Widget> _buildPracticalInfoRows(MatchDetails matchDetails) {
    return [
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
        icon: CupertinoIcons.clock,
        title: 'Countdown',
        value: _countdownLabel(matchDetails),
      ),
      InfoRow(
        icon: CupertinoIcons.person_2,
        title: 'Tilmeldinger',
        value:
            '${matchDetails.registeredCount} tilmeldte / ${matchDetails.unavailableCount} frameldte',
      ),
      InfoRow(
        icon: CupertinoIcons.checkmark_seal,
        title: 'Din udtagelse',
        value: matchDetails.isCurrentUserSelected == true
            ? 'Udtaget'
            : matchDetails.isCurrentUserSelected == false
                ? 'Ikke udtaget'
                : 'Afventer',
      ),
      InfoRow(
        icon: CupertinoIcons.pencil,
        title: 'Noter',
        value: matchDetails.notes ?? 'Ingen noter',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Center(
          child: Button(
            buttonText: 'Åbn navigation',
            onPressed: () => _openNavigation(matchDetails),
            icon: CupertinoIcons.map,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPlayedMatchOverview(
    MatchDetails match,
    UserDetails user,
  ) {
    return [
      _MatchTimelineSection(
        items: _buildTimelineItems(match, user, includeAddEventButton: false),
        canAddEvent: user.isTeamOwner,
        onAddEvent: () => addMatchEvent(user),
      ),
    ];
  }

  List<Widget> _buildAttendanceList(
      MatchDetails match, List<UserDetails> squad, UserDetails user) {
    final attending =
        match.attendanceDetailsList?.where((a) => a.isAttending).toList() ?? [];

    if (user.isTeamOwner && !match.hasMatchBeenPlayed) {
      return _buildLeaderAttendanceApprovalList(match, attending);
    }

    return attending
        .map((a) => PlayerListItem(
              name: a.userDetails.name,
              subtitle: a.isSelected == true
                  ? 'Udtaget'
                  : a.isSelected == false
                      ? 'Ikke udtaget'
                      : a.userDetails.email,
            ))
        .toList();
  }

  List<Widget> _buildLeaderAttendanceApprovalList(
    MatchDetails match,
    List<EventAttendanceDetails> attending,
  ) {
    final pending = attending.where((a) => a.isSelected == null).toList();
    final approved = attending.where((a) => a.isSelected == true).toList();
    final widgets = <Widget>[];

    widgets.add(
      _AttendanceApprovalSection(
        title: 'Afventer godkendelse (${pending.length})',
        children: pending.isEmpty
            ? const [_AttendanceApprovalEmpty()]
            : pending
                .map(
                  (attendance) => _AttendanceApprovalRow(
                    attendance: attendance,
                    approved: false,
                    isSaving:
                        _savingAttendanceSelectionIds.contains(attendance.id),
                    onApprove: () => _updateAttendanceSelection(
                      match.id,
                      attendance,
                      true,
                    ),
                    onReject: () => _updateAttendanceSelection(
                      match.id,
                      attendance,
                      false,
                    ),
                  ),
                )
                .toList(),
      ),
    );

    if (approved.isNotEmpty) {
      widgets.add(const SizedBox(height: Spacing.md));
      widgets.add(
        _AttendanceApprovalSection(
          title: 'Godkendte (${approved.length})',
          children: approved
              .map(
                (attendance) => _AttendanceApprovalRow(
                  attendance: attendance,
                  approved: true,
                  isSaving:
                      _savingAttendanceSelectionIds.contains(attendance.id),
                  onApprove: () {},
                  onReject: () => _updateAttendanceSelection(
                    match.id,
                    attendance,
                    false,
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    if (pending.isNotEmpty) {
      widgets.add(const SizedBox(height: Spacing.lg));
      widgets.add(
        _ApproveAllAttendancesButton(
          isSaving: _isApprovingAllAttendances,
          onPressed: () => _approveAllAttendances(match.id, pending),
        ),
      );
    }

    return widgets;
  }

  Future<void> _updateAttendanceSelection(
    int matchId,
    EventAttendanceDetails attendance,
    bool isSelected,
  ) async {
    if (_savingAttendanceSelectionIds.contains(attendance.id)) return;

    setState(() {
      _savingAttendanceSelectionIds.add(attendance.id);
    });

    try {
      await MatchRepository.updateAttendanceSelection(
        matchId,
        attendance.userDetails.id,
        isSelected,
      );
      AppAnalytics.logEvent(
        'match_attendance_selection_updated',
        parameters: {'is_selected': isSelected},
      );
      await _refreshMatchAndSquad();
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke opdatere godkendelsen. Prøv igen.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingAttendanceSelectionIds.remove(attendance.id);
        });
      }
    }
  }

  Future<void> _approveAllAttendances(
    int matchId,
    List<EventAttendanceDetails> pending,
  ) async {
    if (_isApprovingAllAttendances) return;

    setState(() {
      _isApprovingAllAttendances = true;
      _savingAttendanceSelectionIds.addAll(pending.map((a) => a.id));
    });

    try {
      for (final attendance in pending) {
        await MatchRepository.updateAttendanceSelection(
          matchId,
          attendance.userDetails.id,
          true,
        );
      }
      AppAnalytics.logEvent(
        'match_attendance_selection_all_approved',
        parameters: {'count': pending.length},
      );
      await _refreshMatchAndSquad();
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke godkende alle. Prøv igen.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApprovingAllAttendances = false;
          _savingAttendanceSelectionIds.removeAll(pending.map((a) => a.id));
        });
      }
    }
  }

  int _teamPlayerCount(MatchDetails match, UserDetails user) {
    final count = match.teamPlayerCount;
    if (count == 7 || count == 11) return count;

    final userTeamCount = user.teamDetails?.playerCount ?? 7;
    return userTeamCount == 11 ? 11 : 7;
  }

  List<UserDetails> _lineupPlayers(MatchDetails match) {
    final attendances = match.attendanceDetailsList ?? [];
    final selected = attendances
        .where((attendance) =>
            attendance.isAttending && attendance.isSelected == true)
        .map((attendance) => attendance.userDetails)
        .toList();

    if (selected.isNotEmpty) return selected;

    return attendances
        .where((attendance) => attendance.isAttending)
        .map((attendance) => attendance.userDetails)
        .toList();
  }

  Future<void> _showFormationPicker(
      MatchDetails match, UserDetails user) async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final formationCtl = TextEditingController(text: match.formation);
    var selectedFormation = match.formation;
    var isSaving = false;

    try {
      await showCupertinoModalPopup(
        context: context,
        builder: (modalContext) => StatefulBuilder(
          builder: (modalContext, setModalState) {
            final suggestions =
                _suggestedFormations(_teamPlayerCount(match, user));
            final normalized = _normalizeFormation(formationCtl.text);
            final canSave = _isValidFormation(normalized) && !isSaving;

            Future<void> save() async {
              if (!canSave) return;
              setModalState(() => isSaving = true);
              try {
                await MatchRepository.updateMatchFormation(
                    match.id, normalized);
                AppAnalytics.logEvent(
                  'match_formation_updated',
                  parameters: {'formation': normalized},
                );
                if (mounted) await _refreshMatchAndSquad();
                if (modalContext.mounted) Navigator.of(modalContext).pop();
              } catch (error, stack) {
                CrashReporting.logWebError(error, stack);
                if (modalContext.mounted) {
                  setModalState(() => isSaving = false);
                }
              }
            }

            return Material(
              child: Container(
                color: appColors.surface,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CupertinoNavigationBar(
                          backgroundColor: appColors.surface,
                          middle: Text(
                            'Vælg opstilling',
                            style: appTextStyles.sectionHeader,
                          ),
                          leading: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(modalContext).pop(),
                            child: Text(
                              'Annullér',
                              style: TextStyle(color: appColors.error),
                            ),
                          ),
                          trailing: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: canSave ? save : null,
                            child: isSaving
                                ? const CupertinoActivityIndicator()
                                : Text(
                                    'Gem',
                                    style: TextStyle(
                                      color: canSave
                                          ? appColors.primary
                                          : appColors.divider,
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Standard er 2-3-1, men du kan skrive enhver opstilling som f.eks. 3-2-1 eller 2-2-3.',
                                style: appTextStyles.body,
                              ),
                              const SizedBox(height: Spacing.md),
                              Wrap(
                                spacing: Spacing.sm,
                                runSpacing: Spacing.sm,
                                children: suggestions.map((formation) {
                                  final selected =
                                      formation == selectedFormation;
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        selectedFormation = formation;
                                        formationCtl.text = formation;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Spacing.md,
                                        vertical: Spacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? appColors.lightGrass
                                            : appColors.grey2,
                                        borderRadius: BorderRadius.circular(
                                          Spacing.borderRadiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        formation,
                                        style: appTextStyles.caption.copyWith(
                                          color: selected
                                              ? appColors.primary
                                              : appColors.dirt,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: Spacing.md),
                              CupertinoTextField(
                                controller: formationCtl,
                                placeholder: '2-3-1',
                                keyboardType: TextInputType.text,
                                padding: const EdgeInsets.all(Spacing.md),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Spacing.borderRadiusSmall,
                                  ),
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedFormation =
                                        _normalizeFormation(value);
                                  });
                                },
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                'Brug bindestreger mellem kæderne. Målmanden er altid medregnet automatisk.',
                                style: appTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } finally {
      formationCtl.dispose();
    }
  }

  List<String> _suggestedFormations(int playerCount) {
    if (playerCount == 11) {
      return const ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1'];
    }

    return const ['2-3-1', '3-2-1', '2-2-2', '1-3-2', '2-2-3'];
  }

  String _normalizeFormation(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  bool _isValidFormation(String formation) {
    if (!RegExp(r'^\d+(?:-\d+)*$').hasMatch(formation)) return false;
    return formation
        .split('-')
        .map(int.tryParse)
        .every((count) => count != null && count > 0 && count <= 5);
  }

  Widget? _buildRatingsSection(MatchDetails match) {
    final ratings = match.playerRatingDetailsList ?? [];
    if (ratings.isEmpty) return null;

    return Column(
      children: ratings
          .map(
            (rating) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rating.userName,
                      style: Theme.of(context)
                              .extension<AppTextStyles>()
                              ?.bodyBold ??
                          AppTextStyles.light.bodyBold,
                    ),
                  ),
                  Text(
                    '${rating.averageRating.toStringAsFixed(1)} (${rating.voteCount})',
                    style: Theme.of(context).extension<AppTextStyles>()?.body ??
                        AppTextStyles.light.body,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<Widget> _buildTimelineItems(
    MatchDetails match,
    UserDetails user, {
    bool includeAddEventButton = true,
  }) {
    final List<MatchEventDetails> events =
        List.from(match.matchEventDetailsList ?? []);
    events.sort((a, b) => (b.minute ?? 0).compareTo(a.minute ?? 0));

    if (events.isEmpty && !user.isTeamOwner) return [];

    final List<Widget> items = [];

    if (user.isTeamOwner && includeAddEventButton) {
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
        title = 'Mål: ${e.goalscorerUserName}';
        timeLabel = e.minute != null ? '${e.minute}\'' : 'MÅL';
        icon = Icons.sports_soccer;
        subtitle = e.assistMakerUserName != null
            ? 'Assisteret af ${e.assistMakerUserName}'
            : 'Mål';
      } else if (e.type == MatchEventType.yellowCard) {
        title = 'Gult kort: ${e.goalscorerUserName}';
        timeLabel = e.minute != null ? '${e.minute}\'' : 'KORT';
        icon = Icons.square;
        iconColor = Colors.yellow;
        subtitle = 'Gult kort';
      } else if (e.type == MatchEventType.redCard) {
        title = 'Rødt kort: ${e.goalscorerUserName}';
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
        title = 'Straffe: ${e.goalscorerUserName}';
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
              AppAnalytics.logEvent('match_score_updated');
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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

  String _countdownLabel(MatchDetails match) {
    final countdown = match.countdown;
    if (countdown.isNegative) {
      return 'I gang eller afsluttet';
    }

    return '${countdown.inDays} dage ${countdown.inHours % 24} timer ${countdown.inMinutes % 60} min';
  }

  Future<void> _openNavigation(MatchDetails match) async {
    final query = Uri.encodeComponent(match.location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MatchTimelineSection extends StatelessWidget {
  final List<Widget> items;
  final bool canAddEvent;
  final VoidCallback onAddEvent;

  const _MatchTimelineSection({
    required this.items,
    required this.canAddEvent,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _MatchTimelineEmptyState(
        canAddEvent: canAddEvent,
        onAddEvent: onAddEvent,
      );
    }

    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kampforløb',
          style: styles.subtitle1.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        KopaCard(
          borderRadius: Spacing.borderRadiusLargeIncreased,
          padding: const EdgeInsets.all(20),
          child: Column(children: items),
        ),
        if (canAddEvent) ...[
          const SizedBox(height: Spacing.lg),
          _AddMatchEventOutlineButton(onPressed: onAddEvent),
        ],
      ],
    );
  }
}

class _MatchTimelineEmptyState extends StatelessWidget {
  final bool canAddEvent;
  final VoidCallback onAddEvent;

  const _MatchTimelineEmptyState({
    required this.canAddEvent,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      borderRadius: Spacing.borderRadiusLargeIncreased,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.offWhite,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              CupertinoIcons.list_bullet_indent,
              color: colors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Ingen hændelser endnu',
            style: styles.subtitle1.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Tilføj hændelser som mål, kort og udskiftninger',
            style: styles.body3.copyWith(color: colors.dirt),
            textAlign: TextAlign.center,
          ),
          if (canAddEvent) ...[
            const SizedBox(height: Spacing.lg),
            _AddMatchEventButton(onPressed: onAddEvent),
          ],
        ],
      ),
    );
  }
}

class _AddMatchEventButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMatchEventButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+ Tilføj hændelse',
          style: styles.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AddMatchEventOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddMatchEventOutlineButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+ Tilføj hændelse',
          style: styles.body1.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AttendanceApprovalSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AttendanceApprovalSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: styles.subtitle2),
        const SizedBox(height: Spacing.sm),
        ...children,
      ],
    );
  }
}

class _AttendanceApprovalRow extends StatelessWidget {
  final EventAttendanceDetails attendance;
  final bool approved;
  final bool isSaving;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AttendanceApprovalRow({
    required this.attendance,
    required this.approved,
    required this.isSaving,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final user = attendance.userDetails;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: approved ? 0.82 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
        ),
        child: Row(
          children: [
            _AttendanceAvatar(name: user.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: styles.body3.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _positionLabel(user.position),
                    style: styles.caption1.copyWith(color: colors.dirt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            if (isSaving)
              const SizedBox(
                width: 32,
                height: 32,
                child: CupertinoActivityIndicator(),
              )
            else if (approved)
              _ApprovedBadge(onReject: onReject)
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AttendanceActionButton(
                    icon: CupertinoIcons.xmark,
                    color: colors.error,
                    backgroundColor: const Color(0xFFFFEBEE),
                    semanticLabel: 'Afvis ${user.name}',
                    onPressed: onReject,
                  ),
                  const SizedBox(width: Spacing.sm),
                  _AttendanceActionButton(
                    icon: CupertinoIcons.checkmark_alt,
                    color: colors.primary,
                    backgroundColor: const Color(0xFFE8F5E9),
                    semanticLabel: 'Godkend ${user.name}',
                    onPressed: onApprove,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _positionLabel(String? position) {
    final value = position?.trim();
    if (value == null || value.isEmpty) return 'Spiller';
    return value;
  }
}

class _AttendanceAvatar extends StatelessWidget {
  final String name;

  const _AttendanceAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.offWhite,
        borderRadius: BorderRadius.circular(19),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: styles.body3.copyWith(
          color: colors.grass,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _AttendanceActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String semanticLabel;
  final VoidCallback onPressed;

  const _AttendanceActionButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(32, 32),
        onPressed: onPressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ApprovedBadge extends StatelessWidget {
  final VoidCallback onReject;

  const _ApprovedBadge({required this.onReject});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(28, 28),
      onPressed: onReject,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_alt, size: 10, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              'Godkendt',
              style: styles.caption2.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceApprovalEmpty extends StatelessWidget {
  const _AttendanceApprovalEmpty();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Text(
        'Ingen spillere afventer godkendelse.',
        style: styles.caption1.copyWith(color: colors.dirt),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ApproveAllAttendancesButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _ApproveAllAttendancesButton({
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Semantics(
      button: true,
      enabled: !isSaving,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isSaving ? null : onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                const CupertinoActivityIndicator(color: Colors.white)
              else ...[
                const Icon(
                  CupertinoIcons.checkmark_alt_circle,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Godkend alle',
                  style: styles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
