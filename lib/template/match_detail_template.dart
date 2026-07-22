import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Kampdetaljer',
      showBackButton: true,
      onRefresh: onRefresh,
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heroCard,
            const SizedBox(height: Spacing.lg),
            _buildSegmentedControl(context),
            const SizedBox(height: Spacing.lg),
            ..._buildSelectedSegment(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
        border: Border.all(
          color: colors.grass.withValues(alpha: 0.22),
        ),
      ),
      child: SegmentedButtonSlide(
        selectedEntry: _segmentIndex(selectedSegment),
        onChange: (index) => onSegmentChanged?.call(_segmentFromIndex(index)),
        animationDuration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 40,
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
        textOverflow: TextOverflow.ellipsis,
        colors: SegmentedButtonSlideColors(
          barColor: colors.offWhite,
          backgroundSelectedColor: colors.lightGrass,
        ),
        selectedTextStyle: styles.caption.copyWith(
          color: colors.black,
          fontWeight: FontWeight.w700,
        ),
        unselectedTextStyle: styles.caption.copyWith(
          color: colors.dirt,
          fontWeight: FontWeight.w600,
        ),
        hoverTextStyle: styles.caption.copyWith(
          color: colors.grass,
          fontWeight: FontWeight.w600,
        ),
        slideShadow: [
          BoxShadow(
            color: colors.lightGrass.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        entries: [
          SegmentedButtonSlideEntry(
            label: overviewSegmentLabel,
          ),
          SegmentedButtonSlideEntry(
            label: attendanceSegmentLabel,
          ),
          SegmentedButtonSlideEntry(
            label: timelineSegmentLabel,
          ),
        ],
      ),
    );
  }

  int _segmentIndex(MatchDetailSegment segment) {
    return switch (segment) {
      MatchDetailSegment.overview => 0,
      MatchDetailSegment.attendance => 1,
      MatchDetailSegment.timeline => 2,
    };
  }

  MatchDetailSegment _segmentFromIndex(int index) {
    return switch (index) {
      1 => MatchDetailSegment.attendance,
      2 => MatchDetailSegment.timeline,
      _ => MatchDetailSegment.overview,
    };
  }

  List<Widget> _buildSelectedSegment(BuildContext context) {
    switch (selectedSegment) {
      case MatchDetailSegment.overview:
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
          SectionHeader(title: attendanceTitle),
          const SizedBox(height: Spacing.md),
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
