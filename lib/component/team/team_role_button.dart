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
    final canRemove = canManageTeam && auth.state.user?.id != player.id;
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
          if (canRemove)
            CupertinoActionSheetAction(
              key: const ValueKey('team-remove-member'),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, _RoleChoice.remove),
              child: Text(l10n.teamRemoveMember),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.onboardingCancel),
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice == _RoleChoice.remove) {
      await _removeMember(context, members, teamId, player);
      return;
    }
    try {
      switch (choice) {
        case _RoleChoice.remove:
          return;
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

  Future<void> _removeMember(
    BuildContext context,
    TeamMembersCubit members,
    int teamId,
    UserDetails player,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.teamRemoveMember),
        content: Text(l10n.teamRemoveMemberConfirm(player.name)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.onboardingCancel),
          ),
          CupertinoDialogAction(
            key: const ValueKey('team-remove-member-confirm'),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.teamRemoveMemberAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = AppColors.of(context).error;
    try {
      await members.removeMember(teamId: teamId, userId: player.id);
      // The profile belongs to someone who is no longer on the team.
      navigator.maybePop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.teamRemoveMemberFailed),
        backgroundColor: errorColor,
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

enum _RoleChoice { leader, player, fineAdmin, remove }
