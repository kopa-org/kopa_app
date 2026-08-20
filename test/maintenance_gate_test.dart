import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/feature_flags_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/maintenance/maintenance_gate.dart';
import 'package:kopa/repository/feature_flags_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('blocks the app with the maintenance message', (tester) async {
    final cubit = FeatureFlagsCubit(
      repository: FeatureFlagsRepository(),
      initialFeatureFlags: const AppFeatureFlags(maintenanceMode: true),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('da'),
          home: const MaintenanceGate(child: Text('App content')),
        ),
      ),
    );

    expect(find.text('App content'), findsNothing);
    expect(
      find.text('Kopa er under vedligeholdelse og vil snart være klar igen.'),
      findsOneWidget,
    );
  });
}
