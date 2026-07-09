import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final BoxFit imageFit;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24.0,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final fallback = Text(
      initials ?? '',
      style: appTextStyles.bodyBold.copyWith(
        color: appColors.grass,
        fontSize: radius * 0.8,
      ),
    );
    final normalizedImageUrl = imageUrl?.trim();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: normalizedImageUrl == null || normalizedImageUrl.isEmpty
          ? fallback
          : ClipOval(
              child: Image.network(
                normalizedImageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: imageFit,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: fallback,
                ),
              ),
            ),
    );
  }
}
