import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/page/match/create_match_page.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';

class MatchProgrammePage extends StatefulWidget {
  const MatchProgrammePage({super.key});

  @override
  State<MatchProgrammePage> createState() => _MatchProgrammePageState();
}

class _MatchProgrammePageState extends State<MatchProgrammePage> {
  List<MatchDetails>? _matches;
  Object? _matchesError;
  late Future<UserDetails> currentUser;

  @override
  void initState() {
    super.initState();
    _loadMatches();

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(
          Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
  }

  Future<void> _loadMatches() async {
    try {
      final nextMatches = await MatchRepository.getMatches();
      if (!mounted) return;
      setState(() {
        _matches = nextMatches;
        _matchesError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _matchesError = error;
      });
    }
  }

  Future<void> _refreshMatches() async {
    await _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Kampprogram',
      trailing: [
        FutureHandler<UserDetails>(
          future: currentUser,
          loadingIndicator: const SizedBox.shrink(),
          onError: (_) => const SizedBox.shrink(),
          onSuccess: (context, user) {
            if (!user.isTeamOwner) return const SizedBox.shrink();

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final data = _matches ?? await MatchRepository.getMatches();
                if (!context.mounted) return;

                final result = await showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => CreateMatchPage(matches: data),
                );

                if (result == true) {
                  await _refreshMatches();
                }
              },
              child:
                  const Icon(CupertinoIcons.add, semanticLabel: 'Opret kamp'),
            );
          },
        ),
      ],
      body: _buildMatchList(),
    );
  }

  Widget _buildMatchList() {
    if (_matchesError != null && _matches == null) {
      return const ErrorMessage(
        message: 'Der skete en fejl. Prøv venligst igen senere.',
      );
    }

    final matches = _matches;
    if (matches == null) {
      return const LoadingIndicator();
    }

    if (matches.isEmpty) {
      return const Center(child: Text('Ingen kampe fundet.'));
    }

    final sorted = [...matches]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: Spacing.screenPadding,
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const SizedBox(height: Spacing.md),
      itemBuilder: (context, index) {
        final matchDetails = sorted[index];
        return MatchHeroCard(
          match: matchDetails,
          onTap: () async {
            AppAnalytics.logEvent(
              'match_opened',
              parameters: {'source': 'match_programme'},
            );
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MatchDetailsPage(
                  matchId: matchDetails.id,
                  initialMatch: matchDetails,
                ),
              ),
            );
            if (!mounted) return;
            await Future<void>.delayed(
              const Duration(milliseconds: 350),
            );
            if (!mounted) return;
            _refreshMatches();
          },
        );
      },
    );
  }
}
