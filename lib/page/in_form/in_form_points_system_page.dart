import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/repository/in_form_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Player-facing overview of how in-form points are earned, per position and
/// grouped into the five point categories. Values come from the backend's
/// scoring table so they always match the real calculation.
class InFormPointsSystemPage extends StatefulWidget {
  final String? initialPosition;

  const InFormPointsSystemPage({super.key, this.initialPosition});

  @override
  State<InFormPointsSystemPage> createState() => _InFormPointsSystemPageState();
}

class _InFormPointsSystemPageState extends State<InFormPointsSystemPage> {
  late final Future<InFormPointsSystem> _system =
      InFormRepository.getPointsSystem();
  late String _position = inFormPositions.contains(widget.initialPosition)
      ? widget.initialPosition!
      : inFormPositions.first;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.inFormPointsSystem,
      showBackButton: true,
      body: FutureBuilder<InFormPointsSystem>(
        future: _system,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: colors.grass),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  l10n.inFormPointsSystemLoadFailed,
                  textAlign: TextAlign.center,
                  style: styles.body,
                ),
              ),
            );
          }

          final rules = snapshot.data!.rulesByPosition[_position] ?? const [];
          final byCategory = <String, List<InFormPointRule>>{};
          for (final rule in rules) {
            byCategory.putIfAbsent(rule.category, () => []).add(rule);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.xxl,
            ),
            children: [
              Text(
                l10n.inFormPointsSystemIntro,
                style: styles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: Spacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final position in inFormPositions)
                      Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: InFormPill(
                          label: inFormPositionLabel(position),
                          selected: position == _position,
                          onTap: () => setState(() => _position = position),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              for (final category in inFormCategories)
                if (byCategory[category] case final items?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _CategoryPanel(category: category, rules: items),
                  ),
              InFormPanel(
                color: colors.lightSky,
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colors.dirt, size: 20),
                    const SizedBox(width: Spacing.itemGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inFormCategoryLabel('bonus'),
                            style: styles.bodyBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.inFormPointsSystemExtras,
                            style: styles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  final String category;
  final List<InFormPointRule> rules;

  const _CategoryPanel({required this.category, required this.rules});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(inFormCategoryLabel(category), style: styles.sectionHeader),
          const SizedBox(height: 2),
          Text(
            inFormCategoryDescription(category),
            style: styles.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(rule.label, style: styles.body)),
                  Text(
                    inFormSigned(rule.value),
                    style: styles.bodyBold.copyWith(
                      color: rule.value < 0 ? colors.error : colors.grass,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
