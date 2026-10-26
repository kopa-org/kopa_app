import 'package:flutter/material.dart';
import 'package:kopa/component/match/match_events_timeline.dart';
import 'package:kopa/component/match/match_poll_details_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/spacing.dart';

class PostMatchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  final UserDetails user;
  final Widget heroCard;
  final Widget? headerAction;
  final Widget? belowHeaderAction;
  final List<Widget> attendanceList;
  final Future<void> Function()? onRefresh;
  final VoidCallback onAddEvent;
  final VoidCallback? onCreateMatchPoll;
  final VoidCallback? onEditMatchPoll;
  final ValueChanged<int>? onDeleteEvent;
  final Future<void> Function(List<int>)? onReorderEvents;
  final Widget? attendanceActionBar;
  final MatchDetailSegment selectedSegment;
  final ValueChanged<MatchDetailSegment> onSegmentChanged;
  final Widget? bottomNavigationBar;
  final bool useParentBottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? playerPositions;
  final List<Widget> infoRows;
  final String attendanceSegmentLabel;
  final String timelineLabel;

  const PostMatchDetailsPage({
    super.key,
    required this.match,
    required this.user,
    required this.heroCard,
    this.headerAction,
    this.belowHeaderAction,
    required this.attendanceList,
    required this.onAddEvent,
    this.onCreateMatchPoll,
    this.onEditMatchPoll,
    this.onDeleteEvent,
    this.onReorderEvents,
    this.attendanceActionBar,
    required this.selectedSegment,
    required this.onSegmentChanged,
    this.onRefresh,
    this.bottomNavigationBar,
    this.useParentBottomNavigationBar = false,
    this.floatingActionButton,
    this.playerPositions,
    this.infoRows = const [],
    this.attendanceSegmentLabel = 'Tilmeldte',
    this.timelineLabel = 'Kampbegivenheder',
  });

  @override
  Widget build(BuildContext context) {
    return MatchDetailTemplate(
      onRefresh: onRefresh,
      useDarkMatchHeader: true,
      selectedSegment: selectedSegment,
      onSegmentChanged: onSegmentChanged,
      heroCard: heroCard,
      headerAction: headerAction,
      belowHeaderAction: belowHeaderAction,
      // Same tabs and layout as before the match, so the page feels familiar.
      usePrematchLayout: true,
      overviewWidgetsBeforeInfo: true,
      overviewTitle: 'Praktisk information',
      attendanceTitle: 'Tilmeldte spillere',
      timelineTitle: timelineLabel,
      attendanceSegmentLabel: attendanceSegmentLabel,
      timelineSegmentLabel: timelineLabel,
      showTimelineSegment: true,
      timelineEmptyMessage: 'Ingen kampbegivenheder registreret endnu.',
      overviewWidgets: [
        if (match.matchPollDetails == null)
          PlayerOfMatchSummaryCard(
            playerName: null,
            onPressed: onCreateMatchPoll,
          )
        else
          MatchPollDetailsCard(
            poll: match.matchPollDetails!,
            onEdit: onEditMatchPoll,
          ),
        if (infoRows.isNotEmpty) const SizedBox(height: Spacing.lg),
      ],
      infoRows: infoRows,
      votingModule: null,
      playerPositions: playerPositions,
      attendanceList: attendanceList,
      ratingsSection: null,
      timelineItems: [
        MatchEventsTimeline(
          events: match.matchEventDetailsList ?? const [],
          canAddEvent: true,
          canReorderEvents: onReorderEvents != null,
          onAddEvent: onAddEvent,
          onDeleteEvent: onDeleteEvent,
          onReorderEvents: onReorderEvents,
          // The tab already shows the section title.
          showTitle: false,
        ),
      ],
      bottomNavigationBar: bottomNavigationBar,
      attendanceActionBar: attendanceActionBar,
      useParentBottomNavigationBar: useParentBottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
