import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kopa/utils/app_analytics.dart';

class ProfileTabOld extends StatefulWidget {
  const ProfileTabOld({super.key});

  @override
  State<ProfileTabOld> createState() => _ProfileTabOldState();
}

class _ProfileTabOldState extends State<ProfileTabOld> {
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

    Future<void> logout() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await context.read<AuthCubit>().logout();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Brugeren kunne ikke logges ud: ${e.toString()}';
          });
        }
      }
    }

    return PageScaffold(
      title: 'Profil',
      showBackButton: false,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          children: <Widget>[
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  _errorMessage!,
                  style: appTextStyles.body
                      .copyWith(color: appColors.error, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!_isLoading) ...[
              FullWidthButton(
                buttonText: 'Importér kampprogram',
                onPressed: () async {
                  AppAnalytics.logEvent('dbu_webview_opened');
                  final result =
                      await context.push<String>(AppRouter.dbuWebview);
                  if (result != null && context.mounted) {
                    try {
                      Map<String, dynamic> resultData;
                      try {
                        resultData = jsonDecode(result);
                      } catch (e) {
                        resultData = {'webcal': result, 'matches': []};
                      }

                      final String webcalLink = resultData['webcal'] ?? '';
                      final List<dynamic> scrapedMatches =
                          resultData['matches'] ?? [];
                      final List<dynamic> scrapedPlayers =
                          resultData['players'] ?? [];
                      if (webcalLink.isEmpty) return;

                      final uri = Uri.parse(webcalLink);

                      try {
                        final httpUrl =
                            webcalLink.replaceFirst('webcal://', 'https://');
                        final response = await http.get(Uri.parse(httpUrl));
                        if (response.statusCode == 200) {
                          final iCalendar = ICalendar.fromString(response.body);
                          final events = iCalendar.data
                              .where((e) => e['type'] == 'VEVENT')
                              .toList();

                          try {
                            await UsersRepository.setCalendarUrl(httpUrl);
                          } catch (e) {
                            print('Failed to save calendar URL to backend: $e');
                          }
                          AppAnalytics.logEvent(
                            'dbu_calendar_import_success',
                            parameters: {
                              'match_count': scrapedMatches.length,
                              'player_count': scrapedPlayers.length,
                            },
                          );

                          List<Map<String, dynamic>> combinedEvents =
                              List.from(events);
                          final now = DateTime.now();

                          for (var scraped in scrapedMatches) {
                            final String scrapedDate =
                                scraped['dtstart']?.toString() ?? '';
                            bool isFuture = false;

                            if (scrapedDate.length == 16) {
                              try {
                                final parsedDate = DateTime.parse(
                                        '${scrapedDate.substring(0, 4)}-${scrapedDate.substring(4, 6)}-${scrapedDate.substring(6, 11)}:${scrapedDate.substring(11, 13)}:${scrapedDate.substring(13, 16)}')
                                    .toLocal();
                                if (parsedDate.isAfter(now)) {
                                  isFuture = true;
                                }
                              } catch (_) {}
                            }

                            if (isFuture) continue;

                            combinedEvents.add({
                              'summary': scraped['summary'],
                              'dtstart': scraped['dtstart'],
                              'dtend': '',
                              'location': scraped['result'] != null &&
                                      scraped['result'].toString().isNotEmpty
                                  ? "Resultat: ${scraped['result']}"
                                  : '',
                            });
                          }

                          combinedEvents.sort((a, b) {
                            final aDateStr = (a['dtstart'] is IcsDateTime
                                ? (a['dtstart'] as IcsDateTime).dt
                                : a['dtstart'].toString());
                            final bDateStr = (b['dtstart'] is IcsDateTime
                                ? (b['dtstart'] as IcsDateTime).dt
                                : b['dtstart'].toString());
                            return bDateStr.compareTo(aDateStr);
                          });
                        }
                      } catch (fetchError) {
                        AppAnalytics.logEvent('dbu_calendar_import_failure');
                        print(
                            'Error fetching or parsing calendar: $fetchError');
                      }

                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kunne ikke åbne kalenderlinket.'),
                          ),
                        );
                      }
                    } catch (e) {
                      AppAnalytics.logEvent('dbu_calendar_import_failure');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Der skete en fejl ved åbning af linket.',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Onboarding Test (ADMIN)',
                  style: appTextStyles.sectionHeader,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Test Email Invite',
                  border: OutlineInputBorder(),
                  hintText: 'indtast email',
                ),
              ),
              const SizedBox(height: 8),
              FullWidthButton(
                buttonText: 'Send Test Email',
                onPressed: () async {
                  if (_emailController.text.isEmpty) return;
                  final teamId = currentUser?.teamDetails?.id ?? 0;
                  final onboardingCubit = context.read<OnboardingCubit>();
                  await onboardingCubit.sendEmailInvites(
                    teamId,
                    [_emailController.text.trim()],
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invite sent to ${_emailController.text}'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  if (state.errorMessage != null) {
                    return Text(
                      state.errorMessage!,
                      style: appTextStyles.caption
                          .copyWith(color: appColors.error),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
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
              FullWidthButton(
                buttonText: 'Log ud',
                onPressed: logout,
              ),
            ] else ...[
              const LoadingIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
