import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:kopa/repository/users_repository.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> logout() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await context.read<AuthCubit>().logout();
        // GoRouter will automatically handle the redirection due to the refreshListenable and redirect rules in AppRouter.
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Brugeren kunne ikke logges ud: ${e.toString()}';
          });
        }
      }
    }

    return SizedBox(
        height: double.infinity,
        child: CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGrey6,
            child: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Column(children: <Widget>[
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                                color: theme.colorScheme.error, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!_isLoading) ...[
                        FullWidthButton(
                          buttonText: 'Importér kampprogram',
                          onPressed: () async {
                            final result = await context.push<String>(AppRouter.dbuWebview);
                            if (result != null && context.mounted) {
                              try {
                                final uri = Uri.parse(result);
                                
                                // 1. Fetch and print the calendar data
                                try {
                                  final httpUrl = result.replaceFirst('webcal://', 'https://');
                                  final response = await http.get(Uri.parse(httpUrl));
                                  if (response.statusCode == 200) {
                                    final iCalendar = ICalendar.fromString(response.body);
                                    final events = iCalendar.data.where((e) => e['type'] == 'VEVENT').toList();
                                    
                                    // Send to backend
                                    try {
                                      await UsersRepository.setCalendarUrl(httpUrl);
                                    } catch (e) {
                                      print('Failed to save calendar URL to backend: $e');
                                    }

                                    if (context.mounted && events.isNotEmpty) {
                                      await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        builder: (context) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            initialChildSize: 0.8,
                                            minChildSize: 0.5,
                                            maxChildSize: 0.95,
                                            builder: (context, scrollController) {
                                              return Column(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: Text(
                                                      'Fundne kampe',
                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView.separated(
                                                      controller: scrollController,
                                                      itemCount: events.length,
                                                      separatorBuilder: (context, index) => const Divider(),
                                                      itemBuilder: (context, index) {
                                                        final event = events[index];
                                                        final summary = event['summary'] ?? 'Ukendt';
                                                        final start = (event['dtstart'] as IcsDateTime?)?.dt ?? '';
                                                        final end = (event['dtend'] as IcsDateTime?)?.dt ?? '';
                                                        final location = event['location'] ?? '';
                                                        
                                                        return ListTile(
                                                          title: Text(summary.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                                          subtitle: Text('Start: $start\\nSlut: $end\\nLokation: $location'),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: FullWidthButton(
                                                      buttonText: 'Fortsæt til kalender',
                                                      onPressed: () => Navigator.of(context).pop(),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    print('Failed to fetch calendar data: HTTP \${response.statusCode}');
                                  }
                                } catch (fetchError) {
                                  print('Error fetching or parsing calendar: \$fetchError');
                                }

                                // 2. Launch the native calendar app
                                final launched = await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                                if (!launched) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kunne ikke åbne kalenderlinket. Har du en kalender-app installeret?')),
                                    );
                                  }
                                }
                              } on PlatformException catch (e) {
                                // Fallback: Android often doesn't natively handle webcal:// intents. 
                                // We fallback to https:// which will open the browser and trigger an .ics download/subscription.
                                try {
                                  final fallbackUri = Uri.parse(result.replaceFirst('webcal://', 'https://'));
                                  final fallbackLaunched = await launchUrl(
                                    fallbackUri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!fallbackLaunched) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ingen kalender-app fundet på enheden.')),
                                      );
                                    }
                                  }
                                } catch (fallbackError) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kunne ikke åbne kalenderlinket.')),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Der skete en fejl ved åbning af linket.')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        FullWidthButton(
                          buttonText: 'Log ud',
                          onPressed: logout,
                        ),
                      ] else
                        const LoadingIndicator(),
                    ])))));
  }
}
