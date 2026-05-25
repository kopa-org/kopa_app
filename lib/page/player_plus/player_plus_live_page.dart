import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/player_plus_cubit.dart';
import 'package:kopa/cubits/player_plus_state.dart';
import 'package:kopa/model/player_plus.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';

class PlayerPlusLivePage extends StatelessWidget {
  const PlayerPlusLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().state.user;

    return BlocProvider(
      create: (_) => PlayerPlusCubit()..load(currentUser),
      child: const _PlayerPlusLiveView(),
    );
  }
}

class _PlayerPlusLiveView extends StatefulWidget {
  const _PlayerPlusLiveView();

  @override
  State<_PlayerPlusLiveView> createState() => _PlayerPlusLiveViewState();
}

class _PlayerPlusLiveViewState extends State<_PlayerPlusLiveView> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.logEvent('player_plus_live_opened');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Player+ Live',
      showBackButton: true,
      body: BlocBuilder<PlayerPlusCubit, PlayerPlusState>(
        builder: (context, state) {
          if (state.status == PlayerPlusStatus.loading &&
              state.overview == null &&
              state.leaderboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PlayerPlusStatus.noTeam) {
            return _StatusState(
              title: 'Ingen hold valgt',
              body:
                  'Player+ kræver, at du er tilknyttet et hold. Join eller opret et hold for at se ranglisterne.',
              actionText: null,
              onPressed: null,
            );
          }

          if (state.status == PlayerPlusStatus.error &&
              state.overview == null &&
              state.leaderboard == null) {
            return _StatusState(
              title: 'Kunne ikke hente Player+',
              body: state.errorMessage ?? 'Prøv igen om et øjeblik.',
              actionText: 'Prøv igen',
              onPressed: () => context.read<PlayerPlusCubit>().retry(),
            );
          }

          final overview = state.overview;
          final leaderboard = state.leaderboard;
          if (overview == null || leaderboard == null) {
            return const SizedBox.shrink();
          }

          final currentUserRow = _findCurrentUserRow(
            leaderboard.rows,
            state.currentUserId,
          );

          return RefreshIndicator(
            onRefresh: () => context.read<PlayerPlusCubit>().load(
                  context.read<AuthCubit>().state.user,
                ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _HeroCard(
                  teamTitle: state.teamTitle ?? 'Dit hold',
                  selectedCategory: state.selectedCategory ?? 'overall',
                  selectedScope: state.selectedScope ?? 'team',
                  locked: overview.locked,
                ),
                const SizedBox(height: 20),
                _FilterSection(
                  title: 'Scope',
                  options: overview.scopes,
                  selectedValue: state.selectedScope,
                  onSelected: (scope) =>
                      context.read<PlayerPlusCubit>().selectScope(scope),
                ),
                const SizedBox(height: 16),
                _FilterSection(
                  title: 'Konkurrencer',
                  options: _displayCategories(overview.categories),
                  selectedValue: state.selectedCategory,
                  onSelected: (category) =>
                      context.read<PlayerPlusCubit>().selectCategory(category),
                ),
                const SizedBox(height: 20),
                _SummaryRow(
                  currentUserRow: currentUserRow,
                  totalRows: leaderboard.rows.length,
                  category: state.selectedCategory ?? 'overall',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _sectionTitleFor(state.selectedCategory ?? 'overall'),
                        style: appTextStyles.sectionHeader
                            .copyWith(color: appColors.primary),
                      ),
                    ),
                    if (state.status == PlayerPlusStatus.loading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: appColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.status == PlayerPlusStatus.error)
                  _StatusInlineCard(
                    title: 'Kunne ikke opdatere ranglisten',
                    body: state.errorMessage ?? 'Prøv igen.',
                    actionText: 'Prøv igen',
                    onPressed: () => context.read<PlayerPlusCubit>().retry(),
                  )
                else if (state.status == PlayerPlusStatus.empty)
                  _StatusInlineCard(
                    title: 'Ingen data endnu',
                    body: _emptyStateCopy(state.selectedCategory ?? 'overall'),
                    actionText: null,
                    onPressed: null,
                  )
                else
                  ...leaderboard.rows.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LeaderboardRowCard(
                        row: row,
                        isCurrentUser: row.userId == state.currentUserId,
                        showTeamTitle:
                            (state.selectedScope ?? 'team') == 'global',
                        category: state.selectedCategory ?? 'overall',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.teamTitle,
    required this.selectedCategory,
    required this.selectedScope,
    required this.locked,
  });

  final String teamTitle;
  final String selectedCategory;
  final String selectedScope;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.grass, appColors.lightGrass],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Live ranglister',
              style: appTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            teamTitle,
            style: appTextStyles.pageTitle.copyWith(
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_labelForCategory(selectedCategory)} · ${_labelForScope(selectedScope)}',
            style: appTextStyles.bodyBold.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locked
                ? 'Player+ er stadig låst for dit hold.'
                : 'Her er de rigtige Player+ placeringer baseret på jeres kampdata.',
            style: appTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appTextStyles.caption.copyWith(
            color: appColors.dirt,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = option == selectedValue;
            return ChoiceChip(
              label: Text(_labelForOption(title, option)),
              selected: selected,
              onSelected: (_) => onSelected(option),
              selectedColor: appColors.grass.withValues(alpha: 0.16),
              backgroundColor: appColors.surface,
              labelStyle: appTextStyles.caption.copyWith(
                color: selected ? appColors.primary : appColors.dirt,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: selected
                    ? appColors.grass
                    : appColors.divider.withValues(alpha: 0.6),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.currentUserRow,
    required this.totalRows,
    required this.category,
  });

  final PlayerPlusLeaderboardRow? currentUserRow;
  final int totalRows;
  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Din placering',
            value: currentUserRow == null
                ? 'Ikke på listen'
                : '#${currentUserRow!.rank}',
            color: appColors.sunset,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: _metricLabel(category),
            value: currentUserRow == null
                ? '-'
                : _formatValue(currentUserRow!.value, category),
            color: appColors.sky,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Deltagere',
            value: '$totalRows',
            color: appColors.grass,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appTextStyles.caption.copyWith(color: appColors.dirt),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: appTextStyles.bodyBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRowCard extends StatelessWidget {
  const _LeaderboardRowCard({
    required this.row,
    required this.isCurrentUser,
    required this.showTeamTitle,
    required this.category,
  });

  final PlayerPlusLeaderboardRow row;
  final bool isCurrentUser;
  final bool showTeamTitle;
  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? appColors.lightGrass : appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser
              ? appColors.grass
              : appColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: appColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${row.rank}',
              style: appTextStyles.bodyBold.copyWith(color: appColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? '${row.userName} (dig)' : row.userName,
                  style: appTextStyles.bodyBold,
                ),
                const SizedBox(height: 4),
                Text(
                  showTeamTitle ? row.teamTitle : _metricLabel(category),
                  style: appTextStyles.caption.copyWith(color: appColors.dirt),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatValue(row.value, category),
                style:
                    appTextStyles.bodyBold.copyWith(color: appColors.primary),
              ),
              if (showTeamTitle && row.seriesName != null) ...[
                const SizedBox(height: 4),
                Text(
                  row.seriesName!,
                  style: appTextStyles.caption.copyWith(color: appColors.dirt),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusState extends StatelessWidget {
  const _StatusState({
    required this.title,
    required this.body,
    required this.actionText,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String? actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: appTextStyles.pageTitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              body,
              style: appTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onPressed != null) ...[
              const SizedBox(height: 20),
              FullWidthButton(
                buttonText: actionText!,
                onPressed: onPressed!,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusInlineCard extends StatelessWidget {
  const _StatusInlineCard({
    required this.title,
    required this.body,
    required this.actionText,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String? actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appTextStyles.bodyBold),
          const SizedBox(height: 8),
          Text(body, style: appTextStyles.body.copyWith(color: appColors.dirt)),
          if (actionText != null && onPressed != null) ...[
            const SizedBox(height: 16),
            FullWidthButton(
              buttonText: actionText!,
              onPressed: onPressed!,
              outlined: true,
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

List<String> _displayCategories(List<String> categories) {
  const priority = [
    'overall',
    'mvp_wins',
    'goals',
    'assists',
    'cards_total',
    'fines_total',
  ];

  final prioritized = [
    ...priority.where(categories.contains),
    ...categories.where((category) => !priority.contains(category)),
  ];

  return prioritized;
}

String _sectionTitleFor(String category) =>
    '${_labelForCategory(category)} rangliste';

String _labelForOption(String title, String option) {
  if (title == 'Scope') {
    return _labelForScope(option);
  }

  return _labelForCategory(option);
}

String _labelForScope(String scope) {
  return switch (scope) {
    'team' => 'Hold',
    'global' => 'Alle hold',
    _ => scope,
  };
}

String _labelForCategory(String category) {
  return switch (category) {
    'overall' => 'Overall',
    'mvp_wins' => 'Kampens spiller',
    'goals' => 'Mål',
    'assists' => 'Assists',
    'cards_total' => 'Kort',
    'fines_total' => 'Bøder',
    'matches_played' => 'Kampe spillet',
    'training_attendance' => 'Træningsfremmøde',
    'average_rating' => 'Spillerrating',
    _ => category,
  };
}

String _metricLabel(String category) {
  return switch (category) {
    'training_attendance' => 'Fremmøde',
    'average_rating' => 'Rating',
    'fines_total' => 'Skyldig',
    _ => _labelForCategory(category),
  };
}

String _formatValue(num value, String category) {
  if (category == 'training_attendance') {
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%';
  }

  if (category == 'average_rating' || value % 1 != 0) {
    return value.toStringAsFixed(1);
  }

  return value.toInt().toString();
}

String _emptyStateCopy(String category) {
  return switch (category) {
    'average_rating' =>
      'Der er ikke nok spillerbedømmelser endnu til at vise en stabil rangliste.',
    'training_attendance' =>
      'Der skal registreres flere træninger, før fremmøderanglisten giver mening.',
    'fines_total' => 'Der er ingen ubetalte bøder registreret lige nu.',
    'mvp_wins' =>
      'Ingen har endnu fået kampens spiller registreret i denne periode.',
    _ => 'Der er endnu ikke nok data til at vise denne konkurrence.',
  };
}

PlayerPlusLeaderboardRow? _findCurrentUserRow(
  List<PlayerPlusLeaderboardRow> rows,
  int? currentUserId,
) {
  if (currentUserId == null) {
    return null;
  }

  for (final row in rows) {
    if (row.userId == currentUserId) {
      return row;
    }
  }

  return null;
}
