import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class CreateFineTypeModal extends StatefulWidget {
  final List<FineTypeDetails> fineTypeDetailsList;

  const CreateFineTypeModal({super.key, required this.fineTypeDetailsList});

  @override
  State<CreateFineTypeModal> createState() => _CreateFineTypeModalState();
}

class _CreateFineTypeModalState extends State<CreateFineTypeModal> {
  late TextEditingController _titleController;
  late TextEditingController _defaultAmountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _defaultAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _defaultAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
        title: 'Opret bødetype',
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
              var wasFineTypeCreated = await createFineType(context);
              if (wasFineTypeCreated && context.mounted) {
                Navigator.pop(context, wasFineTypeCreated);
              }
            },
            child: Text(
              'Opret',
              style: appTextStyles.bodyBold.copyWith(color: appColors.primary),
            ),
          ),
        ],
        body: SafeArea(
          child: Form(
              autovalidateMode: AutovalidateMode.always,
              onChanged: () {
                final context = FocusManager.instance.primaryFocus?.context;
                if (context != null) {
                  Form.maybeOf(context)?.save();
                }
              },
              child: CupertinoFormSection.insetGrouped(
                  backgroundColor: appColors.background,
                  header: const Text(''),
                  children: <Widget>[
                    CupertinoFormRow(
                      prefix: Text('Titel', style: appTextStyles.bodyBold),
                      child: CupertinoTextFormFieldRow(
                        placeholder: 'F.eks. "Kommet for sent"',
                        validator: (String? value) =>
                            validateTitleOfFineTypeInput(value),
                        keyboardType: TextInputType.name,
                        controller: _titleController,
                        maxLength: 255,
                        style: appTextStyles.body,
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: Text('Beløb', style: appTextStyles.bodyBold),
                      child: CupertinoTextFormFieldRow(
                        placeholder: 'F.eks. 100',
                        validator: (String? value) =>
                            validateDefaultAmountInput(value),
                        keyboardType: TextInputType.number,
                        controller: _defaultAmountController,
                        style: appTextStyles.body,
                      ),
                    ),
                  ])),
        ));
  }

  String? validateTitleOfFineTypeInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Indtast titel på bødetype';
    }

    return null;
  }

  String? validateDefaultAmountInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Indtast standardbeløb for bødetypen';
    }

    return null;
  }

  Future<bool> createFineType(BuildContext context) async {
    var fineTypeTitle = _titleController.text;
    var fineTypeDefaultAmount = _defaultAmountController.text;
    var doesFineTypeAlreadyExistByTitle =
        widget.fineTypeDetailsList.any((x) => x.title == fineTypeTitle);

    if (fineTypeTitle.isEmpty || fineTypeDefaultAmount.isEmpty) {
      // Show CupertinoDialog if user title or default amount is empty
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Fejl'),
          content: Text('Indtast venligst titel og standardbeløb.'),
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

      return false;
    }

    if (doesFineTypeAlreadyExistByTitle) {
      // Show CupertinoDialog if fine type already exists
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Fejl'),
          content: Text(
              'Bødetype eksisterer allerede. Indtast venligst en anden titel.'),
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

      return false;
    }

    await FinesRepository.createFineType(
      fineTypeTitle,
      fineTypeDefaultAmount,
    );

    return true;
  }
}
