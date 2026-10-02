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
        expect(tester.takeException(), isNull);
        if (width == 390 && status == MatchRsvpStatus.attending) {
          expect(
            tester
                .getSize(find.byKey(const ValueKey('match-rsvp-card')))
                .height,
            closeTo(219, 1),
          );
          expect(
            tester
                .getSize(find.byKey(const ValueKey('match-rsvp-confirmation')))
                .height,
            closeTo(94, 1),
          );
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
        } else if (status == MatchRsvpStatus.declined) {
          await tester.tap(
              find.byKey(const ValueKey('match-details-rsvp-accept-action')));
          expect(accepted, 1);
          expect(declined, 0);
        } else {
          await tester.tap(
              find.byKey(const ValueKey('match-details-rsvp-decline-action')));
          expect(accepted, 0);
          expect(declined, 1);
        }
        await tester.tap(find.byKey(const ValueKey('match-rsvp-attendees')));
        expect(attendeesOpened, 1);
      });
    }
  }

  testWidgets('saving disables both initial decisions', (tester) async {
    var changes = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: MatchRsvpCard(
        status: MatchRsvpStatus.pending,
        isSaving: true,
        attendeeNames: const [],
        attendeeCount: 0,
        onAccept: () => changes++,
        onDecline: () => changes++,
        onShowAttendees: () {},
      )),
    ));
    await tester.tap(find.byKey(const ValueKey('match-rsvp-accept')));
    await tester.tap(find.byKey(const ValueKey('match-rsvp-decline')));
    expect(changes, 0);
  });
}
