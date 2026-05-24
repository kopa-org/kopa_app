import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class PlayerPlusTeaserSection extends StatelessWidget {
  const PlayerPlusTeaserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: appColors.grass,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Player+',
                  style: appTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sæsonens interne liga',
                  style: appTextStyles.sectionHeader.copyWith(
                    color: appColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HeroTeaserCard(
            onTap: () => context.push(AppRouter.playerPlus),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniTeaserCard(
                  title: 'Top 5',
                  value: '#?',
                  label: 'Din overall placering',
                  color: appColors.sunset,
                  onTap: () => context.push(AppRouter.playerPlus),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniTeaserCard(
                  title: 'Form',
                  value: '??%',
                  label: 'MVP, kort og bøder',
                  color: appColors.sky,
                  onTap: () => context.push(AppRouter.playerPlus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTeaserCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HeroTeaserCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: appColors.lightGrass,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: appColors.grass, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: appColors.grass),
                  const SizedBox(width: 8),
                  Text(
                    'Sæsonduellen',
                    style: appTextStyles.bodyBold.copyWith(
                      color: appColors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward, color: appColors.grass),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Column(
                      children: const [
                        _BlurredRankRow(
                            rank: '1', name: 'Mathias', stat: '84 point'),
                        _BlurredRankRow(
                            rank: '2', name: 'Jonas', stat: '79 point'),
                        _BlurredRankRow(
                            rank: '3', name: 'Dig?', stat: '? point'),
                      ],
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.18),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.black,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Se konkurrencerne',
                              style: appTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Overall, kampens spiller, mål, assists, kort og bøder i én intern sæsonkamp.',
                style: appTextStyles.caption.copyWith(
                  color: appColors.dirt,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurredRankRow extends StatelessWidget {
  final String rank;
  final String name;
  final String stat;

  const _BlurredRankRow({
    required this.rank,
    required this.name,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: appColors.surface,
      child: Row(
        children: [
          Text(rank, style: appTextStyles.bodyBold),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: appTextStyles.body)),
          Text(stat, style: appTextStyles.bodyBold),
        ],
      ),
    );
  }
}

class _MiniTeaserCard extends StatelessWidget {
  final String title;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniTeaserCard({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: appTextStyles.caption.copyWith(color: appColors.dirt),
              ),
              const SizedBox(height: 8),
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Text(
                  value,
                  style: appTextStyles.pageTitle.copyWith(color: color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: appTextStyles.caption.copyWith(height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
