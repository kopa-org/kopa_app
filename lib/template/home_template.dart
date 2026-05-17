import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/section_header/section_header.dart';
import 'package:kopa/theme/spacing.dart';

class HomeTemplate extends StatelessWidget {
  final Widget nextMatchCard;
  final List<Widget> taskCards;
  final List<Widget> statCards;
  final Widget? previousMatchCard;
  final Future<void> Function()? onRefresh;

  const HomeTemplate({
    super.key,
    required this.nextMatchCard,
    this.taskCards = const [],
    this.statCards = const [],
    this.previousMatchCard,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Kopa',
      onRefresh: onRefresh,
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Næste kamp'),
            nextMatchCard,
            if (taskCards.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              SectionHeader(
                title: 'Opgaver',
                actionText: 'Se alle',
                onActionPressed: () {},
              ),
              ...taskCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: card,
              )),
            ],
            if (statCards.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Topstatistik'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: Spacing.sm,
                crossAxisSpacing: Spacing.sm,
                childAspectRatio: 1.5,
                children: statCards,
              ),
            ],
            if (previousMatchCard != null) ...[
              const SizedBox(height: Spacing.lg),
              const SectionHeader(title: 'Sidste kamp'),
              previousMatchCard!,
            ],
          ],
        ),
      ),
    );
  }
}
