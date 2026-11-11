import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

/// Player avatar: a photo when there is one, otherwise the player's initials
/// in white on pitch green ("Banegrøn"). Use this for every player avatar so
/// the look stays the same across the app.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final BoxFit imageFit;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24.0,
    this.imageFit = BoxFit.cover,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Avatar for a player's full name, e.g. "Jonas Holm" -> "JH".
  AppAvatar.forName(
    String name, {
    Key? key,
    String? imageUrl,
    double radius = 24.0,
  }) : this(
          key: key,
          imageUrl: imageUrl,
          initials: initialsOf(name),
          radius: radius,
        );

  /// First letter of the first and last name ("?" when empty).
  static String initialsOf(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final fallback = Text(
      initials ?? '',
      maxLines: 1,
      style: styles.bodyBold.copyWith(
        color: foregroundColor ?? colors.white,
        fontSize: radius * 0.72,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
    final normalizedImageUrl = imageUrl?.trim();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? colors.pitch,
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
