import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:share_plus/share_plus.dart';

/// Shares the team's join link through the system share sheet.
class InvitePlayersButton extends StatefulWidget {
  /// Where the invite was shared from, for analytics.
  final String source;

  const InvitePlayersButton({super.key, required this.source});

  @override
  State<InvitePlayersButton> createState() => _InvitePlayersButtonState();
}

class _InvitePlayersButtonState extends State<InvitePlayersButton> {
  bool _isSharing = false;
  String? _errorMessage;

  Future<void> _shareInvite() async {
    final l10n = AppLocalizations.of(context)!;
    final team = context.read<AuthCubit>().state.user?.teamDetails;
    if (team == null) {
      setState(() => _errorMessage = l10n.uiYouMustBeOnATeam);
      return;
    }

    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    try {
      final token =
          await context.read<OnboardingCubit>().fetchTeamJoinToken(team.id);
      if (!mounted) return;

      if (token == null) {
        setState(() {
          _isSharing = false;
          _errorMessage = l10n.uiCouldNotFetchTheInviteLink;
        });
        return;
      }

      final inviteUri = Uri.https('kopa.dk', '/join', {
        'team_token': token,
        'team_id': team.id.toString(),
        'team_title': team.title,
      });

      final shareResult = await SharePlus.instance.share(
        ShareParams(text: l10n.uiJoinOnKopa(team.title, inviteUri)),
      );
      AppAnalytics.logEvent(
        'team_invite_shared',
        parameters: {
          'source': widget.source,
          'status': shareResult.status.name,
        },
      );
      if (!mounted) return;
      setState(() => _isSharing = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSharing = false;
        _errorMessage = l10n.uiCouldNotShareKopa;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FullWidthButton(
          key: const ValueKey('invite-players'),
          buttonText:
              _isSharing ? l10n.uiFetchingLink : l10n.settingsInvitePlayers,
          icon: Icons.person_add_alt_1_rounded,
          // The design's solid brand green; the shared primary is mint.
          backgroundColor: colors.primary,
          foregroundColor: colors.white,
          loading: _isSharing,
          onPressed: _isSharing ? () {} : _shareInvite,
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: Text(
              _errorMessage!,
              style: styles.caption.copyWith(color: colors.error),
            ),
          ),
        BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            if (state.errorMessage == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                state.errorMessage!,
                style: styles.caption.copyWith(color: colors.error),
              ),
            );
          },
        ),
      ],
    );
  }
}
