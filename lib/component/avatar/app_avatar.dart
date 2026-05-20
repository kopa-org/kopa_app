import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return CircleAvatar(
      radius: radius,
      backgroundColor: appColors.primary.withValues(alpha: 0.1),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials ?? '',
              style: appTextStyles.bodyBold.copyWith(
                color: appColors.primary,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
