import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/card/player_positions_card.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/helpers/date_helper.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/add_match_event_modal.dart';
import 'package:kopa/page/match/lineup_editor_page.dart';
import 'package:kopa/page/match/post_match_details_page.dart';
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
  final Set<int> _editingAttendanceSelectionIds = {};
  bool _isApprovingAllAttendances = false;
  bool _isUpdatingRegistration = false;
  bool _isUpdatingLineupVisibility = false;
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

    final heroCard = MatchHeroCard(
      match: matchDetails,
      heroTag: widget.heroTag,
      animateCard: widget.heroTag != null,
      onTap: _enableHeroCardActions && matchDetails.canSetFinalScore(user)
          ? () => setMatchScore(matchDetails.id)
          : null,
    );

    if (hasBeenPlayed) {
      return PostMatchDetailsPage(
        match: matchDetails,
        user: user,
        heroCard: heroCard,
        attendanceList: _buildAttendanceList(matchDetails, squad, user),
        onRefresh: _refreshMatchAndSquad,
        onAddEvent: () => addMatchEvent(user),
        selectedSegment: _selectedSegment,
        onSegmentChanged: _selectSegment,
      );
    }

    return MatchDetailTemplate(
      onRefresh: _refreshMatchAndSquad,
      selectedSegment: _selectedSegment,
      onSegmentChanged: _selectSegment,
      heroCard: heroCard,
      usePrematchLayout: true,
      stickyActionBar: _PrematchRsvpBar(
        match: matchDetails,
        currentUser: user,
        isSaving: _isUpdatingRegistration,
        onAccept: () => _registerForMatch(matchDetails),
        onDecline: () => _unregisterFromMatch(matchDetails),
      ),
      overviewTitle: 'Praktisk information',
      attendanceTitle: 'Tilmeldte spillere',
      attendanceSegmentLabel:
          'Tilmeldte (${matchDetails.attendingAttendanceDetails.length})',
      showTimelineSegment: false,
      overviewWidgets: const [],
      infoRows: _buildPracticalInfoRows(matchDetails),
      votingModule: null,
      playerPositions: user.isTeamOwner || matchDetails.lineupVisible
          ? PlayerPositionsCard(
              playerCount: _teamPlayerCount(matchDetails, user),
              formation: matchDetails.formation,
              players: _lineupPlayers(matchDetails),
              positionedPlayers: _hasSavedLineup(matchDetails)
                  ? _lineupPositionedPlayers(matchDetails, user)
                  : null,
              preservePlayerOrder: _hasSavedLineup(matchDetails),
              onEditFormation: user.isTeamOwner
                  ? () => _openLineupEditor(matchDetails, user)
                  : null,
              onToggleVisibility: user.isTeamOwner
                  ? () => _toggleLineupVisibility(matchDetails)
                  : null,
              isVisibleToPlayers: matchDetails.lineupVisible,
              isUpdatingVisibility: _isUpdatingLineupVisibility,
              showTitle: false,
            )
          : null,
      attendanceList: _buildAttendanceList(matchDetails, squad, user),
      ratingsSection: _buildRatingsSection(matchDetails),
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
      usePrematchLayout: true,
      showTimelineSegment: false,
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
        value: DateHelper.getFormattedTime(matchDetails.date),
      ),
      InfoRow(
        icon: CupertinoIcons.alarm,
        title: 'Mødetid',
        value: DateHelper.getFormattedTime(matchDetails.meetingTime),
      ),
      InfoRow(
        icon: CupertinoIcons.location_solid,
        title: 'Lokation',
        trailing: _LocationMapsLink(
          location: matchDetails.location,
          onPressed: () => _openNavigation(matchDetails),
        ),
      ),
      InfoRow(
        icon: CupertinoIcons.clock,
        title: 'Countdown',
        value: _countdownLabel(matchDetails),
      ),
      InfoRow(
        icon: CupertinoIcons.person_2,
        title: 'Tilmeldinger',
        value: '${matchDetails.registeredCount} tilmeldte',
      ),
      InfoRow(
        icon: CupertinoIcons.checkmark_seal,
        title: 'Din udtagelse',
        value: matchDetails.isCurrentUserSelected == true
            ? 'Udtaget'
            : matchDetails.isCurrentUserSelected == false
                ? 'Ikke udtaget'
                : 'Afventer',
        valueColor: matchDetails.isCurrentUserSelected == true
            ? const Color(0xFF00964E)
            : const Color(0xFFF97316),
      ),
      InfoRow(
        icon: CupertinoIcons.pencil,
        title: 'Noter',
        value: matchDetails.notes ?? 'Ingen noter',
      ),
    ];
  }

  List<Widget> _buildAttendanceList(
      MatchDetails match, List<UserDetails> squad, UserDetails user) {
    final attending = match.attendingAttendanceDetails;
    final declined = match.declinedAttendanceDetails;
    final noRsvp = _membersWithoutRsvp(match, squad);

    if (user.isTeamOwner && !match.hasMatchBeenPlayed) {
      return _buildLeaderAttendanceApprovalList(
        match,
        attending,
        declined,
        noRsvp,
      );
    }

    return [
      ...attending.map((a) => PlayerListItem(
            name: a.userDetails.name,
            subtitle: a.isSelected == true
                ? 'Udtaget'
                : a.isSelected == false
                    ? 'Ikke udtaget'
                    : a.userDetails.email,
          )),
      ..._buildNoRsvpSection(noRsvp),
      ..._buildDeclinedAttendanceSection(declined),
    ];
  }

  List<Widget> _buildLeaderAttendanceApprovalList(
    MatchDetails match,
    List<EventAttendanceDetails> attending,
    List<EventAttendanceDetails> declined,
    List<UserDetails> noRsvp,
  ) {
    final pending = attending.where((a) => a.isSelected == null).toList();
    final handled = attending.where((a) => a.isSelected != null).toList();
    final widgets = <Widget>[];

    widgets.add(
      _AttendanceApprovalSection(
        key: const ValueKey('pending-attendance-approval'),
        title: 'Afventer godkendelse (${pending.length})',
        collapsible: false,
        children: pending.isEmpty
            ? const [_AttendanceApprovalEmpty()]
            : pending
                .map(
                  (attendance) => _AttendanceApprovalRow(
                    attendance: attendance,
                    isEditing: true,
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

    if (handled.isNotEmpty) {
      widgets.add(const SizedBox(height: Spacing.md));
      widgets.add(
        _AttendanceApprovalSection(
          key: const ValueKey('handled-attendance-approval'),
          title: 'Behandlet (${handled.length})',
          children: handled
              .map(
                (attendance) => _AttendanceApprovalRow(
                  attendance: attendance,
                  isEditing:
                      _editingAttendanceSelectionIds.contains(attendance.id),
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
                  onEdit: () => _editAttendanceSelection(attendance),
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

    widgets.addAll(_buildNoRsvpSection(noRsvp));
    widgets.addAll(_buildDeclinedAttendanceSection(declined));

    return widgets;
  }

  List<UserDetails> _membersWithoutRsvp(
    MatchDetails match,
    List<UserDetails> squad,
  ) {
    final attendanceUserIds = (match.attendanceDetailsList ?? [])
        .map((attendance) => attendance.userDetails.id)
        .toSet();

    return squad
        .where((member) => !attendanceUserIds.contains(member.id))
        .toList();
  }

  List<Widget> _buildNoRsvpSection(List<UserDetails> noRsvp) {
    if (noRsvp.isEmpty) return const [];

    return [
      const SizedBox(height: Spacing.lg),
      _AttendanceApprovalSection(
        key: const ValueKey('no-rsvp-attendance'),
        title: 'Mangler svar (${noRsvp.length})',
        children: noRsvp
            .map(
              (member) => PlayerListItem(
                name: member.name,
                subtitle: member.email,
                trailing: const Icon(CupertinoIcons.question_circle),
              ),
            )
            .toList(),
      ),
    ];
  }

  List<Widget> _buildDeclinedAttendanceSection(
    List<EventAttendanceDetails> declined,
  ) {
    if (declined.isEmpty) return const [];

    return [
      const SizedBox(height: Spacing.lg),
      _AttendanceApprovalSection(
        key: const ValueKey('declined-attendance'),
        title: 'Frameldte (${declined.length})',
        children: declined
            .map(
              (attendance) => PlayerListItem(
                name: attendance.userDetails.name,
                subtitle: 'Frameldt',
              ),
            )
            .toList(),
      ),
    ];
  }

  void _editAttendanceSelection(EventAttendanceDetails attendance) {
    if (_savingAttendanceSelectionIds.contains(attendance.id)) return;

    setState(() {
      _editingAttendanceSelectionIds.add(attendance.id);
    });
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
      if (mounted) {
        setState(() {
          _editingAttendanceSelectionIds.remove(attendance.id);
        });
      }
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
            attendance.isAttending &&
            (attendance.isSelected == true || attendance.lineupSlot != null))
        .toList()
      ..sort(_compareLineupAttendance);

    final selectedUsers =
        selected.map((attendance) => attendance.userDetails).toList();

    if (selectedUsers.isNotEmpty) return selectedUsers;

    return attendances
        .where((attendance) => attendance.isAttending)
        .map((attendance) => attendance.userDetails)
        .toList();
  }

  bool _hasSavedLineup(MatchDetails match) {
    return (match.attendanceDetailsList ?? []).any(
      (attendance) => attendance.isAttending && attendance.lineupSlot != null,
    );
  }

  List<UserDetails?> _lineupPositionedPlayers(
    MatchDetails match,
    UserDetails user,
  ) {
    final formation = PlayerFormation.fromString(
      match.formation,
      playerCount: _teamPlayerCount(match, user),
    );
    final positioned = List<UserDetails?>.filled(formation.slots.length, null);

    for (final attendance in match.attendanceDetailsList ?? []) {
      final slot = attendance.lineupSlot;
      if (!attendance.isAttending ||
          slot == null ||
          slot < 0 ||
          slot >= positioned.length) {
        continue;
      }

      positioned[slot] = attendance.userDetails;
    }

    return positioned;
  }

  int _compareLineupAttendance(
    EventAttendanceDetails first,
    EventAttendanceDetails second,
  ) {
    final firstSlot = first.lineupSlot;
    final secondSlot = second.lineupSlot;
    if (firstSlot != null && secondSlot != null) {
      return firstSlot.compareTo(secondSlot);
    }
    if (firstSlot != null) return -1;
    if (secondSlot != null) return 1;
    return first.createdAt.compareTo(second.createdAt);
  }

  Future<void> _openLineupEditor(MatchDetails match, UserDetails user) async {
    final updatedMatch = await Navigator.of(context).push<MatchDetails>(
      CupertinoPageRoute(
        builder: (context) => LineupEditorPage(
          match: match,
          playerCount: _teamPlayerCount(match, user),
        ),
      ),
    );

    if (updatedMatch != null && mounted) {
      AppAnalytics.logEvent('match_lineup_updated');
      setState(() {
        _matchAndSquadData = {
          ...?_matchAndSquadData,
          'matchDetails': updatedMatch,
        };
        _loadError = null;
      });
    }
  }

  Future<void> _toggleLineupVisibility(MatchDetails match) async {
    if (_isUpdatingLineupVisibility) return;

    setState(() {
      _isUpdatingLineupVisibility = true;
    });

    try {
      final updatedMatch = await MatchRepository.updateMatchLineupVisibility(
        match.id,
        !match.lineupVisible,
      );
      AppAnalytics.logEvent(
        'match_lineup_visibility_updated',
        parameters: {'lineup_visible': updatedMatch.lineupVisible},
      );
      if (!mounted) return;
      setState(() {
        _matchAndSquadData = {
          ...?_matchAndSquadData,
          'matchDetails': updatedMatch,
        };
        _loadError = null;
      });
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke ændre synligheden. Prøv igen.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLineupVisibility = false;
        });
      }
    }
  }

  Future<void> _registerForMatch(MatchDetails match) async {
    if (_isUpdatingRegistration) return;

    setState(() {
      _isUpdatingRegistration = true;
    });

    try {
      await MatchRepository.registerForMatch(match.id);
      AppAnalytics.logEvent('match_registered');
      await _refreshMatchAndSquad();
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke tilmelde dig kampen. Prøv igen.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingRegistration = false;
        });
      }
    }
  }

  Future<void> _unregisterFromMatch(MatchDetails match) async {
    if (_isUpdatingRegistration) return;

    setState(() {
      _isUpdatingRegistration = true;
    });

    try {
      await MatchRepository.unregisterFromMatch(match.id);
      AppAnalytics.logEvent('match_unregistered');
      await _refreshMatchAndSquad();
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke melde afbud. Prøv igen.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingRegistration = false;
        });
      }
    }
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

    return '${countdown.inDays} dage ${countdown.inHours % 24} timer';
  }

  Future<void> _openNavigation(MatchDetails match) async {
    final query = Uri.encodeComponent(match.location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _LocationMapsLink extends StatelessWidget {
  final String location;
  final VoidCallback onPressed;

  const _LocationMapsLink({
    required this.location,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      minimumSize: const Size(0, 28),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              location,
              style: styles.body3.copyWith(
                color: colors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            CupertinoIcons.location_north,
            color: colors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _PrematchRsvpBar extends StatelessWidget {
  final MatchDetails match;
  final UserDetails currentUser;
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PrematchRsvpBar({
    required this.match,
    required this.currentUser,
    required this.isSaving,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final attendance = _currentUserAttendance;
    final isDeclined = attendance?.isAttending == false;
    final isAttending = match.isCurrentUserRegistered ||
        (attendance != null && attendance.isAttending);

    if (isAttending && !isDeclined) {
      return _PrematchRsvpStatusBar(
        message: 'Du er tilmeldt kampen!',
        messageColor: const Color(0xFF00964E),
        backgroundColor: const Color(0xFFE8F2ED),
        icon: CupertinoIcons.checkmark_alt,
        actionText: 'Kan ikke alligevel? Meld afbud',
        actionColor: const Color(0xFF877B70),
        isSaving: isSaving,
        onAction: onDecline,
      );
    }

    if (isDeclined) {
      return _PrematchRsvpStatusBar(
        message: 'Du har meldt afbud',
        messageColor: const Color(0xFF524438),
        backgroundColor: const Color(0xFFF1F4F2),
        actionText: 'Alligevel klar? Tilmeld dig',
        actionColor: const Color(0xFF00964E),
        isSaving: isSaving,
        onAction: onAccept,
      );
    }

    return _PrematchRsvpChoiceBar(
      isSaving: isSaving,
      onAccept: onAccept,
      onDecline: onDecline,
    );
  }

  EventAttendanceDetails? get _currentUserAttendance {
    for (final attendance in match.attendanceDetailsList ?? []) {
      if (attendance.userDetails.id == currentUser.id) return attendance;
    }
    return null;
  }
}

class _PrematchRsvpChoiceBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PrematchRsvpChoiceBar({
    required this.isSaving,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return _PrematchStickySurface(
      child: Row(
        children: [
          Expanded(
            child: _PrematchRsvpButton(
              label: 'Nej, kan ikke',
              foregroundColor: const Color(0xFF524438),
              backgroundColor: Colors.transparent,
              borderColor: const Color(0xFF524438),
              isSaving: isSaving,
              onPressed: onDecline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PrematchRsvpButton(
              label: 'Ja, jeg kommer',
              icon: CupertinoIcons.checkmark_alt,
              foregroundColor: Colors.white,
              backgroundColor: colors.primary,
              isSaving: isSaving,
              onPressed: onAccept,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrematchRsvpStatusBar extends StatelessWidget {
  final String message;
  final Color messageColor;
  final Color backgroundColor;
  final IconData? icon;
  final String actionText;
  final Color actionColor;
  final bool isSaving;
  final VoidCallback onAction;

  const _PrematchRsvpStatusBar({
    required this.message,
    required this.messageColor,
    required this.backgroundColor,
    required this.actionText,
    required this.actionColor,
    required this.isSaving,
    required this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return _PrematchStickySurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: messageColor, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    message,
                    style: styles.body3.copyWith(
                      color: messageColor,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            minimumSize: const Size(0, 30),
            padding: const EdgeInsets.only(top: 8),
            onPressed: isSaving ? null : onAction,
            child: isSaving
                ? const CupertinoActivityIndicator(radius: 8)
                : Text(
                    actionText,
                    style: styles.caption2.copyWith(
                      color: actionColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrematchRsvpButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final bool isSaving;
  final VoidCallback onPressed;

  const _PrematchRsvpButton({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.isSaving,
    required this.onPressed,
    this.icon,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isSaving ? null : onPressed,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor ?? backgroundColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSaving
            ? CupertinoActivityIndicator(color: foregroundColor)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foregroundColor, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: styles.body3.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PrematchStickySurface extends StatelessWidget {
  final Widget child;

  const _PrematchStickySurface({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.white.withValues(alpha: 0.93),
        border: const Border(
          top: BorderSide(color: Color(0xFFE0E6E2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

class _AttendanceApprovalSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool collapsible;

  const _AttendanceApprovalSection({
    super.key,
    required this.title,
    required this.children,
    this.collapsible = true,
  });

  @override
  State<_AttendanceApprovalSection> createState() =>
      _AttendanceApprovalSectionState();
}

class _AttendanceApprovalSectionState
    extends State<_AttendanceApprovalSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    if (!widget.collapsible) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: styles.subtitle2),
          const SizedBox(height: Spacing.sm),
          ...widget.children,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          toggled: _isExpanded,
          label: widget.title,
          child: CupertinoButton(
            minimumSize: const Size(0, 36),
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: styles.subtitle2.copyWith(color: colors.black),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    size: 18,
                    color: colors.dirt,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _isExpanded
              ? Column(
                  key: const ValueKey('expanded-attendance-section'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.sm),
                    ...widget.children,
                  ],
                )
              : const SizedBox.shrink(
                  key: ValueKey('collapsed-attendance-section'),
                ),
        ),
      ],
    );
  }
}

class _AttendanceApprovalRow extends StatelessWidget {
  final EventAttendanceDetails attendance;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onEdit;

  const _AttendanceApprovalRow({
    required this.attendance,
    required this.isEditing,
    required this.isSaving,
    required this.onApprove,
    required this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final user = attendance.userDetails;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: attendance.isSelected != null && !isEditing ? 0.88 : 1,
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
            else if (!isEditing && attendance.isSelected != null)
              _AttendanceSelectionBadge(
                isSelected: attendance.isSelected == true,
                onEdit: onEdit,
                userName: user.name,
              )
            else
              _AttendanceSelectionActions(
                userName: user.name,
                onApprove: onApprove,
                onReject: onReject,
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

class _AttendanceSelectionActions extends StatelessWidget {
  final String userName;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AttendanceSelectionActions({
    required this.userName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AttendanceActionButton(
          icon: CupertinoIcons.xmark,
          color: colors.error,
          backgroundColor: const Color(0xFFFFEBEE),
          semanticLabel: 'Afvis $userName',
          onPressed: onReject,
        ),
        const SizedBox(width: Spacing.sm),
        _AttendanceActionButton(
          icon: CupertinoIcons.checkmark_alt,
          color: colors.primary,
          backgroundColor: const Color(0xFFE8F5E9),
          semanticLabel: 'Godkend $userName',
          onPressed: onApprove,
        ),
      ],
    );
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

class _AttendanceSelectionBadge extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onEdit;
  final String userName;

  const _AttendanceSelectionBadge({
    required this.isSelected,
    required this.onEdit,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final color = isSelected ? colors.primary : colors.error;
    final backgroundColor =
        isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon =
        isSelected ? CupertinoIcons.checkmark_alt : CupertinoIcons.xmark;
    final label = isSelected ? 'Godkendt' : 'Afvist';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: styles.caption2.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        _AttendanceActionButton(
          icon: CupertinoIcons.pencil,
          color: colors.dirt,
          backgroundColor: colors.white,
          semanticLabel: 'Rediger valg for $userName',
          onPressed: onEdit ?? () {},
        ),
      ],
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
