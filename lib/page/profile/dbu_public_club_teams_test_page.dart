import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class DbuPublicClubTeamsTestPage extends StatefulWidget {
  const DbuPublicClubTeamsTestPage({super.key});

  @override
  State<DbuPublicClubTeamsTestPage> createState() =>
      _DbuPublicClubTeamsTestPageState();
}

class _DbuPublicClubTeamsTestPageState
    extends State<DbuPublicClubTeamsTestPage> {
  final _clubIdController = TextEditingController(text: '1581');
  final _teamLabelController =
      TextEditingController(text: 'Senior - 7M - Anders B.');
  final _leaderLabelController = TextEditingController(text: 'Anders B.');
  bool _isLoading = false;
  String? _errorMessage;
  DbuPublicClubTeamsResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _clubIdController.dispose();
    _teamLabelController.dispose();
    _leaderLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final result = _result;

    return PageScaffold(
      title: 'DBU holdtest',
      showBackButton: true,
      backgroundColor: appColors.background,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: appColors.background,
        systemNavigationBarColor: appColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Text(
            'Public DBU lookup',
            style: styles.h4.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isoleret test af spiller-flowets offentlige fallback.',
            style: styles.body3.copyWith(color: appColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _clubIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DBU club id',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teamLabelController,
            decoration: const InputDecoration(
              labelText: 'Spillerens holdlabel',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _leaderLabelController,
            decoration: const InputDecoration(
              labelText: 'Holdleder fra Mit DBU',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FullWidthButton(
            buttonText: _isLoading ? 'Henter DBU-hold...' : 'Hent DBU-hold',
            icon: Icons.search,
            onPressed: _isLoading ? () {} : _load,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: styles.body.copyWith(color: appColors.error),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 24),
            Text(
              '${result.teams.length} kandidater',
              style: styles.subtitle1.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.sourceUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.body3.copyWith(color: appColors.textSecondary),
            ),
            const SizedBox(height: 12),
            for (final team in result.teams) ...[
              _DbuCandidateTile(team: team),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _load() async {
    final clubId = int.tryParse(_clubIdController.text.trim());
    if (clubId == null) {
      setState(() => _errorMessage = 'Indtast et gyldigt DBU club id.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await TeamDbuRepository.getPublicClubTeams(
        clubId: clubId,
        teamLabel: _teamLabelController.text,
        leaderLabel: _leaderLabelController.text,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}

class _DbuCandidateTile extends StatelessWidget {
  final DbuPublicClubTeam team;

  const _DbuCandidateTile({required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.grey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  team.seriesName,
                  style: styles.subtitle2.copyWith(
                    color: appColors.dirt,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Score ${team.combinedScore}',
                style: styles.caption.copyWith(color: appColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (team.poolLabel.isNotEmpty) team.poolLabel,
              'team ${team.dbuTeamId}',
              'pool ${team.dbuPoolId}',
            ].join(' · '),
            style: styles.body3.copyWith(color: appColors.textSecondary),
          ),
          if (team.leaderNames.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Holdleder: ${team.leaderNames.join(', ')}',
              style: styles.body3.copyWith(color: appColors.dirt),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Række ${team.matchScore} · holdleder ${team.leaderMatchScore}',
            style: styles.caption.copyWith(color: appColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            team.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.caption.copyWith(color: appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
