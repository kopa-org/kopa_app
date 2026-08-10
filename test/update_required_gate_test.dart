import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/feature_flags_cubit.dart';
import 'package:kopa/page/update_required/update_required_gate.dart';
import 'package:kopa/repository/feature_flags_repository.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('renders update required design with lottie illustration',
      (tester) async {
    final cubit = FeatureFlagsCubit(
      repository: FeatureFlagsRepository(),
      initialFeatureFlags: const AppFeatureFlags(updateRequired: true),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const UpdateRequiredGate(
            child: Text('App content'),
          ),
        ),
      ),
    );

    expect(find.text('App content'), findsNothing);
    expect(find.text('Opdatering påkrævet'), findsOneWidget);
    expect(
      find.text(
        'En ny version af Kopa er tilgængelig. Opdater venligst for at fortsætte din holdoplevelse.',
      ),
      findsOneWidget,
    );
    expect(find.text('Opdater nu'), findsOneWidget);
    expect(find.text('Senere'), findsNothing);
    expect(find.byType(Lottie), findsOneWidget);
  });
}
