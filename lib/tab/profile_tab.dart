import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/profile/player_profile_page.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<List<UserDetails>> _squadFuture;

  @override
  void initState() {
    super.initState();
    _squadFuture = UsersRepository.getSquad();
  }

  Future<void> _refresh() async {
    setState(() {
      _squadFuture = UsersRepository.getSquad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return PageScaffold.tab(
      title: 'Truppen',
      backgroundColor: appColors.background,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: appColors.background,
        systemNavigationBarColor: appColors.surface,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureHandler<List<UserDetails>>(
          future: _squadFuture,
          noDataFoundMessage: 'Ingen spillere fundet.',
          onSuccess: (context, squad) => _SquadRosterView(squad: squad),
        ),
      ),
    );
  }
}

class _SquadRosterView extends StatelessWidget {
  final List<UserDetails> squad;

  const _SquadRosterView({required this.squad});

  @override
  Widget build(BuildContext context) {
    final sortedSquad = sortSquadByPlayerRole(squad);
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        120,
      ),
      children: [
        Text(
          'Truppen',
          style: styles.h4.copyWith(
            color: appColors.dirt,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${squad.length} spillere i truppen',
          style: styles.body3.copyWith(color: appColors.textSecondary),
        ),
        const SizedBox(height: 20),
        FullWidthButton(
          buttonText: 'Test DBU holdopslag',
          icon: Icons.search,
          outlined: true,
          onPressed: () => context.push(AppRouter.dbuPublicClubTeamsTest),
        ),
        const SizedBox(height: 20),
        _RosterCard(squad: sortedSquad),
      ],
    );
  }
}

@visibleForTesting
List<UserDetails> sortSquadByPlayerRole(List<UserDetails> squad) {
  final indexedSquad = squad.indexed.toList();
  indexedSquad.sort((a, b) {
    final roleComparison = _squadRoleSortIndex(a.$2.position)
        .compareTo(_squadRoleSortIndex(b.$2.position));
    if (roleComparison != 0) return roleComparison;

    return a.$1.compareTo(b.$1);
  });

  return indexedSquad.map((entry) => entry.$2).toList();
}

int _squadRoleSortIndex(String? position) {
  final value = position?.toLowerCase().trim() ?? '';
  if (value.isEmpty) return 4;

  if (value.contains('goalkeeper') ||
      value.contains('keeper') ||
      value.contains('målmand') ||
      value.contains('maalmand') ||
      value.contains('malmand')) {
    return 0;
  }

  if (value.contains('centre_back') ||
      value.contains('center_back') ||
      value.contains('back_wingback') ||
      value.contains('midterforsvar') ||
      value.contains('stopper') ||
      value.contains('forsvar') ||
      value.contains('defender') ||
      value.contains('defence') ||
      value.contains('defense') ||
      value.contains('back')) {
    return 1;
  }

  if (value.contains('defensive_midfield') ||
      value.contains('midfield') ||
      value.contains('midtbane') ||
      value.contains('midt') ||
      value.contains('cm') ||
      value.contains('dm') ||
      value.contains('om')) {
    return 2;
  }

  if (value.contains('wing') ||
      value.contains('striker') ||
      value.contains('angreb') ||
      value.contains('angriber') ||
      value.contains('attack') ||
      value.contains('forward')) {
    return 3;
  }

  return 4;
}

class _RosterCard extends StatelessWidget {
  final List<UserDetails> squad;

  const _RosterCard({required this.squad});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _SquadColors.border),
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < squad.length; index++)
            _RosterRow(
              player: squad[index],
              showDivider: index < squad.length - 1,
            ),
        ],
      ),
    );
  }
}

class _RosterRow extends StatelessWidget {
  final UserDetails player;
  final bool showDivider;

  const _RosterRow({
    required this.player,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final position = _positionLabel(player);

    return Material(
      color: appColors.surface,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerProfilePage(player: player),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(color: _SquadColors.border),
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: Spacing.md,
          ),
          child: Row(
            children: [
              _RosterAvatar(player: player),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.subtitle2.copyWith(
                        color: appColors.dirt,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body3.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: appColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _positionLabel(UserDetails player) {
    final position = player.position?.trim();
    if (position != null && position.isNotEmpty) {
      return position;
    }

    return player.isTeamOwner ? 'Holdleder' : 'Spiller';
  }
}

class _RosterAvatar extends StatelessWidget {
  final UserDetails player;

  const _RosterAvatar({required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appColors.lightGrass65,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(player.name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: styles.body3.copyWith(
          color: appColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }
}

abstract final class _SquadColors {
  static const border = Color(0xFFDCE5E2);
}
