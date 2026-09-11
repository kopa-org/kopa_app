import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/home_cubit.dart';
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
}

MatchDetails _match() {
  final date = DateTime(2026, 10, 1, 19);
  return MatchDetails(
    id: 1,
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
