import 'package:flutter/material.dart';
import 'package:kopa/component/match/match_events_timeline.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/template/match_detail_template.dart';

class PostMatchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  final UserDetails user;
  final Widget heroCard;
  final Widget? headerAction;
  final Widget? belowHeaderAction;
  final List<Widget> attendanceList;
  final Future<void> Function()? onRefresh;
  final VoidCallback onAddEvent;
  final ValueChanged<int>? onDeleteEvent;
  final Future<void> Function(List<int>)? onReorderEvents;
  final Widget? attendanceActionBar;
  final MatchDetailSegment selectedSegment;
  final ValueChanged<MatchDetailSegment> onSegmentChanged;
  final Widget? bottomNavigationBar;
  final bool useParentBottomNavigationBar;
  final Widget? floatingActionButton;

  const PostMatchDetailsPage({
    super.key,
    required this.match,
    required this.user,
    required this.heroCard,
    this.headerAction,
    this.belowHeaderAction,
    required this.attendanceList,
    required this.onAddEvent,
    this.onDeleteEvent,
    this.onReorderEvents,
    this.attendanceActionBar,
    required this.selectedSegment,
    required this.onSegmentChanged,
    this.onRefresh,
    this.bottomNavigationBar,
    this.useParentBottomNavigationBar = false,
    this.floatingActionButton,
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
      overviewTitle: 'Efter kampen',
      attendanceTitle: 'Tilmeldte',
      timelineTitle: 'Kampbegivenheder',
      attendanceSegmentLabel: 'Tilmeldte',
      timelineSegmentLabel: 'Begivenheder',
      showTimelineSegment: false,
      timelineEmptyMessage: 'Ingen kampbegivenheder registreret endnu.',
      overviewWidgets: [
        MatchEventsTimeline(
          events: match.matchEventDetailsList ?? const [],
          canAddEvent: user.canManageTeam,
          canReorderEvents: user.canManageTeam && onReorderEvents != null,
          onAddEvent: onAddEvent,
          onDeleteEvent: onDeleteEvent,
          onReorderEvents: onReorderEvents,
        ),
      ],
      infoRows: const [],
      votingModule: null,
      playerPositions: null,
      attendanceList: attendanceList,
      ratingsSection: null,
      timelineItems: const [],
      bottomNavigationBar: bottomNavigationBar,
      attendanceActionBar: attendanceActionBar,
      useParentBottomNavigationBar: useParentBottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
