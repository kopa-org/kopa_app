import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';

class PlayerPlusPage extends StatefulWidget {
  const PlayerPlusPage({super.key});

  @override
  State<PlayerPlusPage> createState() => _PlayerPlusPageState();
}

class _PlayerPlusPageState extends State<PlayerPlusPage> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.logEvent('player_plus_opened');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Player+',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: appColors.lightGrass,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: appColors.grass, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appColors.grass,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Kopa Player+',
                    style: appTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Sæsonens interne konkurrence starter her.',
                  style: appTextStyles.pageTitle
                      .copyWith(color: appColors.black, height: 1.05),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hvem bliver holdets bedste spiller, hvem tager flest kampens spiller, og hvem ender øverst i de sjove lister? Betaling er ikke slået til endnu, så siden fungerer som første kig på Player+ universet.',
                  style: appTextStyles.body
                      .copyWith(color: appColors.dirt, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sæsondueller',
            style:
                appTextStyles.sectionHeader.copyWith(color: appColors.primary),
          ),
          const SizedBox(height: 12),
          _CompetitionGrid(
            competitions: [
              _CompetitionPreview(
                icon: Icons.workspace_premium,
                title: 'Bedste spiller',
                metric: 'Overall',
                color: appColors.grass,
              ),
              _CompetitionPreview(
                icon: Icons.star,
                title: 'Kampens spiller',
                metric: 'MVP',
                color: appColors.sunset,
              ),
              _CompetitionPreview(
                icon: Icons.sports_score,
                title: 'Flest mål',
                metric: 'Mål',
                color: appColors.success,
              ),
              _CompetitionPreview(
                icon: Icons.handshake,
                title: 'Flest assists',
                metric: 'Assists',
                color: appColors.sky,
              ),
              _CompetitionPreview(
                icon: Icons.style,
                title: 'Flest kort',
                metric: 'Kort',
                color: appColors.warning,
              ),
              _CompetitionPreview(
                icon: Icons.payments,
                title: 'Bødekongen',
                metric: 'Bøder',
                color: appColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FeaturePreviewCard(
            icon: Icons.emoji_events,
            title: 'Interne ranglister',
            body:
                'Sæsonkonkurrencer for overall, MVP, mål, assists, kort og bøder på tværs af holdet.',
            color: appColors.sunset,
          ),
          _FeaturePreviewCard(
            icon: Icons.groups,
            title: 'Serie-sammenligning',
            body:
                'Sammenlign spillere mod andre hold i samme række, når DBU data er synkroniseret.',
            color: appColors.sky,
          ),
          _FeaturePreviewCard(
            icon: Icons.auto_graph,
            title: 'Skjulte mønstre',
            body:
                'Formkurver, streaks og små interne konkurrencer baseret på jeres egne kampdata.',
            color: appColors.grass,
          ),
        ],
      ),
    );
  }
}

class _CompetitionPreview {
  final IconData icon;
  final String title;
  final String metric;
  final Color color;

  const _CompetitionPreview({
    required this.icon,
    required this.title,
    required this.metric,
    required this.color,
  });
}

class _CompetitionGrid extends StatelessWidget {
  final List<_CompetitionPreview> competitions;

  const _CompetitionGrid({required this.competitions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: competitions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        return _CompetitionCard(competition: competitions[index]);
      },
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final _CompetitionPreview competition;

  const _CompetitionCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: competition.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: competition.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(competition.icon, color: competition.color, size: 19),
              ),
              const Spacer(),
              Text(
                '#?',
                style:
                    appTextStyles.bodyBold.copyWith(color: competition.color),
              ),
            ],
          ),
          const Spacer(),
          Text(
            competition.title,
            style: appTextStyles.bodyBold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            competition.metric,
            style: appTextStyles.caption.copyWith(color: appColors.dirt),
          ),
        ],
      ),
    );
  }
}

class _FeaturePreviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _FeaturePreviewCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: appTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: appTextStyles.caption.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
