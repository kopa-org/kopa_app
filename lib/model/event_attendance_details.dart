import 'package:kopa/model/user_details.dart';

class EventAttendanceDetails {
  final int id;
  final UserDetails userDetails;
  final bool isAttending;
  final bool? isSelected;
  final int? lineupSlot;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventAttendanceDetails({
    required this.id,
    required this.userDetails,
    required this.isAttending,
    this.isSelected,
    this.lineupSlot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventAttendanceDetails.fromJson(Map<String, dynamic> json) {
    return EventAttendanceDetails(
      id: json['id'],
      userDetails: UserDetails.fromJson(json['user_details']),
      isAttending: json['is_attending'],
      isSelected: json['is_selected'],
      lineupSlot: json['lineup_slot'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
