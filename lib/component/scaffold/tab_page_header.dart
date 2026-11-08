import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Title block at the top of a main tab (match schedule, statistics, squad).
///
/// Place it inside the screen's 16 px gutter; it adds the extra 4 px inset
/// so the title lines up with the text inside the cards below it.
class TabPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Optional control under the title, such as the season selector.
  final Widget? bottom;

  const TabPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final subtitle = this.subtitle;
    final bottom = this.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: styles.pageTitle.copyWith(color: colors.dirt),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              subtitle,
              style: styles.body3.copyWith(color: colors.textSecondary),
            ),
          ],
          if (bottom != null) ...[
            const SizedBox(height: 10),
            bottom,
          ],
        ],
      ),
    );
  }
}
