import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InFormPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Border? border;

  const InFormPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
              border: border,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class InFormEyebrow extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const InFormEyebrow({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? colors.lightGrass,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: styles.caption.copyWith(
          color: textColor ?? colors.dirt,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class InFormAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const InFormAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? colors.offWhite,
      child: Text(
        initialsFor(name),
        style: styles.bodyBold.copyWith(
          color: foregroundColor ?? colors.grass,
          fontSize: radius * .8,
        ),
      ),
    );
  }
}

class InFormMascot extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const InFormMascot({
    super.key,
    required this.asset,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return RepaintBoundary(
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color ?? colors.grass, BlendMode.srcIn),
      ),
    );
  }
}

class InFormMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const InFormMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Spacing.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colors.dirt),
            const SizedBox(height: Spacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.sectionHeader.copyWith(
                color: colors.dirt,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.caption.copyWith(color: colors.dirt),
            ),
          ],
        ),
      ),
    );
  }
}

class InFormPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final IconData? icon;

  const InFormPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final background =
        selected ? selectedColor ?? colors.grass : colors.surface;
    final foreground = selected ? Colors.white : colors.dirt;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: styles.caption.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InFormSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const InFormSectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: styles.sectionHeader.copyWith(
              color: colors.dirt,
              height: 1.05,
              letterSpacing: -.4,
            ),
          ),
        ),
        if (action != null)
          onAction == null
              ? Text(
                  action!,
                  style: styles.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : TextButton(
                  onPressed: onAction,
                  child: Text(action!),
                ),
      ],
    );
  }
}

String initialsFor(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
