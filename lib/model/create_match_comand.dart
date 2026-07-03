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
      'home_team': firstTeam,
      'away_team': secondTeam,
      'location': location,
      'date': date.toUtc().toIso8601String(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };

    if (meetingTime != null) {
      json['meeting_time'] = _formatTime(meetingTime!);
    }

    return json;
  }

  String _formatTime(DateTime value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(value.hour)}:${twoDigits(value.minute)}:00';
  }
}
