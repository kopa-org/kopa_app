import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

/// The home hero right after the season's last result: invites the team into
/// its Season Wrapped (Himmel + Sol) before the season-over/import state.
class SeasonWrappedTeaser extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onSkip;

  const SeasonWrappedTeaser({
    super.key,
    required this.onOpen,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.seasonOverEyebrow,
            style: textStyles.caption2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.seasonOverTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyles.h2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.05,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Semantics(
            button: true,
            label: l10n.wrappedTeaserCta,
            child: Material(
              color: colors.sky,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shadowColor: colors.sky,
              child: InkWell(
                key: const ValueKey('season_wrapped_teaser'),
                onTap: onOpen,
                child: Stack(
                  children: [
                    Positioned(
                      right: -110,
                      top: -60,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.white.withValues(alpha: 0.22),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              for (var i = 0; i < 5; i++) ...[
                                if (i > 0) const SizedBox(width: 6),
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: i < 3
                                          ? colors.sun
                                          : colors.white
                                              .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.wrappedTeaserEyebrow.toUpperCase(),
                                      style: textStyles.caption3.copyWith(
                                        color: colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.sm),
                                    Text(
                                      l10n.wrappedTeaserTitle,
                                      style: textStyles.h3.copyWith(
                                        color: colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 28,
                                        height: 1.02,
                                      ),
                                    ),
                                    const SizedBox(height: Spacing.sm),
                                    Text(
                                      l10n.wrappedTeaserBody,
                                      style: textStyles.body3.copyWith(
                                        color: colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: Spacing.itemGap),
                              Transform.rotate(
                                angle: -0.14,
                                child: SvgPicture.asset(
                                  'assets/illustrations/kopa_flag.svg',
                                  height: 88,
                                  colorFilter: ColorFilter.mode(
                                    colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.sun,
                              borderRadius: BorderRadius.circular(
                                Spacing.borderRadiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: colors.dirt,
                                ),
                                const SizedBox(width: Spacing.sm),
                                Text(
                                  l10n.wrappedTeaserCta,
                                  style: textStyles.buttonSmall.copyWith(
                                    color: colors.dirt,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: colors.primary,
            ),
            child: Text(
              l10n.wrappedSkip,
              style: textStyles.body4.copyWith(
                color: WrappedPalette.deepGraes,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
