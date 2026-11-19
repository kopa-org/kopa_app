import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/cubits/pending_mobile_payment_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/page/team_fines/mobile_pay_paid_dialog.dart';
import 'package:kopa/utils/app_analytics.dart';

/// Asks a signed-in player whether they paid when they return from MobilePay.
///
/// Sits above the router, so it shows the question in the router's navigator
/// from [navigatorContext].
class MobilePayReturnPrompt extends StatefulWidget {
  const MobilePayReturnPrompt({
    super.key,
    required this.navigatorContext,
    required this.child,
  });

  final BuildContext? Function() navigatorContext;
  final Widget child;

  @override
  State<MobilePayReturnPrompt> createState() => _MobilePayReturnPromptState();
}

class _MobilePayReturnPromptState extends State<MobilePayReturnPrompt> {
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAsk());
  }

  Future<void> _maybeAsk() async {
    if (!mounted || _asking) return;
    final cubit = context.read<PendingMobilePaymentCubit>();
    final payment = cubit.state.payment;
    if (!cubit.state.awaitingAnswer || payment == null) return;
    if (!context.read<AuthCubit>().state.isAuthenticated) return;

    final dialogContext = widget.navigatorContext();
    if (dialogContext == null || !dialogContext.mounted) {
      // The router has not built its navigator yet.
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAsk());
      return;
    }

    _asking = true;
    try {
      final paid = await showMobilePayPaidDialog(dialogContext, payment.amount);
      AppAnalytics.logEvent(
        'fine_mobile_pay_answered',
        parameters: {'paid': paid.toString()},
      );
      if (paid) {
        await cubit.confirmPaid();
      } else {
        await cubit.declinePaid();
      }
    } finally {
      _asking = false;
    }
  }

  void _showSaveFailed() {
    final dialogContext = widget.navigatorContext();
    if (dialogContext == null || !dialogContext.mounted) return;
    ScaffoldMessenger.maybeOf(dialogContext)?.showSnackBar(SnackBar(
      content:
          Text(AppLocalizations.of(dialogContext)!.mobilePayPaidSaveFailed),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PendingMobilePaymentCubit, PendingMobilePaymentState>(
          listenWhen: (previous, current) =>
              current.awaitingAnswer && !previous.awaitingAnswer,
          listener: (_, __) => _maybeAsk(),
        ),
        BlocListener<PendingMobilePaymentCubit, PendingMobilePaymentState>(
          listenWhen: (previous, current) =>
              current.saveFailed && !previous.saveFailed,
          listener: (_, __) => _showSaveFailed(),
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.isAuthenticated && !previous.isAuthenticated,
          listener: (_, __) => _maybeAsk(),
        ),
      ],
      child: widget.child,
    );
  }
}
