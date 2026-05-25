import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/create_user_fine_command.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';

class AssignFinesModal extends StatefulWidget {
  const AssignFinesModal({super.key});

  @override
  State<AssignFinesModal> createState() => _AssignFinesModalState();
}

class _AssignFinesModalState extends State<AssignFinesModal> {
  late Future<Map<String, dynamic>> fineTypesAndSquadData;
  List<Map<String, dynamic>> fineTypesExpanded = [];
  Map<int, Map<int, bool>> selectedUsers = {};
  Map<String, String> userFinePrices = {};

  @override
  void initState() {
    super.initState();
    fineTypesAndSquadData = _fetchFineTypesAndSquad();
  }

  Future<Map<String, dynamic>> _fetchFineTypesAndSquad() async {
    final squad = await UsersRepository.getSquad();
    final fineTypeDetailsList = await FinesRepository.getFineTypes();

    fineTypesExpanded = (fineTypeDetailsList as List<dynamic>).map((fine) {
      selectedUsers[fine.id] = {};
      return {
        'id': fine.id,
        'name': fine.title,
        'price': fine.defaultAmount,
        'expanded': false,
      };
    }).toList();

    return {
      'squad': squad,
      'fineTypeDetails': fineTypeDetailsList,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Tildel bøder',
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
            var wereUserFinesCreated = await addFines(context);
            if (wereUserFinesCreated && context.mounted) {
              Navigator.pop(context, wereUserFinesCreated);
            }
          },
          child: Text(
            'Opret',
            style: appTextStyles.bodyBold.copyWith(color: appColors.primary),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: FutureHandler<Map<String, dynamic>>(
            future: fineTypesAndSquadData,
            noDataFoundMessage: 'Ingen bødetyper fundet.',
            onSuccess: (context, data) {
              var squad = data['squad'] as List<UserDetails>;

              if (fineTypesExpanded.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Ingen bødetyper fundet.',
                      style: appTextStyles.sectionHeader
                          .copyWith(color: appColors.textSecondary),
                    ),
                  ),
                );
              }
              return CupertinoListSection.insetGrouped(
                backgroundColor: appColors.background,
                dividerMargin: 0,
                additionalDividerMargin: 0,
                children: fineTypesExpanded.asMap().entries.map((entry) {
                  int index = entry.key;
                  var fine = entry.value;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => toggleExpansion(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          color: appColors.surface,
                          child: Row(
                            children: [
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 300),
                                turns: fine['expanded'] ? -0.5 : 0,
                                curve: Curves.easeInOut,
                                child: Icon(CupertinoIcons.chevron_down,
                                    color: appColors.textSecondary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  fine['name'],
                                  style: appTextStyles.bodyBold,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: CupertinoTextField(
                                  placeholder: fine['price'].toString(),
                                  placeholderStyle:
                                      TextStyle(color: appColors.divider),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (value) {
                                    setState(() {
                                      fine['price'] = value;
                                    });
                                  },
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: appColors.black, width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0)),
                                  ),
                                  inputFormatters: [_FinePriceInputFormatter()],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('kr.', style: appTextStyles.body),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: fine['expanded']
                            ? Container(
                                color: appColors.surface,
                                margin: const EdgeInsets.only(
                                    top: 1, left: 0, right: 0, bottom: 0),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: squad.map((user) {
                                    return Builder(
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedUsers[fine['id']]![
                                                  user.id] = !(selectedUsers[
                                                      fine['id']]![user.id] ??
                                                  false);
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        user.name,
                                                        style:
                                                            appTextStyles.body,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                appColors.black,
                                                            width: 2),
                                                        color: selectedUsers[fine[
                                                                        'id']]![
                                                                    user.id] ==
                                                                true
                                                            ? appColors.black
                                                            : appColors.surface,
                                                      ),
                                                      child: selectedUsers[fine[
                                                                      'id']]![
                                                                  user.id] ==
                                                              true
                                                          ? Icon(
                                                              CupertinoIcons
                                                                  .checkmark,
                                                              color: appColors
                                                                  .surface,
                                                              size: 16)
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                                if (user.id !=
                                                    squad.map((x) => x.id).last)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 12.0),
                                                    child: Divider(
                                                        color:
                                                            appColors.divider,
                                                        thickness: 1,
                                                        height: 1),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  );
                }).toList(),
              );
            }),
      ),
    );
  }

  void toggleExpansion(int index) {
    setState(() {
      fineTypesExpanded[index]['expanded'] =
          !fineTypesExpanded[index]['expanded'];
    });
  }

  Future<bool> addFines(BuildContext context) async {
    List<CreateUserFineCommand> createUserFineCommand = [];
    for (var fine in fineTypesExpanded) {
      var selectedUsersIds = selectedUsers[fine['id']]!
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      for (var userId in selectedUsersIds) {
        createUserFineCommand.add(CreateUserFineCommand(
            userId: userId.toString(),
            fineTypeId: fine['id'].toString(),
            owedAmount: fine['price'].toString()));
      }
    }

    if (createUserFineCommand.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Fejl'),
          content: const Text(
              'Ingen bøder er tildelt. Vælg venligst mindst én spiller.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return false;
    }

    await FinesRepository.addFineForUsers(createUserFineCommand);
    AppAnalytics.logEvent(
      'fine_assigned',
      parameters: {'fine_count': createUserFineCommand.length},
    );
    return true;
  }
}

class _FinePriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    String formattedText = newText.replaceAll(',', '.');
    if (formattedText.isEmpty) {
      return newValue;
    }
    final regex = RegExp(r'^\d{0,4}(\.\d{0,2})?$');
    if (regex.hasMatch(formattedText)) {
      return newValue.copyWith(text: formattedText);
    }
    return oldValue;
  }
}
