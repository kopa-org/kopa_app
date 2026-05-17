import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/custom_checkbox.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_fine_details.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class DepositPersonalModal extends StatefulWidget {
  final int fineBoxId;
  final UserDetails userDetails;
  final UserFineDetails userFineDetails;

  const DepositPersonalModal(
      {super.key, required this.fineBoxId,
      required this.userDetails,
      required this.userFineDetails});

  @override
  State<DepositPersonalModal> createState() => _DepositPersonalModalState();
}

class _DepositPersonalModalState extends State<DepositPersonalModal> {
  bool selectAllFines = false;
  int selectedAmountToDeposit = 0;
  List<FineDetails> fineDetailsListNotPaid = [];
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    fineDetailsListNotPaid = widget.userFineDetails.fineDetailsList
        .where((x) => !x.hasBeenPaid)
        .toList();
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedAmountToDeposit += fineDetailsListNotPaid.asMap().entries.fold(
          0,
          (sum, entry) {
            if (!selectedIndexes.contains(entry.key)) {
              return sum + entry.value.owedAmount;
            }
            return sum;
          },
        );
      } else {
        selectedAmountToDeposit = 0;
      }
      selectAllFines = value ?? false;
      selectedIndexes = selectAllFines ? fineDetailsListNotPaid.asMap().keys.toSet() : {};
    });
  }

  void toggleRowSelection(int index, bool? value) {
    setState(() {
      if (value == true) {
        selectedIndexes.add(index);
        selectedAmountToDeposit += fineDetailsListNotPaid[index].owedAmount;
      } else {
        selectedIndexes.remove(index);
        selectedAmountToDeposit -= fineDetailsListNotPaid[index].owedAmount;
      }
      selectAllFines = selectedIndexes.length == fineDetailsListNotPaid.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Indbetal',
      showBackButton: false,
      backgroundColor: appColors.background,
      leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context, false),
            child: Icon(CupertinoIcons.clear, color: appColors.textPrimary)),
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
            _buildBalanceCard(
              title: 'Mangler at blive betalt',
              amount: fineDetailsListNotPaid.fold(0, (sum, fd) => sum + fd.owedAmount).toString(),
              appColors: appColors,
              appTextStyles: appTextStyles,
            ),
            _buildBalanceCard(
              title: 'Valgt beløb til indbetaling',
              amount: selectedAmountToDeposit.toString(),
              appColors: appColors,
              appTextStyles: appTextStyles,
              isHighlighted: true,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Bødetype', style: appTextStyles.bodyBold)),
                      Text('Beløb', style: appTextStyles.bodyBold),
                      const SizedBox(width: 10),
                      CustomCheckbox(value: selectAllFines, onChanged: toggleSelectAll),
                    ],
                  ),
                  Divider(color: appColors.divider),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: fineDetailsListNotPaid.length,
                      separatorBuilder: (_, __) => Divider(color: appColors.divider),
                      itemBuilder: (context, index) {
                        var fd = fineDetailsListNotPaid[index];
                        bool isSelected = selectedIndexes.contains(index);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(fd.fineTypeDetails.title, style: appTextStyles.body)),
                            Text('${fd.owedAmount} kr', style: appTextStyles.body),
                            const SizedBox(width: 10),
                            CustomCheckbox(value: isSelected, onChanged: (val) => toggleRowSelection(index, val)),
                          ],
                        );
                      },
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
                  children: [MobilePayButton()],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard({required String title, required String amount, required AppColors appColors, required AppTextStyles appTextStyles, bool isHighlighted = false}) {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: appColors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('$amount,-', style: appTextStyles.sectionHeader.copyWith(color: isHighlighted ? appColors.primary : appColors.textPrimary)),
                const SizedBox(height: 5),
                Text(title, style: appTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ));
  }

  Future<String?> depositAmountToFineBox() async {
    if (selectedAmountToDeposit == 0) {
      // Show CupertinoDialog if user depositedAmount is empty or zero
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Fejl'),
          content: Text('Vælg venligst en bøde at indbetale.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );

      return null;
    }

    List<int> selectedFinesToBePaid = fineDetailsListNotPaid
        .asMap()
        .entries
        .where((entry) => selectedIndexes.contains(entry.key))
        .map((entry) => entry.value)
        .map((entry) => entry.id)
        .toList();

    await FinesRepository.depositAmountToFineBox(widget.fineBoxId,
        selectedAmountToDeposit.toString(), selectedFinesToBePaid);

    return selectedAmountToDeposit.toString();
  }
}
