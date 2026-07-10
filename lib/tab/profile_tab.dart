import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/profile/player_profile_page.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<List<UserDetails>> _squadFuture;

  @override
  void initState() {
    super.initState();
    _squadFuture = UsersRepository.getSquad();
  }

  Future<void> _refresh() async {
    setState(() {
      _squadFuture = UsersRepository.getSquad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold.tab(
      title: 'Profil',
      backgroundColor: appColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureHandler<List<UserDetails>>(
          future: _squadFuture,
          noDataFoundMessage: 'Ingen spillere fundet.',
          onSuccess: (context, squad) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                Text(
                  'Truppen',
                  style: appTextStyles.pageTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Alle spillere på holdet. Tryk på en spiller for at se profil, kampe og bøder.',
                  style: appTextStyles.body.copyWith(
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: appColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: List.generate(squad.length, (index) {
                      final player = squad[index];
                      return Column(
                        children: [
                          PlayerListItem(
                            name: player.name,
                            subtitle: player.position ??
                                (player.isTeamOwner ? 'Holdleder' : 'Spiller'),
                            trailing:
                                const Icon(CupertinoIcons.chevron_forward),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlayerProfilePage(player: player),
                                ),
                              );
                            },
                          ),
                          if (index < squad.length - 1)
                            Divider(
                              height: 1,
                              color: appColors.divider,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
