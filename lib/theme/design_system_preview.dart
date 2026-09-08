import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/chip/status_chip.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

@Preview(name: 'Kopa foundations', group: 'Design system', size: Size(390, 844))
Widget designSystemPreview() => const DesignSystemPreview();

class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final text = Theme.of(context).textTheme;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.onboardingTitle, style: text.headlineMedium),
                    const SizedBox(height: 24),
                    KopaCard(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.onboardingWaitingTitle,
                            style: text.titleLarge),
                        const SizedBox(height: 12),
                        Text(l10n.onboardingWaitingBody, style: text.bodyLarge),
                        const SizedBox(height: 16),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          StatusChip(
                              label: l10n.commonOk, status: ChipStatus.success),
                          StatusChip(
                              label: l10n.onboardingWaitingTitle,
                              status: ChipStatus.info),
                        ]),
                      ],
                    )),
                    const SizedBox(height: 24),
                    TextField(
                        decoration: InputDecoration(
                            labelText: l10n.onboardingTeamName)),
                    const SizedBox(height: 16),
                    Button(
                        buttonText: l10n.onboardingContinue,
                        onPressed: () {},
                        icon: Icons.arrow_forward),
                    const SizedBox(height: 12),
                    Button(
                        buttonText: l10n.commonCancel,
                        onPressed: () {},
                        variant: ButtonVariant.secondary),
                    const SizedBox(height: 12),
                    Button(
                        buttonText: l10n.commonDelete,
                        onPressed: () {},
                        variant: ButtonVariant.destructive),
                    const SizedBox(height: 12),
                    Button(
                        buttonText: l10n.onboardingContinue,
                        onPressed: () {},
                        enabled: false),
                  ],
                ),
              ),
            ),
          );
        }),
      );
}
