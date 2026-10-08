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
    final role = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(player.name),
        message: Text(l10n.teamRoleEdit),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.onboardingTeamLeader),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.onboardingPlayer),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.onboardingCancel),
        ),
      ),
    );
    if (role == null || role == player.isTeamOwner || !context.mounted) return;
    try {
      await members.changeRole(
          teamId: teamId, userId: player.id, isTeamLeader: role);
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
      icon: Icon(CupertinoIcons.person_crop_circle_badge_checkmark,
          color: AppColors.of(context).grass),
    );
  }
}
