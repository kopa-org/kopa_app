import 'package:kopa/model/team_details.dart';

class UserDetails {
  final int id;
  final String name;
  final String email;
  final bool isTeamOwner;
  final int roleId;
  final DateTime? dateOfBirth;
  final String? position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TeamDetails? teamDetails;
  final UserOnboardingState? onboardingState;

  UserDetails(
      {required this.id,
      required this.name,
      required this.email,
      required this.isTeamOwner,
      required this.roleId,
      this.dateOfBirth,
      this.position,
      required this.createdAt,
      required this.updatedAt,
      required this.teamDetails,
      this.onboardingState});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isTeamOwner: json['is_team_owner'],
      roleId: json['role_id'],
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.tryParse(json['date_of_birth']),
      position: json['position'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      teamDetails: json['team_details'] == null
          ? null
          : TeamDetails.fromJson(json['team_details']),
      onboardingState: json['onboarding_state'] == null
          ? null
          : UserOnboardingState.fromJson(json['onboarding_state']),
    );
  }
}

class UserOnboardingState {
  final String status;
  final UserPendingJoinRequest? joinRequest;

  const UserOnboardingState({
    required this.status,
    this.joinRequest,
  });

  bool get isComplete => status == 'complete';
  bool get needsOnboarding => status == 'needs_onboarding';
  bool get isWaitingApproval => status == 'waiting_approval';

  factory UserOnboardingState.fromJson(Map<String, dynamic> json) {
    return UserOnboardingState(
      status: json['status'] ?? 'needs_onboarding',
      joinRequest: json['join_request'] == null
          ? null
          : UserPendingJoinRequest.fromJson(json['join_request']),
    );
  }
}

class UserPendingJoinRequest {
  final int id;
  final String status;
  final int teamId;
  final String? teamTitle;
  final String? leaderName;

  const UserPendingJoinRequest({
    required this.id,
    required this.status,
    required this.teamId,
    this.teamTitle,
    this.leaderName,
  });

  factory UserPendingJoinRequest.fromJson(Map<String, dynamic> json) {
    return UserPendingJoinRequest(
      id: json['id'],
      status: json['status'] ?? 'pending',
      teamId: json['team_id'],
      teamTitle: json['team_title'],
      leaderName: json['leader_name'],
    );
  }
}
