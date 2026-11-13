import 'dart:ui' show lerpDouble;

import 'package:kopa/l10n/current_l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/pitch_markings.dart';
import 'package:kopa/component/match/match_details_pinned_scroll_view.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

enum MatchDetailSegment {
  overview,
  attendance,
  lineup,
  timeline,
}

class MatchDetailTemplate extends StatelessWidget {
  final Widget heroCard;
  final Widget? headerAction;
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
  final String? overviewTitle;
  final String? attendanceTitle;
  final String? timelineTitle;
  final String? overviewSegmentLabel;
  final String? attendanceSegmentLabel;
  final String? timelineSegmentLabel;
  final String? attendanceEmptyMessage;
  final String? timelineEmptyMessage;
  final bool timelinePreview;
  final String timelinePreviewMessage;
  final bool showTimelineSegment;
  final bool timelineInOverview;
  final bool usePrematchLayout;
  final List<Widget> leadingOverviewWidgets;
  final bool timelineBeforeInfo;
  final Widget? attendanceHeader;
  final bool attendanceHeaderInBody;
  final Widget? stickyActionBar;
  final Widget? bottomNavigationBar;
  final Widget? attendanceActionBar;
  final bool useParentBottomNavigationBar;
  final String? pageTitle;
  final bool useDarkMatchHeader;
  final bool useTrainingHeader;
  final Widget? belowHeaderAction;
  final Widget? floatingActionButton;

  /// Lines the hero's team names take when expanded; see
  /// [MatchHeroCard.teamLabelLines].
  final int heroLabelLines;

  const MatchDetailTemplate({
    super.key,
    required this.heroCard,
    this.headerAction,
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
    this.overviewTitle,
    this.attendanceTitle,
    this.timelineTitle,
    this.overviewSegmentLabel,
    this.attendanceSegmentLabel,
    this.timelineSegmentLabel,
    this.attendanceEmptyMessage,
    this.timelineEmptyMessage,
    this.timelinePreview = false,
    this.timelinePreviewMessage = '',
    this.timelineInOverview = false,
    this.showTimelineSegment = true,
    this.usePrematchLayout = false,
    this.leadingOverviewWidgets = const [],
    this.timelineBeforeInfo = false,
    this.attendanceHeader,
    this.attendanceHeaderInBody = false,
    this.stickyActionBar,
    this.bottomNavigationBar,
    this.attendanceActionBar,
    this.useParentBottomNavigationBar = false,
    this.pageTitle,
    this.useDarkMatchHeader = false,
    this.useTrainingHeader = false,
    this.belowHeaderAction,
    this.floatingActionButton,
    this.heroLabelLines = 1,
  });

  static const double _navBarExtent = 52;

  String get _overviewTitle =>
      overviewTitle ?? currentL10n.uiPracticalInformation;

  String get _timelineTitle =>
      timelineTitle ?? currentL10n.matchEventTimelineTitle;

  String get _overviewSegmentLabel =>
      overviewSegmentLabel ?? currentL10n.fineBoxSegmentOverview;

  String get _attendanceSegmentLabel =>
      attendanceSegmentLabel ?? currentL10n.uiRegistered3;

  String get _timelineSegmentLabel =>
      timelineSegmentLabel ?? currentL10n.matchEventTimelineTitle;

  String get _attendanceEmptyMessage =>
      attendanceEmptyMessage ?? currentL10n.uiNoRegisteredPlayersYet;

  String get _timelineEmptyMessage =>
      timelineEmptyMessage ?? currentL10n.uiNoEventsRecorded2;

  String get _pageTitle => pageTitle ?? currentL10n.eventDetailsMatch;

  bool get _usesSheetHeader => useDarkMatchHeader || useTrainingHeader;

  /// Heights follow the text scale because the team names sit in the hero.
  double _heroExtent(BuildContext context, double collapse) {
    final lineHeight = MediaQuery.textScalerOf(context).scale(18);
    final expandedLabelHeight = lineHeight * heroLabelLines;
    return lerpDouble(84 + expandedLabelHeight, 36 + lineHeight, collapse)!;
  }

  double _navExtent(double collapse) => lerpDouble(_navBarExtent, 0, collapse)!;

  double _cardPadding(double collapse) => lerpDouble(8, 4, collapse)!;

  double _segmentTopGap(double collapse) => lerpDouble(8, 4, collapse)!;

  double _segmentTrackPadding(double collapse) => lerpDouble(4, 2, collapse)!;

  double _segmentButtonExtent(double collapse) => lerpDouble(44, 36, collapse)!;

  double _segmentExtent(double collapse) =>
      _segmentButtonExtent(collapse) + 2 * _segmentTrackPadding(collapse);

