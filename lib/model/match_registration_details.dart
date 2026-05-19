import 'package:kopa/model/user_details.dart';

class MatchRegistrationDetails {
  final int id;
  final UserDetails userDetails;
  final bool isUserParticipating;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatchRegistrationDetails({
    required this.id,
    required this.userDetails,
    required this.isUserParticipating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchRegistrationDetails.fromJson(Map<String, dynamic> json) {
    return MatchRegistrationDetails(
      id: json['id'],
      userDetails: UserDetails.fromJson(json['user_details']),
      isUserParticipating: json['is_user_participating'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
