import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/team_members_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';

class TeamRoleButton extends StatelessWidget {
  final UserDetails player;
  const TeamRoleButton({super.key, required this.player});

  Future<void> _editRole(BuildContext context, UserDetails player) async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthCubit>();
    final members = context.read<TeamMembersCubit>();
    final teamId = auth.state.user?.teamDetails?.id;
    if (teamId == null) return;
    // Only leaders hand out the fine admin role; a leader editing themselves
    // may still step down to player.
    final canManageTeam = auth.state.user?.canManageTeam == true;
    final choice = await showCupertinoModalPopup<_RoleChoice>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(player.name),
        message: Text(l10n.teamRoleEdit),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, _RoleChoice.leader),
            child: Text(l10n.onboardingTeamLeader),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, _RoleChoice.player),
            child: Text(l10n.onboardingPlayer),
          ),
          if (canManageTeam)
            CupertinoActionSheetAction(
              key: const ValueKey('team-role-fine-admin'),
              isDestructiveAction: player.isFineAdmin,
              onPressed: () => Navigator.pop(context, _RoleChoice.fineAdmin),
              child: Text(player.isFineAdmin
                  ? l10n.teamRoleRemoveFineAdmin
                  : l10n.teamRoleMakeFineAdmin),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.onboardingCancel),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    try {
      switch (choice) {
        case _RoleChoice.fineAdmin:
          await members.changeFineAdmin(
              teamId: teamId,
              userId: player.id,
              isFineAdmin: !player.isFineAdmin);
        case _RoleChoice.leader || _RoleChoice.player:
          final isLeader = choice == _RoleChoice.leader;
          if (isLeader == player.isTeamOwner) return;
          await members.changeRole(
              teamId: teamId, userId: player.id, isTeamLeader: isLeader);
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error is LastTeamLeaderException
            ? l10n.teamRoleLastLeader
            : l10n.teamRoleSaveFailed),
        backgroundColor: AppColors.of(context).error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final state = context.watch<TeamMembersCubit>().state;
    // The page may hold a stale snapshot, so prefer the live member.
    final player = state.members.firstWhere(
      (member) => member.id == this.player.id,
      orElse: () => this.player,
    );
    if (!(user?.canManageTeam == true ||
        (user?.id == player.id && player.isTeamOwner))) {
      return const SizedBox.shrink();
    }
    if (state.savingUserId == player.id) {
      return const CupertinoActivityIndicator();
    }
    return IconButton(
      tooltip: AppLocalizations.of(context)!.teamRoleEdit,
      onPressed:
          state.savingUserId != null ? null : () => _editRole(context, player),
      icon: Icon(CupertinoIcons.pencil, color: AppColors.of(context).black),
    );
  }
}

enum _RoleChoice { leader, player, fineAdmin }
