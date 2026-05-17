import 'package:flutter/material.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PlayerListItem extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final String? initials;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PlayerListItem({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.initials,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: imageUrl,
              initials: initials ?? _getInitials(name),
              radius: 20,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: appTextStyles.bodyBold,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: appTextStyles.caption,
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
