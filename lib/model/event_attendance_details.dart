import 'package:kopa/model/user_details.dart';

class EventAttendanceDetails {
  final int id;
  final UserDetails userDetails;
  final bool isAttending;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventAttendanceDetails({
    required this.id,
    required this.userDetails,
    required this.isAttending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventAttendanceDetails.fromJson(Map<String, dynamic> json) {
    return EventAttendanceDetails(
      id: json['id'],
      userDetails: UserDetails.fromJson(json['user_details']),
      isAttending: json['is_attending'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
