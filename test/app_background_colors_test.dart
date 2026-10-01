import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/football_pitch.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('Home follows background changes on $platform', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final auth = _AuthenticatedCubit();
      final refresh = MatchProgrammeRefreshNotifier();
      addTearDown(auth.close);
      addTearDown(refresh.dispose);
      final background = ValueNotifier(const Color(0xFF9B34C8));
      addTearDown(background.dispose);

      await tester.pumpWidget(ValueListenableBuilder<Color>(
        valueListenable: background,
        builder: (context, color, child) => MaterialApp(
          themeAnimationDuration: Duration.zero,
          theme: _theme(AppColors.light.copyWith(background: color), platform),
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<AuthCubit>.value(
            value: auth,
            child: ChangeNotifierProvider.value(
              value: refresh,
              child: const HomeTab(),
            ),
          ),
        ),
      ));
      await tester.pump();

      Color? pageColor() => platform == TargetPlatform.iOS
          ? tester
              .widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold))
              .backgroundColor
          : tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
      expect(pageColor(), background.value);
      background.value = const Color(0xFF319EAB);
      await tester.pump();
      expect(pageColor(), background.value);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('card, avatar and pitch fills use independent active tokens',
      (tester) async {
    final colors = AppColors.light.copyWith(
      surface: const Color(0xFFFF00C8),
      white: const Color(0xFF31DFBE),
      pitch: const Color(0xFF7D32A9),
      pitchStripe: const Color(0xFFFA9371),
    );
    await tester.pumpWidget(MaterialApp(
      theme: _theme(colors, TargetPlatform.android),
      home: const Scaffold(
          body: Column(children: [
        KopaCard(child: Text('Card')),
        AppAvatar(initials: 'AB'),
        SizedBox(height: 200, child: FootballPitch()),
      ])),
    ));
    final card = find.descendant(
        of: find.byType(KopaCard), matching: find.byType(Material));
    expect(tester.widget<Material>(card).color, colors.surface);
    expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        colors.white);
    final pitch = find.descendant(
        of: find.byType(FootballPitch), matching: find.byType(Container));
    expect((tester.widget<Container>(pitch).decoration! as BoxDecoration).color,
        colors.pitch);
    final stripe = find.descendant(
        of: find.byType(FootballPitch), matching: find.byType(ColoredBox));
    for (final box in tester.widgetList<ColoredBox>(stripe)) {
      expect(box.color, colors.pitchStripe.withValues(alpha: 0.3));
    }
    final paint = find.descendant(
        of: find.byType(FootballPitch), matching: find.byType(CustomPaint));
    expect(
        (tester.widget<CustomPaint>(paint).painter! as FootballPitchPainter)
            .lineColor,
        colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page scaffold uses background separately from offWhite',
      (tester) async {
    final colors = AppColors.light.copyWith(
        background: const Color(0xFFA567CD), offWhite: const Color(0xFF009A91));
    await tester.pumpWidget(MaterialApp(
      theme: _theme(colors, TargetPlatform.android),
      home: const PageScaffold(title: 'Page', body: SizedBox()),
    ));
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        colors.background);
    expect(tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        colors.background);
  });

  test('UI palette literals are defined only in AppColors', () {
    final literal = RegExp(
        r'\b(?:Colors|CupertinoColors)\.|\bColor\(0x|\bColor\.from(?:ARGB|RGBO)');
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('.dart') &&
            !file.path.endsWith('theme/app_colors.dart'))
        .where((file) => literal.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();
    expect(offenders, isEmpty,
        reason: 'Background palettes must stay in AppColors.');
  });
}

ThemeData _theme(AppColors colors, TargetPlatform platform) {
  return AppTheme.lightTheme.copyWith(platform: platform, extensions: [
    ...AppTheme.lightTheme.extensions.values
        .where((extension) => extension is! AppColors),
    colors,
  ]);
}

class _AuthenticatedCubit extends AuthCubit {
  _AuthenticatedCubit() : super(authRepository: _UnusedAuthRepository()) {
    final now = DateTime(2026, 10, 1);
    emit(AuthState(
        status: AuthStatus.authenticated,
        user: UserDetails(
          id: 1,
          name: 'Test Player',
          email: 'test@example.com',
          isTeamOwner: false,
          roleId: 1,
          createdAt: now,
          updatedAt: now,
          teamDetails: null,
        )));
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
  Future<bool> register(
          {required String name,
          required String email,
          required String password,
          required int roleId}) async =>
      false;
}
