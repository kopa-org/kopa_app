import 'package:kopa/model/event_type.dart';

class CreateMatchCommand {
  final String? firstTeam;
  final String? secondTeam;
  final String location;
  final DateTime? meetingTime;
  final DateTime date;
  final String? notes;
  final KopaEventType eventType;
  final String? category;
  final List<DateTime>? occurrences;

  CreateMatchCommand(
    this.firstTeam,
    this.secondTeam,
    this.location,
    this.meetingTime,
    this.date,
    this.notes, {
    this.eventType = KopaEventType.match,
    this.category,
    this.occurrences,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': eventType.apiValue,
      if (firstTeam != null && firstTeam!.trim().isNotEmpty)
        'home_team': firstTeam,
      if (secondTeam != null && secondTeam!.trim().isNotEmpty)
        'away_team': secondTeam,
      'location': location,
      'date': date.toUtc().toIso8601String(),
      if (category != null && category!.trim().isNotEmpty)
        'category': category!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
      if (occurrences != null)
        'occurrences': occurrences!
            .map((occurrence) => occurrence.toUtc().toIso8601String())
            .toList(growable: false),
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