  double _headerExtent(BuildContext context, double collapse) =>
      MediaQuery.paddingOf(context).top +
      _navExtent(collapse) +
      2 * _cardPadding(collapse) +
      _heroExtent(context, collapse) +
      _segmentTopGap(collapse) +
      _segmentExtent(collapse);

  Color _headerColor(BuildContext context) => useTrainingHeader
      ? AppColors.of(context).lightSky65
      : AppColors.of(context).lightGrass;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PageScaffold(
      title: _pageTitle,
      showTopBar: false,
      useTopSafeArea: !_usesSheetHeader,
      backgroundColor: _usesSheetHeader ? colors.background : null,
      systemOverlayStyle: _usesSheetHeader
          ? SystemUiOverlayStyle(
              statusBarColor: _headerColor(context),
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )
          : null,
      onRefresh: _usesSheetHeader ? null : onRefresh,
      useBottomSafeArea:
          bottomNavigationBar == null && !useParentBottomNavigationBar,
      body: ColoredBox(
        key: const ValueKey('match-details-content-background'),
        color: colors.background,
        child: Column(
          children: [
            Expanded(child: _buildScrollableContent(context)),
            if (bottomNavigationBar != null) bottomNavigationBar!,
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    final segmentSpacing = usePrematchLayout ? 20.0 : Spacing.lg;
    final contentBottomPadding = useParentBottomNavigationBar
        ? mainTabBottomContentPadding(context)
        : 0.0;
    final showAttendanceActionBar = attendanceActionBar != null &&
        _effectiveSelectedSegment == MatchDetailSegment.attendance;
    const attendanceActionBarHeight = 80.0;
    final actionBarBottomPadding =
        showAttendanceActionBar ? attendanceActionBarHeight : 0.0;
    final stickyActionBarBottom = contentBottomPadding + actionBarBottomPadding;
    final bottomPadding = (usePrematchLayout
            ? stickyActionBar == null
                ? 32.0
                : 144.0
            : 32.0) +
        contentBottomPadding +
        actionBarBottomPadding +
        (floatingActionButton == null ? 0 : 72);
    final scrollContent = _usesSheetHeader
        ? _buildSheetHeaderContent(
            context: context,
            segmentSpacing: segmentSpacing,
            bottomPadding: bottomPadding,
          )
        : Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MatchDetailsHeader(title: _pageTitle, action: headerAction),
                heroCard,
                if (_showAttendanceHeader && !attendanceHeaderInBody) ...[
                  SizedBox(height: segmentSpacing),
                  attendanceHeader!,
                ],
                SizedBox(height: segmentSpacing),
                _buildSegmentedControl(context),
                SizedBox(height: segmentSpacing),
                if (_showAttendanceHeader && attendanceHeaderInBody) ...[
                  attendanceHeader!,
                  const SizedBox(height: Spacing.md),
                ],
                ..._buildSelectedSegment(context),
              ],
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_usesSheetHeader)
          scrollContent
        else
          SingleChildScrollView(child: scrollContent),
        if (stickyActionBar != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: stickyActionBarBottom,
            child: stickyActionBar!,
          ),
        if (showAttendanceActionBar)
          Positioned(
            left: 0,
            right: 0,
            bottom: contentBottomPadding,
            child: attendanceActionBar!,
          ),
        if (floatingActionButton != null)
          Positioned(
            right: 16,
            bottom: contentBottomPadding + actionBarBottomPadding + 16,
            child: floatingActionButton!,
          ),
      ],
    );
  }

  Widget _buildSheetHeaderContent({
    required BuildContext context,
    required double segmentSpacing,
    required double bottomPadding,
  }) {
    return MatchDetailsPinnedScrollView(
      onRefresh: onRefresh,
      expandedHeaderExtent: _headerExtent(context, 0),
      collapsedHeaderExtent: _headerExtent(context, 1),
      header: _buildPinnedHeader,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, segmentSpacing, 16, bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (belowHeaderAction != null) ...[
              belowHeaderAction!,
              const SizedBox(height: Spacing.md),
            ],
            if (_showAttendanceHeader && !usePrematchLayout) ...[
              attendanceHeader!,
              const SizedBox(height: Spacing.md),
            ],
            ..._buildSelectedSegment(context),
          ],
        ),
      ),
    );
  }

  /// How far the match band reaches down behind the white hero card.
  double _bandOverlap(double collapse) => lerpDouble(44, 18, collapse)!;

  Widget _buildPinnedHeader(BuildContext context, double collapse) {
    final colors = AppColors.of(context);
    final navHidden = collapse == 1;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroExtent = _heroExtent(context, collapse);
    // Trainings keep their sky header with the hero on it; matches put the
    // teams on a white card over a mint band, like the home hero.
    final useMatchBand = !useTrainingHeader;

    final navigation = SizedBox(
      height: _navExtent(collapse),
      child: ClipRect(
        child: OverflowBox(
          minHeight: _navBarExtent,
          maxHeight: _navBarExtent,
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            ignoring: navHidden,
            child: ExcludeSemantics(
              excluding: navHidden,
              child: Opacity(
                opacity: 1 - collapse,
                child: _MatchDetailsHeader(
                  title: _pageTitle,
                  action: headerAction,
                  darkHeader: true,
                  trainingHeader: useTrainingHeader,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget hero = SizedBox(
      height: heroExtent,
      child: ClipRect(
        child: OverflowBox(
          minHeight: 0,
          maxHeight: double.infinity,
          child: MatchHeroCollapse(
            value: collapse,
            child: heroCard,
          ),
        ),
      ),
    );

    if (useMatchBand) {
      const cardRadius = BorderRadius.all(
        Radius.circular(Spacing.borderRadiusLargeIncreased),
      );
      // The white card is drawn here at the exact collapsing height, outside
      // the clip, so its corners and shadow stay whole while it shrinks.
      hero = Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        child: DecoratedBox(
          key: const ValueKey('match-details-hero-surface'),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: cardRadius,
            boxShadow: [
              BoxShadow(
                // Tinted green so the shadow stays clean on the mint.
                color: colors.pitch.withValues(alpha: 0.10),
                blurRadius: lerpDouble(24, 12, collapse)!,
                offset: Offset(0, lerpDouble(10, 4, collapse)!),
              ),
            ],
          ),
          child: ClipRRect(borderRadius: cardRadius, child: hero),
        ),
      );
    }

    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The header colour reaches behind the phone's status bar.
        SizedBox(height: topInset),
        // The navigation row slides out while scrolling.
        navigation,
        Padding(
          padding: EdgeInsets.symmetric(vertical: _cardPadding(collapse)),
          child: hero,
        ),
      ],
    );

    return ColoredBox(
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (useMatchBand)
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topInset +
                      _navExtent(collapse) +
                      _cardPadding(collapse) +
                      _bandOverlap(collapse),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    child: ColoredBox(
                      key: const ValueKey('match-details-dark-header'),
                      color: _headerColor(context),
                      child: CustomPaint(
                        painter: PitchMarkingsPainter(
                          color: colors.grass.withValues(alpha: 0.32),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                headerContent,
              ],
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(Spacing.borderRadiusLargeIncreased),
              ),
              child: ColoredBox(
                key: const ValueKey('match-details-dark-header'),
                color: _headerColor(context),
                child: headerContent,
              ),
            ),
          SizedBox(height: _segmentTopGap(collapse)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSegmentedControl(
              context,
              darkHeader: true,
              collapse: collapse,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(
    BuildContext context, {
    bool darkHeader = false,
    double collapse = 0,
  }) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final segments = <({MatchDetailSegment segment, String label})>[
      (segment: MatchDetailSegment.overview, label: _overviewSegmentLabel),
      (segment: MatchDetailSegment.attendance, label: _attendanceSegmentLabel),
      if (playerPositions != null)
        (
          segment: MatchDetailSegment.lineup,
          label: AppLocalizations.of(context)!.matchDetailsLineupTab
        ),
      if (_hasTimelineSegment)
        (segment: MatchDetailSegment.timeline, label: _timelineSegmentLabel),
    ];

    // Trainings only have two tabs, so both stay fully labelled side by side.
    final row = useTrainingHeader
        ? Row(
            children: [
              for (var index = 0; index < segments.length; index++) ...[
                if (index > 0) SizedBox(width: darkHeader ? 4.0 : 8.0),
                Expanded(
                  child: _MatchDetailSegmentButton(
                    key: ValueKey(
                        'match-details-segment-${segments[index].segment.name}'),
                    segment: segments[index].segment,
                    label: segments[index].label,
                    selected:
                        _effectiveSelectedSegment == segments[index].segment,
                    collapsedWidth: 0,
                    expandedWidth: 0,
                    fixed: true,
                    textStyle: styles.body3,
                    darkHeader: darkHeader,
                    trainingHeader: useTrainingHeader,
                    height: _segmentButtonExtent(collapse),
                    onPressed: () =>
                        onSegmentChanged?.call(segments[index].segment),
                  ),
                ),
              ],
            ],
          )
        : LayoutBuilder(builder: (context, constraints) {
            final gap = darkHeader ? 4.0 : 8.0;
            final availableWidth =
                constraints.maxWidth - gap * (segments.length - 1);
            final collapsedWidth =
                (availableWidth / segments.length).clamp(0.0, 44.0);
            final maximumExpandedWidth =
                availableWidth - collapsedWidth * (segments.length - 1);
            double labelWidth(String label) {
              final painter = TextPainter(
                text: TextSpan(
                    text: label,
                    style: styles.body3
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: 1,
              )..layout();
              final width = (painter.width + 48)
                  .clamp(collapsedWidth, maximumExpandedWidth);
              painter.dispose();
              return width;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < segments.length; index++) ...[
                  if (index > 0) SizedBox(width: gap),
                  _MatchDetailSegmentButton(
                    key: ValueKey(
                        'match-details-segment-${segments[index].segment.name}'),
                    segment: segments[index].segment,
                    label: segments[index].label,
                    selected:
                        _effectiveSelectedSegment == segments[index].segment,
                    collapsedWidth: collapsedWidth,
                    expandedWidth: labelWidth(segments[index].label),
                    textStyle: styles.body3,
                    darkHeader: darkHeader,
                    trainingHeader: useTrainingHeader,
                    height: _segmentButtonExtent(collapse),
                    onPressed: () =>
                        onSegmentChanged?.call(segments[index].segment),
                  ),
                ],
              ],
            );
          });

    if (darkHeader) {
      return Container(
        key: const ValueKey('match-details-dark-segment-control'),
        padding: EdgeInsets.all(_segmentTrackPadding(collapse)),
        decoration: BoxDecoration(
          color: AppColors.of(context).background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: row,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: row,
    );
  }

  bool get _hasTimelineSegment => showTimelineSegment && !timelineInOverview;

  bool get _showAttendanceHeader =>
      attendanceHeader != null &&
      _effectiveSelectedSegment == MatchDetailSegment.overview;

  MatchDetailSegment get _effectiveSelectedSegment {
    if (!_hasTimelineSegment &&
        selectedSegment == MatchDetailSegment.timeline) {
      return MatchDetailSegment.overview;
    }
    if (playerPositions == null &&
        selectedSegment == MatchDetailSegment.lineup) {
      return MatchDetailSegment.overview;
    }

    return selectedSegment;
  }

  List<Widget> _buildSelectedSegment(BuildContext context) {
    final effectiveSegment = _effectiveSelectedSegment;

    switch (effectiveSegment) {
      case MatchDetailSegment.overview:
        if (usePrematchLayout) {
          final info = [
            if (infoRows.isNotEmpty) ...[
              _PrematchSectionTitle(title: _overviewTitle),
              _PrematchInfoCard(children: infoRows),
            ],
            if (_usesSheetHeader && _showAttendanceHeader) ...[
              const SizedBox(height: Spacing.md),
              attendanceHeader!,
              const SizedBox(height: Spacing.md),
            ],
          ];
          final timeline = [
            if (timelineInOverview && showTimelineSegment) ...[
              const SizedBox(height: 20),
              ..._buildTimelineSection(),
            ],
          ];
          return [
            ...leadingOverviewWidgets,
            if (timelineBeforeInfo) ...[
              ...timeline,
              const SizedBox(height: 20),
            ],
            ...info,
            ...overviewWidgets,
            if (!timelineBeforeInfo) ...timeline,
          ];
        }

        return [
          ...overviewWidgets,
          if (infoRows.isNotEmpty) ...[
            SectionHeader(title: _overviewTitle),
            ...infoRows,
          ],
          if (votingModule != null) ...[
            const SizedBox(height: Spacing.lg),
            SectionHeader(title: AppLocalizations.of(context)!.uiPoll),
            votingModule!,
          ],
          if (ratingsSection != null) ...[
            const SizedBox(height: Spacing.lg),
            SectionHeader(title: AppLocalizations.of(context)!.uiMatchRating),
            const SizedBox(height: Spacing.md),
            ratingsSection!,
          ],
        ];
      case MatchDetailSegment.lineup:
        return [playerPositions!];
      case MatchDetailSegment.attendance:
        return [
          if (attendanceList.isEmpty)
            _EmptySegmentMessage(message: _attendanceEmptyMessage)
          else
            ...attendanceList,
        ];
      case MatchDetailSegment.timeline:
        return _buildTimelineSection();
    }
  }

  List<Widget> _buildTimelineSection() {
    if (timelinePreview) {
      return [
        _PrematchSectionTitle(title: _timelineTitle),
        _PrematchTimelinePreview(
          items: timelineItems,
          message: timelinePreviewMessage,
        ),
      ];
    }

    return [
      if (usePrematchLayout)
        _PrematchSectionTitle(title: _timelineTitle)
      else ...[
        SectionHeader(title: _timelineTitle),
        const SizedBox(height: Spacing.md),
      ],
      if (timelineItems.isEmpty)
        _EmptySegmentMessage(message: _timelineEmptyMessage)
      else
        ...timelineItems,
    ];
  }
}

class _MatchDetailSegmentButton extends StatelessWidget {
  final MatchDetailSegment segment;
  final String label;
  final bool selected;
  final double collapsedWidth;
  final double expandedWidth;
  final bool fixed;
  final TextStyle textStyle;
  final bool darkHeader;
  final bool trainingHeader;
  final double height;
  final VoidCallback onPressed;

  const _MatchDetailSegmentButton({
    super.key,
    required this.segment,
    required this.label,
    required this.selected,
    required this.collapsedWidth,
    required this.expandedWidth,
    this.fixed = false,
    required this.textStyle,
    required this.darkHeader,
    required this.trainingHeader,
    this.height = 44,
    required this.onPressed,
  });

  IconData? get _icon => switch (segment) {
        MatchDetailSegment.overview => Icons.info_outline_rounded,
        MatchDetailSegment.attendance => Icons.groups_outlined,
        MatchDetailSegment.lineup => null,
        MatchDetailSegment.timeline => Icons.timeline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selectedColor = trainingHeader ? colors.sky : colors.dirt;
    final unselectedColor = colors.textSecondary;
    final background = selected
        ? darkHeader
            ? colors.surface
            : colors.lightGrass
        : AppColors.transparent;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 400);

    if (fixed) {
      final foreground = selected ? selectedColor : unselectedColor;
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: onPressed,
        child: SizedBox(
          height: height,
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onPressed,
              child: AnimatedContainer(
                key: ValueKey('match-details-segment-${segment.name}-surface'),
                duration: duration == Duration.zero
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_icon, size: 20, color: foreground),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle.copyWith(
                          color: foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: selected ? 1.0 : 0.0, end: selected ? 1.0 : 0.0),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, expansion, child) => SizedBox(
            width:
                collapsedWidth + (expandedWidth - collapsedWidth) * expansion,
            height: height,
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onPressed,
                child: Container(
                  key:
                      ValueKey('match-details-segment-${segment.name}-surface'),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (segment == MatchDetailSegment.lineup)
                        SvgPicture.asset(
                          'assets/icons/match/lineup.svg',
                          key: const ValueKey('match-details-lineup-icon'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            selected ? selectedColor : unselectedColor,
                            BlendMode.srcIn,
                          ),
                        )
                      else
                        Icon(_icon,
                            size: 20,
                            color: selected ? selectedColor : unselectedColor),
                      if (expansion > 0) ...[
                        SizedBox(width: 4 * expansion),
                        Expanded(
                          child: Opacity(
                            opacity: expansion,
                            child: Text(
                              label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle.copyWith(
                                color: selectedColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchDetailsHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final bool darkHeader;
  final bool trainingHeader;

  const _MatchDetailsHeader({
    required this.title,
    this.action,
    this.darkHeader = false,
    this.trainingHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final backButton = CupertinoButton(
      minimumSize: const Size(32, 32),
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.of(context).pop(),
      child: darkHeader
          ? Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: trainingHeader ? colors.lightSky95 : colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                CupertinoIcons.back,
                color: colors.dirt,
                size: 20,
              ),
            )
          : Icon(
              CupertinoIcons.back,
              color: colors.dirt,
              size: 30,
            ),
    );

    if (darkHeader) {
      return Padding(
        key: const ValueKey('match-details-scroll-header'),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            backButton,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: styles.h5.copyWith(
                  color: colors.dirt,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
            ),
            if (action != null)
              IconTheme.merge(
                data: IconThemeData(color: colors.dirt),
                child: action!,
              ),
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey('match-details-scroll-header'),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: Row(
        children: [
          backButton,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: styles.h5.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (action != null) action!,
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

class _PrematchTimelinePreview extends StatelessWidget {
  final List<Widget> items;
  final String message;

  const _PrematchTimelinePreview({
    required this.items,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(
          child: Opacity(
            key: const ValueKey('match-details-events-preview-content'),
            opacity: 0.38,
            child: KopaCard(
              borderRadius: Spacing.borderRadiusLargeIncreased,
              padding: const EdgeInsets.all(20),
              child: Column(children: items),
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Container(
          key: const ValueKey('match-details-events-preview-message'),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.grey2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: colors.grey5,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: styles.body3.copyWith(color: colors.grey5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
