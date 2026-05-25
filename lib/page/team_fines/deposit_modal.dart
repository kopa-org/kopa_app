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

  const DepositModal({super.key, required this.fineBoxId});

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
      title: 'Indbetal',
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
            'Gem',
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
                          'Mangler at blive betalt',
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
                  Text('Beløb til indbetaling', style: appTextStyles.bodyBold),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    placeholder: 'F.eks. 100',
                    controller: _depositController,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: appColors.black, width: 2),
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
                          message: 'Bødekassen',
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
          title: const Text('Fejl'),
          content: const Text('Indtast venligst et beløb større end 0 kr.'),
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
