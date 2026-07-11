import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class PlayerPlusAccess {
  static final ValueNotifier<bool> temporaryUnlocked = ValueNotifier(false);
}

class PlayerPlusStatRankingRow {
  final int userId;
  final String userName;
  final String value;
  final String? suffix;

  const PlayerPlusStatRankingRow({
    required this.userId,
    required this.userName,
    required this.value,
    this.suffix,
  });
}

class PlayerPlusStatTileData {
  final String title;
  final String value;
  final int? rank;
  final List<PlayerPlusStatRankingRow> rows;
  final IconData icon;
  final Color accentColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const PlayerPlusStatTileData({
    required this.title,
    required this.value,
    required this.rank,
    this.rows = const [],
    required this.icon,
    required this.accentColor,
    this.backgroundColor,
    this.borderColor,
  });

  String get rankLabel => rank == null ? 'Ingen placering' : '#$rank på holdet';
}

class PlayerPlusStatTile extends StatelessWidget {
  final PlayerPlusStatTileData data;
  final VoidCallback? onTap;
  final bool obscureValue;
  final bool obscureRank;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double valueFontSize;
  final double? titleFontSize;
  final double? rankFontSize;
  final double valueRankGap;
  final bool showShadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final int? currentUserId;
  final bool locked;
  final Future<void> Function()? onBuyPlayerPlus;

  const PlayerPlusStatTile({
    super.key,
    required this.data,
    this.onTap,
    this.obscureValue = false,
    this.obscureRank = false,
    this.width,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 8,
    this.iconSize = 20,
    this.valueFontSize = 34,
    this.titleFontSize,
    this.rankFontSize,
    this.valueRankGap = 8,
    this.showShadow = false,
    this.backgroundColor,
    this.borderColor,
    this.currentUserId,
    this.locked = false,
    this.onBuyPlayerPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final currentIndex = currentUserId == null
        ? -1
        : data.rows.indexWhere((row) => row.userId == currentUserId);
    final computedRank =
        data.rank ?? (currentIndex == -1 ? null : currentIndex + 1);
    final displayData = PlayerPlusStatTileData(
      title: data.title,
      value: data.value,
      rank: computedRank,
      rows: data.rows,
      icon: data.icon,
      accentColor: data.accentColor,
      backgroundColor: data.backgroundColor,
      borderColor: data.borderColor,
    );
    final effectiveBackgroundColor = backgroundColor ??
        displayData.backgroundColor ??
        appColors.lightGrass55;
    final effectiveBorderColor =
        borderColor ?? displayData.borderColor ?? appColors.grass;

    final content = Material(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap ?? () => _handleTap(context, displayData),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: effectiveBorderColor),
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: appColors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    displayData.icon,
                    color: displayData.accentColor,
                    size: iconSize,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayData.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.bodyBold.copyWith(fontSize: titleFontSize),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              BlurredValue(
                blurred: obscureValue,
                child: Text(
                  displayData.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.pageTitle.copyWith(
                    color: appColors.textPrimary,
                    fontSize: valueFontSize,
                  ),
                ),
              ),
              SizedBox(height: valueRankGap),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: displayData.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: BlurredValue(
                  blurred: obscureRank,
                  sigma: 3,
                  child: Text(
                    displayData.rankLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.caption.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: rankFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }

  void _handleTap(BuildContext context, PlayerPlusStatTileData displayData) {
    if (locked) {
      _showPlayerPlusRequiredDialog(context);
      return;
    }
    _showLeaderboardSheet(context, displayData);
  }

  void _showPlayerPlusRequiredDialog(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: appColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Player+ påkrævet',
                style: styles.sectionHeader.copyWith(
                  color: appColors.primary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Ranglisten kan ikke vises, fordi spilleren ikke har Player+.',
          style: styles.body.copyWith(color: appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Luk'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              PlayerPlusAccess.temporaryUnlocked.value = true;
              await onBuyPlayerPlus?.call();
            },
            child: const Text('Køb Player+'),
          ),
        ],
      ),
    );
  }

  void _showLeaderboardSheet(
    BuildContext context,
    PlayerPlusStatTileData displayData,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlayerPlusLeaderboardSheet(
        data: displayData,
        currentUserId: currentUserId,
        locked: locked,
      ),
    );
  }
}

class _PlayerPlusLeaderboardSheet extends StatelessWidget {
  final PlayerPlusStatTileData data;
  final int? currentUserId;
  final bool locked;

  const _PlayerPlusLeaderboardSheet({
    required this.data,
    required this.currentUserId,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: appColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: appColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Icon(data.icon, color: data.accentColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.title,
                        style: styles.sectionHeader.copyWith(
                          color: appColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: data.rows.isEmpty
                    ? Center(
                        child: Text('Ingen data endnu.', style: styles.body))
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: data.rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final row = data.rows[index];
                          return _PlayerPlusLeaderboardSheetRow(
                            rank: index + 1,
                            row: row,
                            isCurrentUser: row.userId == currentUserId,
                            accentColor: data.accentColor,
                            locked: locked,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerPlusLeaderboardSheetRow extends StatelessWidget {
  final int rank;
  final PlayerPlusStatRankingRow row;
  final bool isCurrentUser;
  final Color accentColor;
  final bool locked;

  const _PlayerPlusLeaderboardSheetRow({
    required this.rank,
    required this.row,
    required this.isCurrentUser,
    required this.accentColor,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? accentColor.withValues(alpha: 0.14)
            : appColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: appColors.grass, width: 1.4)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: BlurredValue(
              blurred: locked,
              sigma: 3,
              child: Text(
                '$rank.',
                style: styles.bodyBold.copyWith(
                  color: isCurrentUser ? accentColor : appColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlurredValue(
              blurred: locked,
              sigma: 4,
              child: Text(
                row.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.bodyBold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BlurredValue(
            blurred: locked,
            sigma: 4,
            child: Text(
              row.suffix == null ? row.value : '${row.value} ${row.suffix}',
              style: styles.bodyBold.copyWith(
                color: isCurrentUser ? accentColor : appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlurredValue extends StatelessWidget {
  final bool blurred;
  final double sigma;
  final Widget child;

  const BlurredValue({
    required this.blurred,
    required this.child,
    this.sigma = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (!blurred) return child;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Opacity(
        opacity: 0.72,
        child: child,
      ),
    );
  }
}
