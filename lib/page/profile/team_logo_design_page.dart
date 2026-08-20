import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/component/team_logo_design_editor.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class TeamLogoDesignPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final TeamLogoDesign initialDesign;

  const TeamLogoDesignPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.initialDesign,
  });

  @override
  State<TeamLogoDesignPage> createState() => _TeamLogoDesignPageState();
}

class _TeamLogoDesignPageState extends State<TeamLogoDesignPage> {
  late TeamLogoDesign _design;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _design = widget.initialDesign;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.teamLogoEditTitle,
      showBackButton: true,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeamLogoDesignEditor(
              teamName: widget.teamName,
              design: _design,
              onChanged: (design) => setState(() => _design = design),
            ),
            const SizedBox(height: 28),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: appTextStyles.body.copyWith(color: appColors.error),
              ),
              const SizedBox(height: 12),
            ],
            FullWidthButton(
              buttonText: _isSaving ? l10n.teamLogoSaving : l10n.teamLogoSave,
              icon: Icons.check,
              onPressed: _isSaving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final onboardingCubit = context.read<OnboardingCubit>();
      final saved = await onboardingCubit.updateTeamLogo(
        teamId: widget.teamId,
        logoDesign: _design,
      );
      if (!mounted) return;

      if (!saved) {
        setState(() {
          _isSaving = false;
          _errorMessage = onboardingCubit.state.errorMessage ??
              AppLocalizations.of(context)!.teamLogoSaveFailure;
        });
        return;
      }

      await context.read<AuthCubit>().init();
      if (!mounted) return;
      Navigator.of(context).pop(_design);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }
}
