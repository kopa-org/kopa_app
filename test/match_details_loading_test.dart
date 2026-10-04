import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/match/match_poll_details_card.dart';
import 'package:kopa/component/match/player_of_match_summary_card.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/component/match/match_details_sheet_scroll_view.dart';

void main() {
  for (final (platform, variant) in [
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS])
      for (final variant in [
        'pending',
        'attending',
        'declined',
        'training',
        'scored'
      ])
        (platform, variant),
  ]) {
    testWidgets(
        '$platform $variant stays in place after hero flight and loading',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final user = _user();
      final auth = _AuthenticatedCubit(user);
      addTearDown(auth.close);
      final initialMatch = _match(variant, location: 'Home stadium');
      final matchResponse = Completer<MatchDetails>();
      final squadResponse = Completer<List<UserDetails>>();
      var matchStarted = false;
      var squadStarted = false;
      const heroTag = 'home-match-42-home_hero';

      await tester.pumpWidget(_app(
        auth: auth,
        platform: platform,
        home: Builder(builder: (context) {
          return Scaffold(
            body: Column(children: [
              Row(children: [
                for (final side in TeamSide.values)
                  TeamBadgeLabel(
                    teamName: side == TeamSide.home ? 'Kopa IF' : 'Fremad',
                    teamId: side.index + 1,
                    heroTag: MatchHeroCard.logoHeroTag(heroTag, side),
                  ),
              ]),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MatchDetailsPage(
                    matchId: 42,
                    initialMatch: initialMatch,
                    heroTag: heroTag,
                    showBottomNavigationBar: false,
                    loadMatch: (id) {
                      expect(id, 42);
                      matchStarted = true;
                      return matchResponse.future;
                    },
                    loadSquad: () {
                      squadStarted = true;
                      return squadResponse.future;
                    },
                  ),
                )),
                child: const Text('Open match'),
              ),
            ]),
          );
        }),
      ));

      await tester.tap(find.text('Open match'));
      await tester.pumpAndSettle();
      // Both requests must start before either response is available.
      expect(matchStarted, isTrue);
      expect(squadStarted, isTrue);
      expect(
          tester
              .widget<MatchHeroCard>(find.byType(MatchHeroCard))
              .match
              .location,
          'Home stadium');
      if (variant != 'scored') {
        expect(find.text('Praktisk information'), findsOneWidget);
      }

      final hero = find.byType(MatchHeroCard);
      final header = find.byKey(const ValueKey('match-details-scroll-header'));
      final segment =
          find.byKey(const ValueKey('match-details-segment-overview'));
      final initialHeroRect = tester.getRect(hero);
      final initialHeaderRect = tester.getRect(header);
      final initialSegmentRect = tester.getRect(segment);
      final practicalTitle = find.text('Praktisk information');
      final initialPracticalRect =
          variant == 'scored' ? null : tester.getRect(practicalTitle);
      if (variant == 'attending') {
        final darkHeader = tester.getRect(
          find.byKey(const ValueKey('match-details-dark-header')),
        );
        final rsvpCard = tester.getRect(
          find.byKey(const ValueKey('match-rsvp-card')),
        );
        final status = tester.getRect(
          find.byKey(const ValueKey('match-details-rsvp-status')),
        );
        expect(rsvpCard.top, greaterThan(darkHeader.bottom));
        expect(status.top, greaterThan(rsvpCard.top));
        expect(initialPracticalRect!.top, greaterThan(status.bottom));
      }

      matchResponse.complete(_match(variant, location: 'Fetched stadium'));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getRect(hero), initialHeroRect);

      squadResponse.complete([user]);
      await tester.pumpAndSettle();
      expect(
          tester.widget<MatchHeroCard>(hero).match.location, 'Fetched stadium');
      expect(tester.getRect(hero), initialHeroRect);
      expect(tester.getRect(header), initialHeaderRect);
      expect(tester.getRect(segment), initialSegmentRect);
      if (initialPracticalRect != null) {
        expect(tester.getRect(practicalTitle), initialPracticalRect);
      }
      expect(tester.takeException(), isNull);
      expect(find.byType(PlayerOfMatchSummaryCard), findsNothing);
      expect(find.byType(MatchPollDetailsCard), findsNothing);
      expect(find.byKey(const ValueKey('match-quick-actions-fab')),
          variant == 'training' ? findsNothing : findsOneWidget);
      if (variant == 'training') {
        expect(find.byType(MatchDetailsSheetScrollView), findsOneWidget);
        expect(
            tester
                .widget<ColoredBox>(
                    find.byKey(const ValueKey('match-details-dark-header')))
                .color,
            AppColors.light.lightSky65);
        final track = tester.widget<Container>(
            find.byKey(const ValueKey('match-details-dark-segment-control')));
        expect((track.decoration! as BoxDecoration).color,
            AppColors.light.lightSky95);
        expect(find.byKey(const ValueKey('match-details-segment-timeline')),
            findsNothing);
        final sheet = find.byKey(const ValueKey('match-details-body-sheet'));
        final originalSheetTop = tester.getRect(sheet).top;
        await tester.drag(
            find.byKey(const ValueKey('match-details-sheet-scroll')),
            const Offset(0, -100));
        await tester.pumpAndSettle();
        expect(tester.getRect(sheet).top, lessThan(originalSheetTop));
        expect(
            tester
                .widget<Opacity>(
                    find.byKey(const ValueKey('match-details-header-fade')))
                .opacity,
            lessThan(1));
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        await tester.tap(
            find.byKey(const ValueKey('match-details-segment-attendance')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('match-rsvp-card')), findsNothing);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('ready details appear immediately without a fixed delay',
      (tester) async {
    final user = _user();
    final auth = _AuthenticatedCubit(user);
    addTearDown(auth.close);
    await tester.pumpWidget(_app(
      auth: auth,
      home: MatchDetailsPage(
        matchId: 42,
        initialMatch: _match('pending', location: 'Home stadium'),
        showBottomNavigationBar: false,
        loadMatch: (_) async => _match('pending', location: 'Fetched stadium'),
        loadSquad: () async => [user],
      ),
    ));
    await tester.pump();
    expect(find.text('Fetched stadium'), findsOneWidget);
    expect(find.text('Praktisk information'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  required AuthCubit auth,
  required Widget home,
  TargetPlatform platform = TargetPlatform.android,
}) =>
    BlocProvider<AuthCubit>.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.lightTheme.copyWith(platform: platform),
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

MatchDetails _match(String variant, {required String location}) {
  final date = DateTime.now().add(const Duration(days: 1));
  return MatchDetails(
    id: 42,
    type: variant == 'training'
        ? MatchDetails.trainingType
        : MatchDetails.matchType,
    homeTeam: 'Kopa IF',
    awayTeam: 'Fremad',
    date: date,
    location: location,
    createdAt: date,
    updatedAt: date,
    isCurrentUserAttending: switch (variant) {
      'attending' => true,
      'declined' => false,
      _ => null,
    },
    homeTeamScore: variant == 'scored' ? 2 : null,
    awayTeamScore: variant == 'scored' ? 1 : null,
  );
}

UserDetails _user() {
  final date = DateTime.now();
  return UserDetails(
    id: 1,
    name: 'Test owner',
    email: 'test@example.com',
    isTeamOwner: true,
    roleId: 1,
    createdAt: date,
    updatedAt: date,
    teamDetails: null,
  );
}

class _AuthenticatedCubit extends AuthCubit {
  _AuthenticatedCubit(UserDetails user)
      : super(authRepository: _UnusedAuthRepository()) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  Future<UserDetails?> getCurrentUser() async => null;
  @override
  Future<bool> login(String email, String password) async => false;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async =>
      false;
}
