import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kopa/component/home/home_calendar_overlay.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_theme.dart';

@Preview(
  name: 'Home calendar overlay',
  group: 'Home',
  size: Size(390, 430),
)
Widget homeCalendarOverlayPreview() {
  final now = DateTime(2026, 6, 8);
  final events = [
    _previewEvent(1, DateTime(2026, 6, 4), 'match'),
    _previewEvent(2, DateTime(2026, 6, 7), 'training'),
    _previewEvent(3, DateTime(2026, 6, 14), 'training'),
    _previewEvent(4, DateTime(2026, 6, 19), 'match'),
    _previewEvent(5, DateTime(2026, 6, 23), 'training'),
    _previewEvent(6, DateTime(2026, 6, 24), 'match'),
  ];

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: HomeCalendarCard(
          events: events,
          initialMonth: now,
          today: now,
          onEventTap: (_) {},
        ),
      ),
    ),
  );
}

MatchDetails _previewEvent(int id, DateTime date, String type) {
  return MatchDetails(
    id: id,
    type: type,
    date: date,
    location: 'Kopa Arena',
    createdAt: date,
    updatedAt: date,
  );
}
