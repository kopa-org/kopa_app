import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/page/match_polls/match_polls_page.dart';
import 'package:kopa/page/team/team_page.dart';
import 'package:kopa/page/team_fines/team_fines_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;

    return PageScaffold(
      title: 'Home',
      showBackButton: false,
      backgroundColor: appColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 400,
                      height: 140,
                      child: _buildDashboardCard(
                        context: context,
                        title: 'Kampens spiller',
                        icon: Icons.star_rounded,
                        color: appColors.sky,
                        onTap: () {
                          Navigator.of(context).push(MaterialWithModalsPageRoute(
                              builder: (context) => MatchPollsListPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400,
                      height: 140,
                      child: _buildDashboardCard(
                        context: context,
                        title: 'Truppen',
                        icon: Icons.groups_rounded,
                        color: appColors.sunset,
                        onTap: () {
                          Navigator.of(context).push(MaterialWithModalsPageRoute(
                              builder: (context) => TeamPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400,
                      height: 140,
                      child: _buildDashboardCard(
                        context: context,
                        title: 'Bødekassen',
                        icon: Icons.account_balance_wallet_rounded,
                        color: appColors.grass,
                        onTap: () {
                          Navigator.of(context).push(MaterialWithModalsPageRoute(
                              builder: (context) => TeamFinesPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Text(
                title,
                style: appTextStyles.bodyBold.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}