import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_rsvp_card.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('packages/cupertino_icons/CupertinoIcons')
      ..addFont(rootBundle
          .load('packages/cupertino_icons/assets/CupertinoIcons.ttf'));
    await icons.load();
  });
  for (final status in MatchRsvpStatus.values) {
    for (final width in [320.0, 390.0]) {
      testWidgets('$status supports RSVP and attendee navigation at $width',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var accepted = 0;
        var declined = 0;
        var attendeesOpened = 0;
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: Padding(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: boundaryKey,
              child: MatchRsvpCard(
                status: status,
                isSaving: false,
                attendeeNames: const [
                  'Mads Jensen',
                  'Anna Hansen',
                  'Bo',
                  'Ida',
                  'Peter',
                  'Søren'
                ],
                attendeeCount: 12,
                onAccept: () => accepted++,
                onDecline: () => declined++,
                onShowAttendees: () => attendeesOpened++,
              ),
            ),
          )),
        ));
        await tester.pumpAndSettle();
        expect(find.text('12 tilmeldte'), findsOneWidget);
        expect(find.text('+7'), findsOneWidget);
        final avatars = tester.getRect(
          find.byKey(const ValueKey('match-rsvp-attendee-avatars')),
        );
        final count = tester.getRect(find.text('12 tilmeldte'));
        expect(avatars.bottom, lessThan(count.top));
        expect(avatars.right, closeTo(count.right, 0.1));
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(MatchRsvpCard));
        final l10n = AppLocalizations.of(context)!;
        if (status == MatchRsvpStatus.pending) {
          expect(find.text(l10n.matchRsvpQuestion), findsOneWidget);
          expect(find.text(l10n.matchRsvpHint), findsOneWidget);
        } else {
          expect(find.text(l10n.matchRsvpQuestion), findsNothing);
          expect(find.text(l10n.matchRsvpHint), findsNothing);
          expect(find.text(l10n.matchDetailsRsvpRegistered), findsNothing);
          expect(find.text(l10n.matchDetailsRsvpDeclined), findsNothing);
          expect(find.byKey(const ValueKey('match-rsvp-confirmation')),
              findsNothing);
          expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
          final summary = tester.getRect(
            find.byKey(const ValueKey('match-rsvp-attendees')),
          );
          final dropdown = tester.getRect(
            find.byKey(const ValueKey('match-details-rsvp-status')),
          );
          expect(dropdown.right, lessThan(summary.left));
          expect(dropdown.center.dy, closeTo(summary.center.dy, 0.1));
          expect(
              find.text(status == MatchRsvpStatus.awaitingSelection
                  ? l10n.matchDetailsRsvpPendingSelection
                  : status == MatchRsvpStatus.attending
                      ? l10n.homeAttendanceGoing
                      : l10n.homeAttendanceDeclined),
              findsOneWidget);
        }

        // Optional rendered reference for comparison with the Figma card.
        final previewDirectory = Platform.environment['KOPA_RSVP_PREVIEW_DIR'];
        if (previewDirectory != null && width == 390) {
          await tester.runAsync(() async {
            final boundary = boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            await File('$previewDirectory/${status.name}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        if (status == MatchRsvpStatus.pending) {
          await tester.tap(find.byKey(const ValueKey('match-rsvp-accept')));
          await tester.tap(find.byKey(const ValueKey('match-rsvp-decline')));
          expect(accepted, 1);
          expect(declined, 1);
        } else {
          final going = status != MatchRsvpStatus.declined;
          final dropdown =
              find.byKey(const ValueKey('match-details-rsvp-status'));
          await tester.tap(dropdown);
          await tester.pumpAndSettle();
          expect(find.byType(BottomSheet), findsOneWidget);
          // Keeping the current response closes the sheet without saving.
          await tester.tap(find.byKey(ValueKey(
              going ? 'attendance_response_yes' : 'attendance_response_no')));
          await tester.pumpAndSettle();
          expect(accepted, 0);
          expect(declined, 0);
          await tester.tap(dropdown);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(ValueKey(
              going ? 'attendance_response_no' : 'attendance_response_yes')));
          await tester.pumpAndSettle();
          expect(accepted, going ? 0 : 1);
          expect(declined, going ? 1 : 0);
        }
        await tester.tap(find.byKey(const ValueKey('match-rsvp-attendees')));
        expect(attendeesOpened, 1);
      });
    }
  }

  for (final status in MatchRsvpStatus.values) {
    testWidgets('saving disables response changes for $status', (tester) async {
      var changes = 0;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: MatchRsvpCard(
          status: status,
          isSaving: true,
          attendeeNames: const [],
          attendeeCount: 0,
          onAccept: () => changes++,
          onDecline: () => changes++,
          onShowAttendees: () {},
        )),
      ));
      if (status == MatchRsvpStatus.pending) {
        await tester.tap(find.byKey(const ValueKey('match-rsvp-accept')));
        await tester.tap(find.byKey(const ValueKey('match-rsvp-decline')));
      } else {
        await tester
            .tap(find.byKey(const ValueKey('match-details-rsvp-status')));
        await tester.pump();
        expect(find.byType(BottomSheet), findsNothing);
      }
      expect(changes, 0);
    });
  }
}
