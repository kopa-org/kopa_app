import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/home_calendar_overlay.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('navigates months and opens an event day', (tester) async {
    final now = DateTime(2026, 6, 8);
    final event = MatchDetails(
      id: 42,
      type: 'training',
      date: DateTime(2026, 6, 14, 18),
      location: 'Kopa Arena',
      createdAt: now,
      updatedAt: now,
    );
    MatchDetails? openedEvent;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HomeCalendarCard(
            events: [event],
            initialMonth: now,
            today: now,
            onEventTap: (value) => openedEvent = value,
          ),
        ),
      ),
    );

    expect(find.text('Juni 2026'), findsOneWidget);
    expect(find.text('Kamp'), findsOneWidget);
    expect(find.text('Træning'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-day-2026-06-14')));
    await tester.pump();
    expect(openedEvent?.id, 42);

    await tester.tap(find.byTooltip('Næste måned'));
    await tester.pumpAndSettle();
    expect(find.text('Juli 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Forrige måned'));
    await tester.pumpAndSettle();
    expect(find.text('Juni 2026'), findsOneWidget);
  });
}
