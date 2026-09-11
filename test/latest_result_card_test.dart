import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/latest_result_card.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  testWidgets('does not show match events on the latest result card',
      (tester) async {
    final matchDate = DateTime(2026, 8, 17, 20);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeLatestResultCard(
              match: MatchDetails(
                id: 1,
                homeTeam: 'Kopa IF',
                awayTeam: 'Fremad',
                date: matchDate,
                location: 'Kopa Stadion',
                createdAt: matchDate,
                updatedAt: matchDate,
                homeTeamScore: 2,
                awayTeamScore: 1,
                matchEventDetailsList: [
                  MatchEventDetails(
                    id: 1,
                    eventId: 1,
                    type: MatchEventType.goal,
                    minute: 42,
                    teamId: 1,
                    goalscorerUserId: 1,
                    goalscorerUserName: 'Test User',
                  ),
                ],
              ),
              currentUser: _user(),
              onOpenMatch: (_) {},
              matchHeroTag: (_, source) => source,
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 - 1'), findsOneWidget);
    expect(find.text('Kamphistorik'), findsOneWidget);
    expect(find.text('Mål'), findsOneWidget);
    expect(find.text('Gule kort'), findsOneWidget);
    expect(find.text('Røde kort'), findsOneWidget);
    expect(find.textContaining('Vis alle hændelser'), findsNothing);
    expect(find.text('Test User'), findsNothing);
  });
}

UserDetails _user() {
  final now = DateTime(2026, 1, 1);
  return UserDetails(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: false,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
