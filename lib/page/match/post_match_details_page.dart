import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match/match_poll_details_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PostMatchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  final UserDetails user;
  final Widget heroCard;
  final Widget? headerAction;
  final List<Widget> attendanceList;
  final Future<void> Function()? onRefresh;
  final VoidCallback onAddEvent;
  final ValueChanged<int>? onDeleteEvent;
  final Future<void> Function(List<int>)? onReorderEvents;
  final Widget? attendanceActionBar;
  final VoidCallback onSetMatchScore;
  final VoidCallback onCreateMatchPoll;
  final VoidCallback? onEditMatchPoll;
  final MatchDetailSegment selectedSegment;
  final ValueChanged<MatchDetailSegment> onSegmentChanged;
  final Widget? bottomNavigationBar;
  final bool useParentBottomNavigationBar;

  const PostMatchDetailsPage({
    super.key,
    required this.match,
    required this.user,
    required this.heroCard,
    this.headerAction,
    required this.attendanceList,
    required this.onAddEvent,
    this.onDeleteEvent,
    this.onReorderEvents,
    this.attendanceActionBar,
    required this.onSetMatchScore,
    required this.onCreateMatchPoll,
    this.onEditMatchPoll,
    required this.selectedSegment,
    required this.onSegmentChanged,
    this.onRefresh,
    this.bottomNavigationBar,
    this.useParentBottomNavigationBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MatchDetailTemplate(
      onRefresh: onRefresh,
      selectedSegment: selectedSegment,
      onSegmentChanged: onSegmentChanged,
      heroCard: heroCard,
      headerAction: headerAction,
      overviewTitle: 'Efter kampen',
      attendanceTitle: 'Tilmeldte',
      timelineTitle: 'Kampbegivenheder',
      attendanceSegmentLabel: 'Tilmeldte',
      timelineSegmentLabel: 'Begivenheder',
      showTimelineSegment: false,
      timelineEmptyMessage: 'Ingen kampbegivenheder registreret endnu.',
      overviewWidgets: [
        if (match.matchPollDetails == null)
          PlayerOfMatchSummaryCard(
            playerName: null,
            onPressed: user.canManageTeam ? onCreateMatchPoll : null,
          )
        else
          MatchPollDetailsCard(
            poll: match.matchPollDetails!,
            onEdit: user.canManageTeam ? onEditMatchPoll : null,
          ),
        const SizedBox(height: Spacing.lg),
        _MatchTimelineSection(
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
    );
  }
}

class _TimelineEventItem {
  final String title;
  final String timeLabel;
  final IconData icon;
  final Color? iconColor;
  final String subtitle;

  const _TimelineEventItem({
    required this.title,
    required this.timeLabel,
    required this.icon,
    this.iconColor,
    required this.subtitle,
  });

  factory _TimelineEventItem.from(MatchEventDetails event) {
    final minute = event.minute != null ? '${event.minute}\'' : null;

    if (event.type == MatchEventType.goal) {
      return _TimelineEventItem(
        title: 'Mål: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'MÅL',
        icon: Icons.sports_soccer,
        subtitle: event.assistMakerUserName != null
            ? 'Assisteret af ${event.assistMakerUserName}'
            : 'Mål',
      );
    }

    if (event.type == MatchEventType.yellowCard) {
      return _TimelineEventItem(
        title: 'Gult kort: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'KORT',
        icon: Icons.square,
        iconColor: Colors.yellow,
        subtitle: 'Gult kort',
      );
    }

    if (event.type == MatchEventType.redCard) {
      return _TimelineEventItem(
        title: 'Rødt kort: ${event.goalscorerUserName}',
        timeLabel: minute ?? 'KORT',
        icon: Icons.square,
        iconColor: Colors.red,
        subtitle: 'Rødt kort',
      );
    }

    if (event.type == MatchEventType.substitution) {
      return _TimelineEventItem(
        title:
            '${event.goalscorerUserName} (Ind) / ${event.assistMakerUserName ?? '?'} (Ud)',
        timeLabel: minute ?? 'UDSK.',
        icon: Icons.swap_horiz,
        subtitle: 'Udskiftning',
      );
    }

    return _TimelineEventItem(
      title: 'Straffe: ${event.goalscorerUserName}',
      timeLabel: minute ?? 'STRAFFE',
      icon: Icons.sports_soccer,
      iconColor: Colors.orange,
      subtitle: 'Straffespark',
    );
  }
}

class _MatchTimelineSection extends StatefulWidget {
  final List<MatchEventDetails> events;
  final bool canAddEvent;
  final bool canReorderEvents;
  final VoidCallback onAddEvent;
  final ValueChanged<int>? onDeleteEvent;
  final Future<void> Function(List<int>)? onReorderEvents;

  const _MatchTimelineSection({
    required this.events,
    required this.canAddEvent,
    required this.canReorderEvents,
    required this.onAddEvent,
    required this.onDeleteEvent,
    required this.onReorderEvents,
  });

  @override
  State<_MatchTimelineSection> createState() => _MatchTimelineSectionState();
}

class _MatchTimelineSectionState extends State<_MatchTimelineSection> {
  late List<MatchEventDetails> _events;
  bool _savingOrder = false;

  @override
  void initState() {
    super.initState();
    _events = _sortMatchEvents(widget.events);
  }

  @override
  void didUpdateWidget(covariant _MatchTimelineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.events, widget.events)) {
      _events = _sortMatchEvents(widget.events);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_events.isEmpty) {
      return _MatchTimelineEmptyState(
        canAddEvent: widget.canAddEvent,
        onAddEvent: widget.onAddEvent,
      );
    }

    final l10n = AppLocalizations.of(context)!;
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
          child: Column(
            children: [
              TimelineItem(
                title: l10n.matchTimelineKickoff,
                time: '0\'',
                icon: Icons.play_arrow,
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _events.length,
                onReorder: _reorderEvents,
                itemBuilder: (context, index) => _buildEventItem(
                  context,
                  _events[index],
                  index,
                  l10n,
                ),
              ),
              TimelineItem(
                title: l10n.matchTimelineFullTime,
                time: '90\'',
                icon: Icons.flag,
                isLast: true,
              ),
            ],
          ),
        ),
        if (widget.canAddEvent) ...[
          const SizedBox(height: Spacing.lg),
          _AddMatchEventOutlineButton(onPressed: widget.onAddEvent),
        ],
      ],
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    MatchEventDetails event,
    int index,
    AppLocalizations l10n,
  ) {
    final item = _TimelineEventItem.from(event);
    final trailing = <Widget>[];

    if (widget.onDeleteEvent != null) {
      trailing.add(
        IconButton(
          key: ValueKey('delete-match-event-${event.id}'),
          tooltip: l10n.commonDelete,
          icon: const Icon(CupertinoIcons.delete),
          onPressed: () => widget.onDeleteEvent!(event.id),
        ),
      );
    }

    if (widget.canReorderEvents && _events.length > 1 && !_savingOrder) {
      trailing.add(
        ReorderableDragStartListener(
          index: index,
          child: Tooltip(
            message: l10n.matchEventReorderTooltip,
            child: const SizedBox(
              width: 40,
              height: 48,
              child: Icon(Icons.drag_handle),
            ),
          ),
        ),
      );
    }

    return TimelineItem(
      key: ValueKey('match-event-timeline-${event.id}'),
      title: item.title,
      time: item.timeLabel,
      icon: item.icon,
      iconColor: item.iconColor,
      subtitle: item.subtitle,
      trailing: trailing.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: trailing),
    );
  }

  Future<void> _reorderEvents(int oldIndex, int newIndex) async {
    if (_savingOrder ||
        oldIndex == newIndex ||
        widget.onReorderEvents == null) {
      return;
    }

    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (adjustedIndex == oldIndex) return;

    final previousEvents = List<MatchEventDetails>.of(_events);
    final reorderedEvents = List<MatchEventDetails>.of(_events);
    final movedEvent = reorderedEvents.removeAt(oldIndex);
    reorderedEvents.insert(adjustedIndex, movedEvent);

    setState(() {
      _events = reorderedEvents;
      _savingOrder = true;
    });

    try {
      await widget.onReorderEvents!(
        reorderedEvents.map((event) => event.id).toList(growable: false),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = previousEvents;
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.matchEventReorderFailed),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingOrder = false;
        });
      }
    }
  }
}

List<MatchEventDetails> _sortMatchEvents(List<MatchEventDetails> events) {
  final hasSavedOrder = events.every((event) => event.sortOrder != null);
  final sortedEvents = List<MatchEventDetails>.of(events);

  sortedEvents.sort((a, b) {
    if (hasSavedOrder) {
      final orderComparison = a.sortOrder!.compareTo(b.sortOrder!);
      if (orderComparison != 0) return orderComparison;
    }

    final minuteComparison = (a.minute ?? 0).compareTo(b.minute ?? 0);
    if (minuteComparison != 0) return minuteComparison;
    return a.id.compareTo(b.id);
  });

  return sortedEvents;
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
