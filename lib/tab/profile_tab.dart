import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
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
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

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
            child: Column(children: <Widget>[
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: appTextStyles.body.copyWith(
                        color: appColors.error, fontSize: 14),
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
                        Map<String, dynamic> resultData;
                        try {
                          resultData = jsonDecode(result);
                        } catch (e) {
                          resultData = {'webcal': result, 'matches': []};
                        }
                        
                        final String webcalLink = resultData['webcal'] ?? '';
                        final List<dynamic> scrapedMatches = resultData['matches'] ?? [];
                        final List<dynamic> scrapedPlayers = resultData['players'] ?? [];
                        if (webcalLink.isEmpty) return;

                        final uri = Uri.parse(webcalLink);
                        
                        try {
                          final httpUrl = webcalLink.replaceFirst('webcal://', 'https://');
                          final response = await http.get(Uri.parse(httpUrl));
                          if (response.statusCode == 200) {
                            final iCalendar = ICalendar.fromString(response.body);
                            final events = iCalendar.data.where((e) => e['type'] == 'VEVENT').toList();
                            
                            try {
                              await UsersRepository.setCalendarUrl(httpUrl);
                            } catch (e) {
                              print('Failed to save calendar URL to backend: $e');
                            }

                            List<Map<String, dynamic>> combinedEvents = List.from(events);
                            final now = DateTime.now();
                            
                            for (var scraped in scrapedMatches) {
                              final String scrapedDate = scraped['dtstart']?.toString() ?? '';
                              bool isFuture = false;
                              
                              if (scrapedDate.length == 16) {
                                try {
                                  final parsedDate = DateTime.parse('${scrapedDate.substring(0, 4)}-${scrapedDate.substring(4, 6)}-${scrapedDate.substring(6, 11)}:${scrapedDate.substring(11, 13)}:${scrapedDate.substring(13, 16)}').toLocal();
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
                                'location': scraped['result'] != null && scraped['result'].toString().isNotEmpty ? "Resultat: ${scraped['result']}" : '',
                              });
                            }
                            
                            combinedEvents.sort((a, b) {
                              final aDateStr = (a['dtstart'] is IcsDateTime ? (a['dtstart'] as IcsDateTime).dt : a['dtstart'].toString());
                              final bDateStr = (b['dtstart'] is IcsDateTime ? (b['dtstart'] as IcsDateTime).dt : b['dtstart'].toString());
                              return bDateStr.compareTo(aDateStr);
                            });

                            if (context.mounted && (combinedEvents.isNotEmpty || scrapedPlayers.isNotEmpty)) {
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
                                      return ScrapedMembersWidget(
                                        players: scrapedPlayers,
                                        scrollController: scrollController,
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          }
                        } catch (fetchError) {
                          print('Error fetching or parsing calendar: $fetchError');
                        }

                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!launched && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kunne ikke åbne kalenderlinket.')),
                          );
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
            ])));
  }
}

class ScrapedMatchesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> combinedEvents;
  final ScrollController? scrollController;
  
  const ScrapedMatchesWidget({super.key, required this.combinedEvents, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Fundne kampe',
            style: appTextStyles.sectionHeader,
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: combinedEvents.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final event = combinedEvents[index];
              final summary = event['summary'] ?? 'Ukendt';
              final dtstart = event['dtstart'];
              final start = dtstart is IcsDateTime ? dtstart.dt : dtstart.toString();
              final dtend = event['dtend'];
              final end = dtend is IcsDateTime ? dtend.dt : dtend?.toString() ?? '';
              final location = event['location'] ?? '';
              
              return ListTile(
                title: Text(summary.toString(), style: appTextStyles.bodyBold),
                subtitle: Text(
                  'Start: $start${end.isNotEmpty ? '\nSlut: $end' : ''}${location.isNotEmpty ? '\nLokation/Resultat: $location' : ''}',
                  style: appTextStyles.caption,
                ),
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
  }
}

class ScrapedMembersWidget extends StatelessWidget {
  final List<dynamic> players;
  final ScrollController? scrollController;
  
  const ScrapedMembersWidget({super.key, required this.players, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Fundne holdmedlemmer',
            style: appTextStyles.sectionHeader,
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: players.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final player = players[index];
              final name = player['name'] ?? 'Ukendt';
              final contact = player['contact'] ?? '';
              
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name.toString(), style: appTextStyles.bodyBold),
                subtitle: Text(contact.toString(), style: appTextStyles.caption),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FullWidthButton(
            buttonText: 'Invitier holdet til Kopa',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}