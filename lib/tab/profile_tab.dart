import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/team/team_role_button.dart';
import 'package:kopa/cubits/team_members_cubit.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/profile/player_profile_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class ProfileTab extends StatelessWidget {
  final TeamMembersCubit Function()? createMembersCubit;
  const ProfileTab({super.key, this.createMembersCubit});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            (createMembersCubit?.call() ?? TeamMembersCubit())..load(),
        child: const _SquadTabView(),
      );
}

class _SquadTabView extends StatelessWidget {
  const _SquadTabView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return PageScaffold.tab(
      title: l10n.teamSquadTitle,
      backgroundColor: colors.background,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: colors.background,
        systemNavigationBarColor: colors.surface,
      ),
      body: BlocConsumer<TeamMembersCubit, TeamMembersState>(
          listener: (context, state) {
        if (state.loading || state.loadFailed || state.savingUserId != null) {
          return;
        }
        final auth = context.read<AuthCubit>();
        final current = auth.state.user;
        if (current == null) return;
        for (final member in state.members) {
          if (member.id == current.id &&
              member.isTeamOwner != current.isTeamOwner) {
            auth.updateUser(current.withTeamRole(member.isTeamOwner));
            break;
          }
        }
      }, builder: (context, state) {
        final cubit = context.read<TeamMembersCubit>();
        return RefreshIndicator(
          onRefresh: () async {
            if (state.savingUserId == null) await cubit.load();
          },
          child: state.loading
              ? const Center(child: CupertinoActivityIndicator())
              : state.loadFailed
                  ? ListView(children: [
                      TextButton(
                          onPressed: cubit.load,
                          child: Text(l10n.teamSquadLoadFailed)),
                    ])
                  : state.members.isEmpty
                      ? ListView(children: [
                          Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(l10n.teamSquadEmpty)),
                        ])
                      : _SquadRosterView(squad: state.members),
        );
      }),
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
    final bottomContentPadding = mainTabBottomContentPadding(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.md + bottomContentPadding,
      ),
      children: [
        Text(
          AppLocalizations.of(context)!.teamSquadTitle,
          style: styles.h4.copyWith(
            color: appColors.dirt,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.teamSquadCount(squad.length),
          style: styles.body3.copyWith(color: appColors.textSecondary),
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
        borderRadius: BorderRadius.circular(16),
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
    final l10n = AppLocalizations.of(context)!;
    final role =
        player.isTeamOwner ? l10n.onboardingTeamLeader : l10n.onboardingPlayer;
    final position = player.position?.trim();

    return Material(
      color: appColors.surface,
      child: InkWell(
        key: ValueKey('team-member-${player.id}'),
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
                    bottom: BorderSide(color: appColors.offWhite),
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
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
                      position == null || position.isEmpty
                          ? role
                          : '$position · $role',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body3.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TeamRoleButton(player: player),
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
