// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/main.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final authRepository = ApiAuthRepository();
    final onboardingRepository = OnboardingRepository();
    final authCubit = AuthCubit(authRepository: authRepository);
    final onboardingCubit = OnboardingCubit(onboardingRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(KopaApp(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      featureFlags: const AppFeatureFlags(),
      authCubit: authCubit,
      onboardingCubit: onboardingCubit,
    ));

    // Verify that the app widget is rendered
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
