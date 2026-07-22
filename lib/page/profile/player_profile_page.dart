import 'package:flutter/material.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/player_profile.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class PlayerProfilePage extends StatelessWidget {
  final UserDetails player;

  const PlayerProfilePage({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: player.name,
      showBackButton: true,
      body: FutureHandler<PlayerProfile>(
        future: UsersRepository.getPlayerProfile(player.id),
        onSuccess: (context, profile) => _PlayerProfileView(profile: profile),
      ),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  final PlayerProfile profile;

  const _PlayerProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SectionCard(
          title: 'Stamdata',
          child: Column(
            children: [
              _InfoRow(
                  label: 'Alder', value: profile.bio.age?.toString() ?? '-'),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Position',
                value: profile.bio.position ?? profile.player.position ?? '-',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Spillerens Player+',
          child: Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              _StatPill(
                label: 'Kampe',
                value: '${profile.playerPlusSummary.matchesPlayed}',
                color: appColors.sky,
              ),
              _StatPill(
                label: 'Mål',
                value: '${profile.playerPlusSummary.goalsScored}',
                color: appColors.success,
              ),
              _StatPill(
                label: 'Assists',
                value: '${profile.playerPlusSummary.assists}',
                color: appColors.sunset,
              ),
              _StatPill(
                label: 'Pointsnit',
                value: profile.playerPlusSummary.pointsAverage
                        ?.toStringAsFixed(1) ??
                    '-',
                color: appColors.primary,
              ),
              _StatPill(
                label: 'Stemmer',
                value: '${profile.playerPlusSummary.voteCount}',
                color: appColors.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Spillerens bødekasse',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skyldigt beløb: ${profile.fineOverview.owedAmount.toStringAsFixed(0)} kr.',
                style: styles.bodyBold,
              ),
              const SizedBox(height: 12),
              if (profile.fineOverview.fines.isEmpty)
                Text('Ingen bøder registreret.', style: styles.body)
              else
                ...profile.fineOverview.fines.map(
                  (fine) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            fine.fineTypeDetails.title,
                            style: styles.body,
                          ),
                        ),
                        Text(
                          '${fine.owedAmount} kr.',
                          style: styles.bodyBold.copyWith(
                            color: fine.hasBeenPaid
                                ? appColors.textSecondary
                                : appColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Kampprogram',
          child: Column(
            children: profile.matchHistory.isEmpty
                ? [Text('Ingen kampe fundet.', style: styles.body)]
                : profile.matchHistory.map((match) {
                    final tags = <String>[
                      match.participated ? 'Deltog' : 'Deltog ikke',
                      if (match.rating != null)
                        'Rating ${match.rating!.toStringAsFixed(1)}',
                      if (match.scored) 'Mål',
                      if (match.assisted) 'Assist',
                    ];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match.homeTeam} vs ${match.awayTeam}',
                            style: styles.bodyBold,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${match.date.day.toString().padLeft(2, '0')}-${match.date.month.toString().padLeft(2, '0')}-${match.date.year}',
                            style: styles.caption,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appColors.surface,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(tag, style: styles.caption),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: styles.sectionHeader),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: styles.body),
        Text(value, style: styles.bodyBold),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: styles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: styles.sectionHeader.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
