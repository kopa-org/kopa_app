class RegisterForUnregisterFromEventCommand {
  String eventId;

  RegisterForUnregisterFromEventCommand({required this.eventId});

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
    };
  }
}
