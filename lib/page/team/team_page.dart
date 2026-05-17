import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/page/team/add_user_to_team_page.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late Future<List<UserDetails>> squad;

  @override
  void initState() {
    super.initState();
    squad = UsersRepository.getSquad();
  }

  Future<void> _refreshSquad() async {
    setState(() {
      squad = UsersRepository.getSquad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Truppen',
      showBackButton: true,
      backgroundColor: appColors.background,
      trailing: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final squadData = await squad;

            if (context.mounted) {
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => AddUserToTeamPage(
                  squad: squadData,
                ),
              );

              if (result == true) {
                _refreshSquad();
              }
            }
          },
          child: Icon(
            semanticLabel: 'Tilføj ny spiller',
            CupertinoIcons.add,
            color: appColors.primary,
          ),
        ),
      ],
      body: FutureHandler<List<UserDetails>>(
        future: squad,
        noDataFoundMessage: 'Ingen spillere fundet.',
        onSuccess: (context, data) {
          return SingleChildScrollView(
            child: CupertinoListSection.insetGrouped(
              backgroundColor: appColors.background,
              dividerMargin: 0,
              additionalDividerMargin: 0,
              children: data.map((player) {
                return CupertinoListTile(
                  backgroundColor: appColors.surface,
                  title: Text(
                    player.name,
                    style: appTextStyles.bodyBold,
                  ),
                  subtitle: player.isTeamOwner
                      ? Text(
                          'Holdleder',
                          style: appTextStyles.caption.copyWith(color: appColors.primary),
                        )
                      : null,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
