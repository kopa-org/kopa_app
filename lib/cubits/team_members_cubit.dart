import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/users_repository.dart';

class TeamMembersState {
  final List<UserDetails> members;
  final bool loading;
  final int? savingUserId;
  final bool loadFailed;
  const TeamMembersState({
    this.members = const [],
    this.loading = false,
    this.savingUserId,
    this.loadFailed = false,
  });
}

class TeamMembersCubit extends Cubit<TeamMembersState> {
  final Future<List<UserDetails>> Function() _loadMembers;
  final Future<UserDetails> Function(
      {required int teamId,
      required int userId,
      required bool isTeamLeader}) _updateRole;
  final Future<UserDetails> Function(
      {required int teamId,
      required int userId,
      required bool isFineAdmin}) _updateFineAdmin;

  TeamMembersCubit(
      {Future<List<UserDetails>> Function()? loadMembers,
      Future<UserDetails> Function(
              {required int teamId,
              required int userId,
              required bool isTeamLeader})?
          updateRole,
      Future<UserDetails> Function(
              {required int teamId,
              required int userId,
              required bool isFineAdmin})?
          updateFineAdmin})
      : _loadMembers = loadMembers ?? UsersRepository.getSquad,
        _updateRole = updateRole ?? UsersRepository.updateTeamRole,
        _updateFineAdmin = updateFineAdmin ?? UsersRepository.updateFineAdmin,
        super(const TeamMembersState());

  Future<void> load() async {
    emit(TeamMembersState(members: state.members, loading: true));
    try {
      final members = await _loadMembers();
      if (!isClosed) emit(TeamMembersState(members: members));
    } catch (_) {
      if (!isClosed) {
        emit(TeamMembersState(members: state.members, loadFailed: true));
      }
    }
  }

  Future<UserDetails?> changeRole(
          {required int teamId,
          required int userId,
          required bool isTeamLeader}) =>
      _saveMember(
          userId,
          () => _updateRole(
              teamId: teamId, userId: userId, isTeamLeader: isTeamLeader));

  Future<UserDetails?> changeFineAdmin(
          {required int teamId,
          required int userId,
          required bool isFineAdmin}) =>
      _saveMember(
          userId,
          () => _updateFineAdmin(
              teamId: teamId, userId: userId, isFineAdmin: isFineAdmin));

  Future<UserDetails?> _saveMember(
      int userId, Future<UserDetails> Function() save) async {
    if (state.savingUserId != null) return null;
    emit(TeamMembersState(members: state.members, savingUserId: userId));
    try {
      final updated = await save();
      if (!isClosed) {
        emit(TeamMembersState(members: [
          for (final member in state.members)
            member.id == userId ? updated : member,
        ]));
      }
      return updated;
    } catch (_) {
      if (!isClosed) emit(TeamMembersState(members: state.members));
      rethrow;
    }
  }
}
