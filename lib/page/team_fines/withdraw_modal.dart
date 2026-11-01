import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';

/// Records money taken out of the fine box, e.g. for the season party.
/// Pops with true once the withdrawal is saved.
class WithdrawModal extends StatefulWidget {
  final double currentAmount;
  final Future<void> Function(int amount, {String? note}) withdraw;

  const WithdrawModal({
    super.key,
    required this.currentAmount,
    this.withdraw = FinesRepository.withdrawFromFineBox,
  });

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = int.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      setState(() => _error = l10n.fineBoxWithdrawInvalidAmount);
      return;
    }
    if (amount > widget.currentAmount) {
      setState(() => _error = l10n.fineBoxWithdrawTooMuch);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final note = _noteController.text.trim();
      await widget.withdraw(amount, note: note.isEmpty ? null : note);
      AppAnalytics.logEvent('fine_withdraw_completed');
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = error is InsufficientFundsException
            ? l10n.fineBoxWithdrawTooMuch
            : l10n.fineBoxWithdrawFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    final fieldDecoration = BoxDecoration(
      color: appColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: appColors.divider),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.fineBoxWithdrawTitle,
              style: appTextStyles.h5.copyWith(
                color: appColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.fineBoxWithdrawIntro(widget.currentAmount.round()),
              style: appTextStyles.body3.copyWith(
                color: appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              key: const ValueKey('withdraw-amount'),
              controller: _amountController,
              enabled: !_isSaving,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              placeholder: l10n.fineBoxWithdrawAmountHint,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text('kr.', style: appTextStyles.bodyBold),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: fieldDecoration,
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              key: const ValueKey('withdraw-note'),
              controller: _noteController,
              enabled: !_isSaving,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              placeholder: l10n.fineBoxWithdrawNoteHint,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: fieldDecoration,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: appTextStyles.caption2.copyWith(
                  color: appColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Button(
              key: const ValueKey('withdraw-save'),
              icon: _isSaving
                  ? CupertinoIcons.hourglass
                  : CupertinoIcons.arrow_up_circle,
              buttonText: l10n.fineBoxWithdrawSave,
              loading: _isSaving,
              width: double.infinity,
              backgroundColor: appColors.primary,
              foregroundColor: appColors.surface,
              onPressed: _isSaving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }
}
