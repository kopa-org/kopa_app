class CreateMatchCommand {
  final String firstTeam;
  final String secondTeam;
  final String location;
  final DateTime? meetingTime;
  final DateTime date;
  final String? notes;

  CreateMatchCommand(
    this.firstTeam,
    this.secondTeam,
    this.location,
    this.meetingTime,
    this.date,
    this.notes,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'first_team': firstTeam,
      'second_team': secondTeam,
      'location': location,
      'date': date.toString(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };

    if (meetingTime != null) {
      json['meeting_time'] = meetingTime.toString();
    }

    return json;
  }
}
