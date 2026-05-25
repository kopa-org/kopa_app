import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/theme/spacing.dart';

class MatchDetailTemplate extends StatelessWidget {
  final Widget heroCard;
  final List<Widget> infoRows;
  final List<Widget> attendanceList;
  final List<Widget> timelineItems;
  final Widget? votingModule;
  final Widget? ratingsSection;
  final Future<void> Function()? onRefresh;

  const MatchDetailTemplate({
    super.key,
    required this.heroCard,
    this.infoRows = const [],
    this.attendanceList = const [],
    this.timelineItems = const [],
    this.votingModule,
    this.ratingsSection,
    this.onRefresh,
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
            if (infoRows.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Praktisk information'),
              ...infoRows,
            ],
            if (votingModule != null) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Afstemning'),
              votingModule!,
            ],
            if (attendanceList.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              SectionHeader(
                title: 'Tilmeldte spillere',
                actionText: 'Se alle',
                onActionPressed: () {},
              ),
              ...attendanceList,
            ],
            if (ratingsSection != null) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Kamprating'),
              const SizedBox(height: Spacing.md),
              ratingsSection!,
            ],
            if (timelineItems.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Kampforløb'),
              const SizedBox(height: Spacing.md),
              ...timelineItems,
            ],
          ],
        ),
      ),
    );
  }
}
