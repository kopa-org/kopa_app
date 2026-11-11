import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// Colour family for a settings row icon. Each settings category gets one so
/// admins can scan the list by colour as well as by label.
enum SettingsTone { matches, season, team, fines, neutral }

class SettingsToneColors {
  final Color background;
  final Color foreground;

  const SettingsToneColors(this.background, this.foreground);

  static SettingsToneColors of(BuildContext context, SettingsTone tone) {
    final colors = AppColors.of(context);
    Color tint(Color color) =>
        Color.alphaBlend(color.withValues(alpha: .14), colors.surface);
    return switch (tone) {
      SettingsTone.matches => SettingsToneColors(tint(colors.sky), colors.sky),
      SettingsTone.season =>
        SettingsToneColors(tint(colors.sunset), colors.textPrimary),
      SettingsTone.team =>
        SettingsToneColors(tint(colors.primary), colors.primary),
      SettingsTone.fines =>
        SettingsToneColors(tint(colors.textPrimary), colors.textPrimary),
      SettingsTone.neutral =>
        SettingsToneColors(colors.background, colors.textSecondary),
    };
  }
}

/// A titled group of [SettingsRow]s rendered as one rounded card.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionLabel(title),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Spacing.borderRadius),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 66,
                    color: colors.offWhite,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  final String text;

  const SettingsSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.xs, 0, Spacing.xs, Spacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: styles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
      ),
    );
  }
}

class SettingsIconTile extends StatelessWidget {
  final IconData icon;
  final SettingsTone tone;
  final double size;

  const SettingsIconTile({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final toneColors = SettingsToneColors.of(context, tone);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: toneColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * .56, color: toneColors.foreground),
    );
  }
}

/// One tappable settings row: icon, title, current value and a chevron.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final SettingsTone tone;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool loading;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.trailing,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: 10,
            ),
            child: Row(
              children: [
                SettingsIconTile(icon: icon, tone: tone),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: styles.subtitle2.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: styles.body3.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Spacing.sm),
                  trailing!,
                ],
                const SizedBox(width: Spacing.sm),
                if (loading)
                  const CupertinoActivityIndicator()
                else
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 18,
                    color: colors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small orange count pill used for things that need the admin's attention.
class SettingsCountBadge extends StatelessWidget {
  final int count;

  const SettingsCountBadge(this.count, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.sunset,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        '$count',
        style: styles.caption.copyWith(
          color: colors.dirt,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Inline save status shown at the bottom of auto-saving settings pages.
class SettingsSaveStatusLine extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final bool busy;

  const SettingsSaveStatusLine({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return Semantics(
      liveRegion: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy)
            const CupertinoActivityIndicator(radius: 7)
          else if (icon != null)
            Icon(icon, size: 16, color: color),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: styles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
