import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/error_message.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/loading_indicator.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/match_programme_cubit.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/create_match_page.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MatchProgrammePage extends StatefulWidget {
  const MatchProgrammePage({super.key});

  @override
  State<MatchProgrammePage> createState() => _MatchProgrammePageState();
}

class _MatchProgrammePageState extends State<MatchProgrammePage> {
  late Future<UserDetails> currentUser;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(
          Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MatchProgrammeCubit()..loadMatches(),
      child: PageScaffold(
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
                onPressed: () => _showCreateMatch(context),
                child: const Icon(
                  CupertinoIcons.add,
                  semanticLabel: 'Opret kamp',
                ),
              );
            },
          ),
        ],
        body: const _MatchList(),
      ),
    );
  }

  Future<void> _showCreateMatch(BuildContext context) async {
    final cubit = context.read<MatchProgrammeCubit>();
    await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (modalContext) => BlocProvider.value(
        value: cubit,
        child: CreateMatchPage(matches: cubit.state.matches),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchProgrammeCubit, MatchProgrammeState>(
      builder: (context, state) {
        if (state.status == MatchProgrammeStatus.failure) {
          return const ErrorMessage(
            message: 'Der skete en fejl. Prøv venligst igen senere.',
          );
        }

        if (state.isLoading) {
          return const LoadingIndicator();
        }

        return _buildMatchList(context, state.matches);
      },
    );
  }

  Widget _buildMatchList(BuildContext context, List<MatchDetails> matches) {
    if (matches.isEmpty) {
      return const Center(child: Text('Ingen kampe fundet.'));
    }

    return ListView(
      padding: Spacing.screenPadding,
      children: [
        AllGamesCard(
          matches: matches,
          onMatchTap: (match) => _openMatch(context, match),
        ),
      ],
    );
  }

  Future<void> _openMatch(
    BuildContext context,
    MatchDetails matchDetails,
  ) async {
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
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (context.mounted) {
      context.read<MatchProgrammeCubit>().loadMatches(showLoading: false);
    }
  }
}
