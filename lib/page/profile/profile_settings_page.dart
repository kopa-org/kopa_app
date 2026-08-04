import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/profile/dbu_calendar_import_flow.dart';
import 'package:kopa/page/profile/dbu_webview_page.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:share_plus/share_plus.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _isLoading = false;
  bool _isSharingKopa = false;
  bool _isResendingInvites = false;
  DbuWebviewOperation? _activeDbuSync;
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
      title: 'Settings',
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
              buttonText: _isSharingKopa ? 'Henter link...' : 'Del Kopa',
              onPressed: _isSharingKopa ? () {} : _shareKopa,
            ),
            const SizedBox(height: 24),
            Text('Holdværktøjer', style: appTextStyles.sectionHeader),
            const SizedBox(height: 12),
            if (currentUser?.isTeamOwner == true) ...[
              FullWidthButton(
                buttonText: _activeDbuSync == DbuWebviewOperation.standings
                    ? 'Synkroniserer stilling...'
                    : 'Synkroniser stilling fra DBU',
                onPressed: _activeDbuSync == null ? _syncDbu : () {},
              ),
              const SizedBox(height: 16),
              FullWidthButton(
                buttonText: _isResendingInvites
                    ? 'Sender invitationer...'
                    : 'Send invitationer igen',
                onPressed: _isResendingInvites ? () {} : _resendPendingInvites,
              ),
              const SizedBox(height: 16),
            ],
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
                  [
                    {'email': _emailController.text.trim()}
                  ],
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
      final currentUser = context.read<AuthCubit>().state.user;
      final message = await DbuCalendarImportFlow.run(
        context,
        teamId: currentUser?.teamDetails?.id,
      );

      if (!mounted) return;
      if (message != null) {
        context.read<MatchProgrammeRefreshNotifier>().notifyImported();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _shareKopa() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final team = currentUser?.teamDetails;
    if (team == null) {
      setState(
          () => _errorMessage = 'Du skal være på et hold for at dele Kopa.');
      return;
    }

    setState(() {
      _isSharingKopa = true;
      _errorMessage = null;
    });

    try {
      final token =
          await context.read<OnboardingCubit>().fetchTeamJoinToken(team.id);
      if (!mounted) return;

      if (token == null) {
        setState(() {
          _isSharingKopa = false;
          _errorMessage = 'Kunne ikke hente invitationslink.';
        });
        return;
      }

      final inviteUri = Uri.https(
        'app.kopa.dk',
        '/join',
        {
          'team_token': token,
          'team_id': team.id.toString(),
          'team_title': team.title,
        },
      );

      await SharePlus.instance.share(
        ShareParams(
          text: 'Join ${team.title} på Kopa: $inviteUri',
        ),
      );
      if (!mounted) return;
      setState(() => _isSharingKopa = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSharingKopa = false;
        _errorMessage = 'Kunne ikke dele Kopa.';
      });
    }
  }

  Future<void> _resendPendingInvites() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final teamId = currentUser?.teamDetails?.id;
    if (currentUser?.isTeamOwner != true || teamId == null) {
      return;
    }

    setState(() {
      _isResendingInvites = true;
      _errorMessage = null;
    });

    try {
      final result =
          await context.read<OnboardingCubit>().resendPendingInvites(teamId);
      if (!mounted) return;

      if (result['error'] != null) {
        setState(() {
          _isResendingInvites = false;
          _errorMessage = result['error'] as String;
        });
        return;
      }

      final sent = (result['sent'] as List<dynamic>? ?? []).length;
      final failed = (result['failed'] as List<dynamic>? ?? []).length;
      final message = failed == 0
          ? 'Invitationer sendt igen ($sent).'
          : 'Invitationer sendt: $sent. Fejlede: $failed.';

      setState(() => _isResendingInvites = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResendingInvites = false;
        _errorMessage = 'Kunne ikke sende invitationer igen.';
      });
    }
  }

  Future<void> _syncDbu() async {
    const operation = DbuWebviewOperation.standings;
    final currentUser = context.read<AuthCubit>().state.user;
    final teamId = currentUser?.teamDetails?.id;
    if (currentUser?.isTeamOwner != true || teamId == null) {
      return;
    }

    setState(() {
      _activeDbuSync = operation;
      _errorMessage = null;
    });

    try {
      AppAnalytics.logEvent(
        'dbu_pool_sync_started',
        parameters: {'operation': operation.wireValue},
      );
      final result = await context.push<String>(
        AppRouter.dbuWebview,
        extra: operation,
      );
      if (!mounted) return;

      if (result == null) {
        setState(() => _activeDbuSync = null);
        return;
      }

      final scrapedData = jsonDecode(result) as Map<String, dynamic>;
      final scraperError = scrapedData['error']?.toString();
      if (scraperError != null && scraperError.isNotEmpty) {
        throw Exception(scraperError);
      }

      await TeamDbuRepository.syncStandings(
        teamId: teamId,
        scrapedData: scrapedData,
      );

      if (!mounted) return;
      final count = (scrapedData['standings'] as List<dynamic>? ?? []).length;
      final label = 'Stilling og puljehold er synkroniseret ($count hold).';

      AppAnalytics.logEvent(
        'dbu_pool_sync_completed',
        parameters: {
          'operation': operation.wireValue,
          'row_count': count,
        },
      );
      setState(() => _activeDbuSync = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label)),
      );
    } catch (error) {
      AppAnalytics.logEvent(
        'dbu_pool_sync_failed',
        parameters: {'operation': operation.wireValue},
      );
      if (!mounted) return;
      setState(() {
        _activeDbuSync = null;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }
}
