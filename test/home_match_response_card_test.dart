import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('places the decline action before the accept action',
      (tester) async {
    final homeCubit = HomeCubit();
    addTearDown(homeCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: BlocProvider.value(
          value: homeCubit,
          child: Scaffold(
            body: HomeMatchResponseCard(
              match: _match(),
              currentUser: _user(),
            ),
          ),
        ),
      ),
    );

    final declineButton = find.byKey(
      const ValueKey('match_response_decline'),
    );
    final acceptButton = find.byKey(
      const ValueKey('match_response_accept'),
    );

    expect(declineButton, findsOneWidget);
    expect(acceptButton, findsOneWidget);
    expect(
      tester.getCenter(declineButton).dx,
      lessThan(tester.getCenter(acceptButton).dx),
    );
    expect(tester.getSize(declineButton).height, 42);
    expect(tester.getSize(acceptButton).height, 42);

    final acceptMaterial = tester.widget<Material>(
      find.descendant(
        of: acceptButton,
        matching: find.byType(Material),
      ),
    );
    expect(acceptMaterial.color, AppColors.light.primary);
  });

  for (final going in [true, false]) {
    testWidgets('answered status opens choices and changes response: $going',
        (tester) async {
      final cubit = _ResponseCubit();
      addTearDown(cubit.close);
      Future<void> render(bool? response) => tester.pumpWidget(MaterialApp(
            locale: const Locale('da'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<HomeCubit>.value(
              value: cubit,
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 320,
                    child: HomeMatchResponseCard(
                      match: _match(response),
                      currentUser: _user(),
                    ),
                  ),
                ),
              ),
            ),
          ));
      await render(null);
      await tester.pumpAndSettle();
      final unansweredHeight =
          tester.getSize(find.byType(HomeMatchResponseCard)).height;
      await render(going);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(HomeMatchResponseCard)).height,
          lessThan(unansweredHeight));
      expect(find.text(going ? 'Du er tilmeldt' : 'Afbud registreret'),
          findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('match_response_status')));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Ja, jeg kommer'), findsOneWidget);
      expect(find.text('Nej'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey(
        going ? 'attendance_response_no' : 'attendance_response_yes',
      )));
      await tester.pumpAndSettle();
      expect(cubit.response, !going);
      expect(cubit.matchId, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

class _ResponseCubit extends HomeCubit {
  bool? response;
  int? matchId;

  @override
  Future<void> registerForMatch(int matchId, int teamId) async {
    response = true;
    this.matchId = matchId;
  }

  @override
  Future<void> declineMatch(int matchId, int teamId) async {
    response = false;
    this.matchId = matchId;
  }
}

MatchDetails _match([bool? response]) {
  final date = DateTime(2026, 10, 1, 19);
  return MatchDetails(
    id: 1,
    isCurrentUserRegistered: response == true,
    isCurrentUserAttending: response,
    homeTeam: 'Kopa IF',
    awayTeam: 'Fremad',
    date: date,
    location: 'Kopa Stadion',
    createdAt: date,
    updatedAt: date,
  );
}

UserDetails _user() {
  final now = DateTime(2026, 1, 1);
  return UserDetails(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
