import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/feature_flags_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class MaintenanceGate extends StatelessWidget {
  const MaintenanceGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsCubit, FeatureFlagsState>(
      buildWhen: (previous, current) =>
          previous.maintenanceMode != current.maintenanceMode,
      builder: (context, state) {
        if (!state.maintenanceMode) return child;

        return const MaintenancePage();
      },
    );
  }
}

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              localizations.maintenanceMessage,
              textAlign: TextAlign.center,
              style: styles.h4.copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w800,
                height: 36 / 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
