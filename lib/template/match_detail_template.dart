import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

enum MatchDetailSegment {
  overview,
  attendance,
  timeline,
}

class MatchDetailTemplate extends StatelessWidget {
  final Widget heroCard;
  final List<Widget> overviewWidgets;
  final List<Widget> infoRows;
  final List<Widget> attendanceList;
  final List<Widget> timelineItems;
  final Widget? votingModule;
  final Widget? ratingsSection;
  final Widget? playerPositions;
  final Future<void> Function()? onRefresh;
  final MatchDetailSegment selectedSegment;
  final ValueChanged<MatchDetailSegment>? onSegmentChanged;
  final String overviewTitle;
  final String attendanceTitle;
  final String timelineTitle;
  final String overviewSegmentLabel;
  final String attendanceSegmentLabel;
  final String timelineSegmentLabel;
  final String attendanceEmptyMessage;
  final String timelineEmptyMessage;
  final bool showTimelineSegment;
  final bool usePrematchLayout;
  final Widget? stickyActionBar;

  const MatchDetailTemplate({
    super.key,
    required this.heroCard,
    this.overviewWidgets = const [],
    this.infoRows = const [],
    this.attendanceList = const [],
    this.timelineItems = const [],
    this.votingModule,
    this.ratingsSection,
    this.playerPositions,
    this.onRefresh,
    this.selectedSegment = MatchDetailSegment.overview,
    this.onSegmentChanged,
    this.overviewTitle = 'Praktisk information',
    this.attendanceTitle = 'Tilmeldte spillere',
    this.timelineTitle = 'Kampforløb',
    this.overviewSegmentLabel = 'Overblik',
    this.attendanceSegmentLabel = 'Tilmeldte',
    this.timelineSegmentLabel = 'Kampforløb',
    this.attendanceEmptyMessage = 'Ingen tilmeldte spillere endnu.',
    this.timelineEmptyMessage = 'Ingen begivenheder registreret.',
    this.showTimelineSegment = true,
    this.usePrematchLayout = false,
    this.stickyActionBar,
  });

  @override
  Widget build(BuildContext context) {
    if (usePrematchLayout) {
      return PageScaffold(
        title: 'Kampdetaljer',
        showTopBar: false,
        onRefresh: onRefresh,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                stickyActionBar == null ? 32 : 220,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MatchDetailsHeader(),
                  heroCard,
                  const SizedBox(height: 20),
                  _buildSegmentedControl(context),
                  const SizedBox(height: 20),
                  ..._buildSelectedSegment(context),
                ],
              ),
            ),
            if (stickyActionBar != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: stickyActionBar!,
              ),
          ],
        ),
      );
    }

    return PageScaffold(
      title: 'Kampdetaljer',
      showTopBar: false,
      onRefresh: onRefresh,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _MatchDetailsHeader(),
                heroCard,
                const SizedBox(height: Spacing.lg),
                _buildSegmentedControl(context),
                const SizedBox(height: Spacing.lg),
                ..._buildSelectedSegment(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final segments = <({MatchDetailSegment segment, String label})>[
      (segment: MatchDetailSegment.overview, label: overviewSegmentLabel),
      (segment: MatchDetailSegment.attendance, label: attendanceSegmentLabel),
      if (showTimelineSegment)
        (segment: MatchDetailSegment.timeline, label: timelineSegmentLabel),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          for (var index = 0; index < segments.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: _MatchDetailSegmentButton(
                key: ValueKey(
                  'match-details-segment-${segments[index].segment.name}',
                ),
                segment: segments[index].segment,
                label: segments[index].label,
                selected: _effectiveSelectedSegment == segments[index].segment,
                textStyle: styles.body3,
                onPressed: () => onSegmentChanged?.call(
                  segments[index].segment,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  MatchDetailSegment get _effectiveSelectedSegment {
    if (!showTimelineSegment &&
        selectedSegment == MatchDetailSegment.timeline) {
      return MatchDetailSegment.overview;
    }

    return selectedSegment;
  }

  List<Widget> _buildSelectedSegment(BuildContext context) {
    final effectiveSegment =
        !showTimelineSegment && selectedSegment == MatchDetailSegment.timeline
            ? MatchDetailSegment.overview
            : selectedSegment;

    switch (effectiveSegment) {
      case MatchDetailSegment.overview:
        if (usePrematchLayout) {
          return [
            if (infoRows.isNotEmpty) ...[
              const SizedBox(height: 18),
              _PrematchSectionTitle(title: overviewTitle),
              _PrematchInfoCard(children: infoRows),
            ],
            ...overviewWidgets,
            if (playerPositions != null) ...[
              const SizedBox(height: 26),
              _PrematchSectionTitle(title: 'Holdopstilling'),
              playerPositions!,
              const SizedBox(height: 18),
            ],
          ];
        }

        return [
          ...overviewWidgets,
          if (infoRows.isNotEmpty) ...[
            SectionHeader(title: overviewTitle),
            ...infoRows,
          ],
          if (votingModule != null) ...[
            const SizedBox(height: Spacing.lg),
            const SectionHeader(title: 'Afstemning'),
            votingModule!,
          ],
          if (playerPositions != null) ...[
            const SizedBox(height: Spacing.lg),
            playerPositions!,
          ],
          if (ratingsSection != null) ...[
            const SizedBox(height: Spacing.lg),
            const SectionHeader(title: 'Kamprating'),
            const SizedBox(height: Spacing.md),
            ratingsSection!,
          ],
        ];
      case MatchDetailSegment.attendance:
        return [
          if (attendanceList.isEmpty)
            _EmptySegmentMessage(message: attendanceEmptyMessage)
          else
            ...attendanceList,
        ];
      case MatchDetailSegment.timeline:
        return [
          SectionHeader(title: timelineTitle),
          const SizedBox(height: Spacing.md),
          if (timelineItems.isEmpty)
            _EmptySegmentMessage(message: timelineEmptyMessage)
          else
            ...timelineItems,
        ];
    }
  }
}

class _MatchDetailSegmentButton extends StatelessWidget {
  final MatchDetailSegment segment;
  final String label;
  final bool selected;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const _MatchDetailSegmentButton({
    super.key,
    required this.segment,
    required this.label,
    required this.selected,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF105230);
    const unselectedColor = Color(0xFF524438);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 30,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle.copyWith(
                        color: selected
                            ? selectedColor
                            : unselectedColor.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        height: 18 / 14,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    key: ValueKey(
                      'match-details-segment-${segment.name}-indicator',
                    ),
                    duration: const Duration(milliseconds: 220),
                    height: 2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: selected ? selectedColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchDetailsHeader extends StatelessWidget {
  const _MatchDetailsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      key: const ValueKey('match-details-scroll-header'),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: Row(
        children: [
          CupertinoButton(
            minimumSize: const Size(32, 32),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(
              CupertinoIcons.back,
              color: colors.dirt,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Kampdetaljer',
            style: styles.h5.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PrematchSectionTitle extends StatelessWidget {
  final String title;

  const _PrematchSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: styles.h5.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PrematchInfoCard extends StatelessWidget {
  final List<Widget> children;

  const _PrematchInfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _EmptySegmentMessage extends StatelessWidget {
  final String message;

  const _EmptySegmentMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      child: Center(
        child: Text(
          message,
          style: styles.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
