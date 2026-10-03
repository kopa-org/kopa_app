import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/match/match_details_sheet_scroll_view.dart';
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
  final String overviewTitle;
  final String attendanceTitle;
  final String timelineTitle;
  final String overviewSegmentLabel;
  final String attendanceSegmentLabel;
  final String timelineSegmentLabel;
  final String attendanceEmptyMessage;
  final String timelineEmptyMessage;
  final bool timelinePreview;
  final String timelinePreviewMessage;
  final bool showTimelineSegment;
  final bool usePrematchLayout;
  final Widget? attendanceHeader;
  final bool attendanceHeaderInBody;
  final Widget? stickyActionBar;
  final Widget? bottomNavigationBar;
  final Widget? attendanceActionBar;
  final bool useParentBottomNavigationBar;
  final String pageTitle;
  final bool useDarkMatchHeader;
  final bool useTrainingHeader;
  final Widget? belowHeaderAction;
  final Widget? floatingActionButton;

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
    this.overviewTitle = 'Praktisk information',
    this.attendanceTitle = 'Tilmeldte spillere',
    this.timelineTitle = 'Kampforløb',
    this.overviewSegmentLabel = 'Overblik',
    this.attendanceSegmentLabel = 'Tilmeldte',
    this.timelineSegmentLabel = 'Kampforløb',
    this.attendanceEmptyMessage = 'Ingen tilmeldte spillere endnu.',
    this.timelineEmptyMessage = 'Ingen begivenheder registreret.',
    this.timelinePreview = false,
    this.timelinePreviewMessage = '',
    this.showTimelineSegment = true,
    this.usePrematchLayout = false,
    this.attendanceHeader,
    this.attendanceHeaderInBody = false,
    this.stickyActionBar,
    this.bottomNavigationBar,
    this.attendanceActionBar,
    this.useParentBottomNavigationBar = false,
    this.pageTitle = 'Kampdetaljer',
    this.useDarkMatchHeader = false,
    this.useTrainingHeader = false,
    this.belowHeaderAction,
    this.floatingActionButton,
  });

  bool get _usesSheetHeader => useDarkMatchHeader || useTrainingHeader;

  Color _headerColor(BuildContext context) => useTrainingHeader
      ? AppColors.of(context).lightSky65
      : AppColors.matchDetailsHeader;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PageScaffold(
      title: pageTitle,
      showTopBar: false,
      backgroundColor: _usesSheetHeader ? _headerColor(context) : null,
      systemOverlayStyle: _usesSheetHeader
          ? SystemUiOverlayStyle(
              statusBarColor: _headerColor(context),
              statusBarIconBrightness:
                  useTrainingHeader ? Brightness.dark : Brightness.light,
              statusBarBrightness:
                  useTrainingHeader ? Brightness.light : Brightness.dark,
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
                _MatchDetailsHeader(title: pageTitle, action: headerAction),
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
    return MatchDetailsSheetScrollView(
      onRefresh: onRefresh,
      headerBackgroundColor: _headerColor(context),
      header: ColoredBox(
        key: const ValueKey('match-details-dark-header'),
        color: _headerColor(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MatchDetailsHeader(
                title: pageTitle,
                action: headerAction,
                darkHeader: true,
                trainingHeader: useTrainingHeader,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: heroCard,
              ),
              if (_showAttendanceHeader && !attendanceHeaderInBody) ...[
                SizedBox(height: segmentSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: attendanceHeader!,
                ),
              ],
              SizedBox(height: segmentSpacing),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSegmentedControl(
                  context,
                  darkHeader: true,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, segmentSpacing, 16, bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (belowHeaderAction != null) ...[
              belowHeaderAction!,
              const SizedBox(height: Spacing.md),
            ],
            if (_showAttendanceHeader && attendanceHeaderInBody) ...[
              attendanceHeader!,
              const SizedBox(height: Spacing.md),
            ],
            ..._buildSelectedSegment(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(
    BuildContext context, {
    bool darkHeader = false,
  }) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final segments = <({MatchDetailSegment segment, String label})>[
      (segment: MatchDetailSegment.overview, label: overviewSegmentLabel),
      (segment: MatchDetailSegment.attendance, label: attendanceSegmentLabel),
      if (showTimelineSegment)
        (segment: MatchDetailSegment.timeline, label: timelineSegmentLabel),
    ];

    final row = Row(
      children: [
        for (var index = 0; index < segments.length; index++) ...[
          if (index > 0) SizedBox(width: darkHeader ? 4 : 8),
          Expanded(
            child: _MatchDetailSegmentButton(
              key: ValueKey(
                'match-details-segment-${segments[index].segment.name}',
              ),
              segment: segments[index].segment,
              label: segments[index].label,
              selected: _effectiveSelectedSegment == segments[index].segment,
              textStyle: styles.body3,
              darkHeader: darkHeader,
              trainingHeader: useTrainingHeader,
              onPressed: () => onSegmentChanged?.call(
                segments[index].segment,
              ),
            ),
          ),
        ],
      ],
    );

    if (darkHeader) {
      return Container(
        key: const ValueKey('match-details-dark-segment-control'),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: useTrainingHeader
              ? AppColors.of(context).lightSky95
              : AppColors.matchDetailsHeaderTrack,
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

  bool get _showAttendanceHeader =>
      attendanceHeader != null &&
      _effectiveSelectedSegment == MatchDetailSegment.overview;

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
        if (timelinePreview) {
          return [
            _PrematchSectionTitle(title: timelineTitle),
            _PrematchTimelinePreview(
              items: timelineItems,
              message: timelinePreviewMessage,
            ),
          ];
        }

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
  final bool darkHeader;
  final bool trainingHeader;
  final VoidCallback onPressed;

  const _MatchDetailSegmentButton({
    super.key,
    required this.segment,
    required this.label,
    required this.selected,
    required this.textStyle,
    required this.darkHeader,
    required this.trainingHeader,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selectedColor = trainingHeader
        ? colors.sky
        : darkHeader
            ? AppColors.matchDetailsHeader
            : AppColors.of(context).successForeground;
    final unselectedColor = trainingHeader
        ? colors.textSecondary
        : darkHeader
            ? AppColors.matchDetailsHeaderMuted
            : AppColors.of(context).textSecondary;

    if (darkHeader) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onPressed,
            child: Container(
              key: ValueKey('match-details-segment-${segment.name}-surface'),
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? trainingHeader
                        ? colors.surface
                        : AppColors.matchDetailsHeaderForeground
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle.copyWith(
                    color: selected ? selectedColor : unselectedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 14 / 10,
                  ),
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
      child: Material(
        color: AppColors.transparent,
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
                      color: selected ? selectedColor : AppColors.transparent,
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
    final foreground =
        trainingHeader ? colors.dirt : AppColors.matchDetailsHeaderForeground;

    return Padding(
      key: const ValueKey('match-details-scroll-header'),
      padding: darkHeader
          ? const EdgeInsets.fromLTRB(16, 10, 16, 10)
          : const EdgeInsets.fromLTRB(0, 12, 0, 20),
      child: Row(
        children: [
          CupertinoButton(
            minimumSize: const Size(32, 32),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: darkHeader
                ? Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: trainingHeader
                          ? colors.lightSky95
                          : AppColors.matchDetailsHeaderBackButton,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      CupertinoIcons.back,
                      color: foreground,
                      size: 20,
                    ),
                  )
                : Icon(
                    CupertinoIcons.back,
                    color: colors.dirt,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: styles.h5.copyWith(
                color: darkHeader ? foreground : null,
                fontWeight: darkHeader ? FontWeight.w400 : FontWeight.w800,
                fontSize: darkHeader ? 17 : null,
              ),
            ),
          ),
          if (action != null)
            if (darkHeader)
              IconTheme.merge(
                data: IconThemeData(
                  color: foreground,
                ),
                child: action!,
              )
            else
              action!,
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
