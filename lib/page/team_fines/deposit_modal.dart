import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';

class DepositModal extends StatefulWidget {
  final int fineBoxId;
  final String? mobilePayBoxId;

  const DepositModal(
      {super.key, required this.fineBoxId, required this.mobilePayBoxId});

  @override
  State<DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends State<DepositModal> {
  late TextEditingController _depositController;

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController();
    _depositController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: AppLocalizations.of(context)!.fineBoxDeposit,
      showBackButton: false,
      backgroundColor: appColors.background,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pop(context, false),
        child: Icon(CupertinoIcons.clear, color: appColors.textPrimary),
      ),
      trailing: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            var depositedAmount = await depositAmountToFineBox();
            if (depositedAmount != null && context.mounted) {
              Navigator.pop(context, depositedAmount);
            }
          },
          child: Text(
            AppLocalizations.of(context)!.matchTasksSave,
            style: appTextStyles.bodyBold.copyWith(color: appColors.primary),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                        color: appColors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('123', style: appTextStyles.sectionHeader),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)!.uiStillToBePaid,
                          style: appTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  ],
                )),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                      color: appColors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.uiAmountToDeposit,
                      style: appTextStyles.bodyBold),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: AppLocalizations.of(context)!.uiEG100,
                    controller: _depositController,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        MobilePayButton(
                          amount: int.tryParse(_depositController.text),
                          message: AppLocalizations.of(context)!.fineBoxTitle,
                          mobilePayBoxId: widget.mobilePayBoxId,
                        ),
                      ],
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future<String?> depositAmountToFineBox() async {
    var depositedAmount = _depositController.text;
    if (depositedAmount.isEmpty || depositedAmount == '0') {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context)!.matchPollErrorTitle),
          content: Text(
              AppLocalizations.of(context)!.uiPleaseEnterAnAmountGreaterThan),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return null;
    }
    await FinesRepository.depositAmountToFineBox(
        widget.fineBoxId, depositedAmount, []);
    AppAnalytics.logEvent('fine_deposit_completed');
    return depositedAmount;
  }
}
