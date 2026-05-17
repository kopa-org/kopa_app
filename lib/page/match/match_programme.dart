import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/future_handler.dart';
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

class MatchProgrammePage extends StatefulWidget {
  const MatchProgrammePage({super.key});

  @override
  State<MatchProgrammePage> createState() => _MatchProgrammePageState();
}

class _MatchProgrammePageState extends State<MatchProgrammePage> {
  late Future<List<MatchDetails>> matches;
  late Future<UserDetails> currentUser;

  @override
  void initState() {
    super.initState();
    matches = MatchRepository.getMatches();

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUser = Future.error(Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUser = Future.value(user);
    }
  }

  Future<void> _refreshMatches() async {
    setState(() {
      matches = MatchRepository.getMatches();
    });
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
                final data = await matches;
                if (!context.mounted) return;

                final result = await showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => CreateMatchPage(matches: data),
                );

                if (result == true) {
                  _refreshMatches();
                }
              },
              child: const Icon(CupertinoIcons.add, semanticLabel: 'Opret kamp'),
            );
          },
        ),
      ],
      body: FutureHandler<List<MatchDetails>>(
        future: matches,
        noDataFoundMessage: 'Ingen kampe fundet.',
        onSuccess: (context, data) {
          final sorted = [...data]..sort((a, b) => b.date.compareTo(a.date));

          return ListView.separated(
            padding: Spacing.screenPadding,
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: Spacing.md),
            itemBuilder: (context, index) {
              final matchDetails = sorted[index];
              return MatchHeroCard(
                match: matchDetails,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MatchDetailsPage(matchId: matchDetails.id),
                    ),
                  );
                  if (!mounted) return;
                  _refreshMatches();
                },
              );
            },
          );
        },
      ),
    );
  }
}
