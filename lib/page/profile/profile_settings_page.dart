import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _isLoading = false;
  String? _errorMessage;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final currentUser = context.read<AuthCubit>().state.user;

    return PageScaffold(
      title: 'Indstillinger',
      showBackButton: true,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: appTextStyles.body.copyWith(color: appColors.error),
                ),
              ),
            FullWidthButton(
              buttonText: 'Importér kampprogram',
              onPressed: _isLoading ? () {} : _importCalendar,
            ),
            const SizedBox(height: 16),
            FullWidthButton(
              buttonText: 'Del Kopa',
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'Kopa samler holdets kampe, statistik og bødekasse ét sted.',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Holdværktøjer', style: appTextStyles.sectionHeader),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Inviter spiller via email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FullWidthButton(
              buttonText: 'Send invitation',
              onPressed: () async {
                if (_emailController.text.isEmpty || currentUser == null) {
                  return;
                }
                final teamId = currentUser.teamDetails?.id ?? 0;
                await context.read<OnboardingCubit>().sendEmailInvites(
                  teamId,
                  [_emailController.text.trim()],
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitation sendt.')),
                );
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                if (state.status == OnboardingStatus.loading) {
                  return const LoadingIndicator();
                }

                if (state.errorMessage != null) {
                  return Text(
                    state.errorMessage!,
                    style:
                        appTextStyles.caption.copyWith(color: appColors.error),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            FullWidthButton(
              buttonText: _isLoading ? 'Logger ud...' : 'Log ud',
              onPressed: _isLoading
                  ? () {}
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      try {
                        await context.read<AuthCubit>().logout();
                      } catch (error) {
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Kunne ikke logge ud.';
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importCalendar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppAnalytics.logEvent('dbu_webview_opened');
      final result = await context.push<String>(AppRouter.dbuWebview);
      if (!mounted) return;
      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      Map<String, dynamic> resultData;
      try {
        resultData = jsonDecode(result);
      } catch (_) {
        resultData = {'webcal': result, 'matches': []};
      }

      final webcalLink = resultData['webcal']?.toString() ?? '';
      if (webcalLink.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final httpUrl = webcalLink.replaceFirst('webcal://', 'https://');
      final response = await http.get(Uri.parse(httpUrl));
      if (response.statusCode == 200) {
        ICalendar.fromString(response.body);
        await UsersRepository.setCalendarUrl(httpUrl);
      }

      await launchUrl(
        Uri.parse(webcalLink),
        mode: LaunchMode.externalApplication,
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Der opstod en fejl under importen.';
      });
    }
  }
}
