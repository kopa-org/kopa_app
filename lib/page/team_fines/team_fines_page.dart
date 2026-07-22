import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_fine_details.dart';
import 'package:kopa/page/team_fines/assign_fines_modal.dart';
import 'package:kopa/page/team_fines/create_fine_type_modal.dart';
import 'package:kopa/page/team_fines/deposit_modal.dart';
import 'package:kopa/page/team_fines/deposit_personal_modal.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum TeamOwnerFinesSegments { overview, fineTypes, personal }

class TeamFinesPage extends StatefulWidget {
  final bool showBackButton;

  const TeamFinesPage({super.key, this.showBackButton = true});

  @override
  State<TeamFinesPage> createState() => _TeamFinesPageState();
}

class _TeamFinesPageState extends State<TeamFinesPage> {
  late Future<FineBoxDetails> fineBoxDetails;
  late Future<List<FineTypeDetails>> fineTypeDetails;
  late Future<List<UserFineDetails>> userFineDetails;
  late Future<UserDetails> currentUserData;

  TeamOwnerFinesSegments _selectedSegment = TeamOwnerFinesSegments.overview;

  @override
  void initState() {
    super.initState();
    AppAnalytics.logScreenView('team_fines');
    AppAnalytics.logEvent('fine_box_opened');
    fineBoxDetails = FinesRepository.getFineBox();
    fineTypeDetails = FinesRepository.getFineTypes();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUserData = Future.error(
          Exception('Ingen bruger fundet. Log venligst ind igen.'));
    } else {
      currentUserData = Future.value(user);
    }
  }

  Future<void> _refreshFineBox() async {
    setState(() {
      fineBoxDetails = FinesRepository.getFineBox();
    });
  }

  Future<void> _refreshFineTypes() async {
    setState(() {
      fineTypeDetails = FinesRepository.getFineTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Bødekassen',
      showBackButton: widget.showBackButton,
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<TeamOwnerFinesSegments>(
                  backgroundColor: appColors.divider,
                  thumbColor: appColors.surface,
                  groupValue: _selectedSegment,
                  onValueChanged: (TeamOwnerFinesSegments? value) {
                    if (value != null) {
                      AppAnalytics.logEvent(
                        'fine_box_segment_selected',
                        parameters: {'segment': value.name},
                      );
                      setState(() {
                        _selectedSegment = value;
                      });
                    }
                  },
                  children: <TeamOwnerFinesSegments, Widget>{
                    TeamOwnerFinesSegments.overview: Text(
                      'Overblik',
                      style: appTextStyles.caption.copyWith(
                        color: appColors.textPrimary,
                        fontWeight:
                            _selectedSegment == TeamOwnerFinesSegments.overview
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    TeamOwnerFinesSegments.fineTypes: Text(
                      'Bødetyper',
                      style: appTextStyles.caption.copyWith(
                        color: appColors.textPrimary,
                        fontWeight:
                            _selectedSegment == TeamOwnerFinesSegments.fineTypes
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    TeamOwnerFinesSegments.personal: Text(
                      'Personlig',
                      style: appTextStyles.caption.copyWith(
                        color: appColors.textPrimary,
                        fontWeight:
                            _selectedSegment == TeamOwnerFinesSegments.personal
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: getTeamFinesSegment(width, appColors, appTextStyles),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget? getTeamFinesSegment(
      double width, AppColors appColors, AppTextStyles appTextStyles) {
    return FutureHandler<FineBoxDetails>(
      future: fineBoxDetails,
      onSuccess: (context, fineBox) {
        var allUserFineDetails = fineBox.userFineDetails;

        if (_selectedSegment == TeamOwnerFinesSegments.overview) {
          return FutureHandler<UserDetails>(
              future: currentUserData,
              onSuccess: (context, user) {
                return Column(
                  children: [
                    _buildOverallBalanceSection(
                        fineBox, appColors, appTextStyles),
                    if (user.isTeamOwner)
                      _buildActionButtonsOverview(
                          fineBox, appColors, appTextStyles),
                    if (user.isTeamOwner)
                      _buildMobilePaySection(appColors, appTextStyles),
                    _buildUserFineDetailsSection(
                        allUserFineDetails, width, appColors, appTextStyles),
                  ],
                );
              });
        } else if (_selectedSegment == TeamOwnerFinesSegments.fineTypes) {
          return FutureHandler<List<FineTypeDetails>>(
            future: fineTypeDetails,
            allowEmpty: true,
            onSuccess: (context, fineTypes) {
              return Column(
                children: [
                  _buildActionButtonFineTypes(
                      fineTypes, appColors, appTextStyles),
                  _buildFineTypesSection(
                      fineTypes, width, appColors, appTextStyles),
                ],
              );
            },
          );
        } else {
          return FutureHandler<UserDetails>(
            future: currentUserData,
            onSuccess: (context, user) {
              final matches = allUserFineDetails
                  .where((u) => u.userDetails.id == user.id)
                  .toList();

              if (matches.isEmpty) {
                return _buildEmptyPersonalSection(
                    user, appColors, appTextStyles);
              }

              final userFineDetails = matches.first;

              return Column(
                children: [
                  _buildPersonalBalanceSection(
                      userFineDetails, appColors, appTextStyles),
                  _buildActionButtonsPersonal(
                    fineBox,
                    userFineDetails,
                    user,
                    appColors,
                    appTextStyles,
                  ),
                  _buildPersonalFineDetailsSection(
                      userFineDetails, width, appColors, appTextStyles),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildOverallBalanceSection(
      FineBoxDetails data, AppColors appColors, AppTextStyles appTextStyles) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCurrentBalanceText(
                data.currentAmount, appColors, appTextStyles),
            const SizedBox(height: 20),
            dividerSection(appColors),
            const SizedBox(height: 20),
            _buildBalanceRow(data, appColors, appTextStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBalanceSection(UserFineDetails userFineDetails,
      AppColors appColors, AppTextStyles appTextStyles) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPersonalBalanceText(
                userFineDetails, appColors, appTextStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBalanceText(UserFineDetails userFineDetails,
      AppColors appColors, AppTextStyles appTextStyles) {
    final amount = userFineDetails.fineDetailsList
        .where((x) => !x.hasBeenPaid)
        .fold(0, (sum, fineDetail) => sum + fineDetail.owedAmount);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$amount,-',
          style: appTextStyles.pageTitle.copyWith(color: appColors.error),
        ),
        Text(
          'Mangler du at betale',
          style: appTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCurrentBalanceText(
      double currentAmount, AppColors appColors, AppTextStyles appTextStyles) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$currentAmount,-',
          style: appTextStyles.pageTitle.copyWith(color: appColors.primary),
        ),
        Text(
          'I kassen nu',
          style: appTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(
      FineBoxDetails data, AppColors appColors, AppTextStyles appTextStyles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildBalanceColumn(data.currentAmount + data.totalOwedAmount,
              'Når alle har betalt', appColors, appTextStyles),
        ),
        verticalDividerSection(appColors),
        Expanded(
          child: _buildBalanceColumn(data.totalOwedAmount, 'Manglende beløb',
              appColors, appTextStyles),
        ),
      ],
    );
  }

  Widget _buildBalanceColumn(double amount, String label, AppColors appColors,
      AppTextStyles appTextStyles) {
    return Column(
      children: [
        Text('$amount,-', style: appTextStyles.sectionHeader),
        const SizedBox(height: 5),
        Text(label,
            textAlign: TextAlign.center,
            style: appTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtonsPersonal(
      FineBoxDetails data,
      UserFineDetails userFineDetails,
      UserDetails userDetails,
      AppColors appColors,
      AppTextStyles appTextStyles) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButtonItem('Indbetal', CupertinoIcons.arrow_up_square, appColors,
                appTextStyles, onTap: () async {
              AppAnalytics.logEvent('fine_deposit_started');
              var hasUserPaidAllFines = userFineDetails.fineDetailsList
                  .where((x) => !x.hasBeenPaid)
                  .isEmpty;

              if (hasUserPaidAllFines) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Info'),
                    content:
                        const Text('Du mangler ikke at indbetale nogle bøder.'),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                );
                return null;
              }

              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => DepositPersonalModal(
                  fineBoxId: data.id,
                  userDetails: userDetails,
                  userFineDetails: userFineDetails,
                ),
              );

              if (result != null) {
                _refreshFineBox();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsOverview(
      FineBoxDetails data, AppColors appColors, AppTextStyles appTextStyles) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButtonItem(
                'Tildel', CupertinoIcons.money_dollar, appColors, appTextStyles,
                onTap: () async {
              AppAnalytics.logEvent('fine_assign_started');
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => AssignFinesModal(),
              );
              if (result == true) {
                _refreshFineBox();
              }
            }),
            const SizedBox(width: 30),
            getButtonItem('Indbetal', CupertinoIcons.arrow_up_square, appColors,
                appTextStyles, onTap: () async {
              AppAnalytics.logEvent('fine_deposit_started');
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => DepositModal(fineBoxId: 1),
              );

              if (result != null) {
                _refreshFineBox();
              }
            }),
            const SizedBox(width: 30),
            getButtonItem('Hæv', CupertinoIcons.arrow_down_square, appColors,
                appTextStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaySection(
      AppColors appColors, AppTextStyles appTextStyles) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Betaling',
                style: appTextStyles.sectionHeader,
              ),
            ),
            const SizedBox(height: 20),
            MobilePayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalFineDetailsSection(UserFineDetails userFineDetails,
      double width, AppColors appColors, AppTextStyles appTextStyles) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: BoxDecoration(
        color: appColors.surface,
      ),
      child: userFineDetails.fineDetailsList.isEmpty
          ? const Center(child: Text('Ingen bøder tildelt endnu.'))
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text('Bødehistorik', style: appTextStyles.sectionHeader),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: DataTable(
                    horizontalMargin: 0,
                    columns: [
                      DataColumn(
                          label: SizedBox(
                              width: width * .4,
                              child: Text('Bødetype',
                                  style: appTextStyles.bodyBold))),
                      DataColumn(
                          label: SizedBox(
                              child: Text('Beløb',
                                  style: appTextStyles.bodyBold))),
                      DataColumn(
                          label: SizedBox(
                              child: Text('Betalt',
                                  style: appTextStyles.bodyBold))),
                    ],
                    rows: userFineDetails.fineDetailsList.map((fineDetail) {
                      return DataRow(
                        cells: [
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(fineDetail.fineTypeDetails.title,
                                  style: appTextStyles.body),
                              if (fineDetail.note != null &&
                                  fineDetail.note!.isNotEmpty)
                                Text(
                                  fineDetail.note!,
                                  style: appTextStyles.caption
                                      .copyWith(color: appColors.textSecondary),
                                ),
                            ],
                          )),
                          DataCell(Text('${fineDetail.owedAmount},-',
                              style: appTextStyles.body)),
                          DataCell(fineDetail.hasBeenPaid
                              ? Icon(CupertinoIcons.checkmark,
                                  color: appColors.primary, size: 16)
                              : const Text('')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyPersonalSection(
      UserDetails user, AppColors appColors, AppTextStyles appTextStyles) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Text(
              'Ingen bøder tildelt endnu.',
              style: appTextStyles.bodyBold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonFineTypes(List<FineTypeDetails> fineTypeDetails,
      AppColors appColors, AppTextStyles appTextStyles) {
    return FutureHandler<UserDetails>(
      future: currentUserData,
      onSuccess: (context, user) {
        if (!user.isTeamOwner) {
          return const SizedBox.shrink();
        } else {
          return Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    buttonText: 'Opret bødetype',
                    onPressed: () async {
                      final result = await showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        builder: (context) => CreateFineTypeModal(
                          fineTypeDetailsList: fineTypeDetails,
                        ),
                      );

                      if (result == true) {
                        _refreshFineTypes();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFineTypesSection(
    List<FineTypeDetails> fineTypeDetails,
    double width,
    AppColors appColors,
    AppTextStyles appTextStyles,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: BoxDecoration(
        color: appColors.surface,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Holdets bødetyper',
              style: appTextStyles.sectionHeader,
            ),
          ),
          const SizedBox(height: 16),
          if (fineTypeDetails.isEmpty)
            Text(
              'Ingen bødertyper endnu.',
              style: appTextStyles.caption
                  .copyWith(color: appColors.textSecondary),
            )
          else
            FractionallySizedBox(
              widthFactor: 1,
              child: DataTable(
                horizontalMargin: 0,
                columns: [
                  DataColumn(
                    label: SizedBox(
                        width: width * .4,
                        child: Text('Type', style: appTextStyles.bodyBold)),
                  ),
                  DataColumn(
                      label: SizedBox(
                          child: Text('Standardbeløb',
                              style: appTextStyles.bodyBold))),
                ],
                rows: fineTypeDetails.map((fineTypeDetail) {
                  return DataRow(
                    cells: [
                      DataCell(Text(fineTypeDetail.title,
                          style: appTextStyles.body)),
                      DataCell(Text('${fineTypeDetail.defaultAmount},-',
                          style: appTextStyles.body)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserFineDetailsSection(List<UserFineDetails> userFineDetails,
      double width, AppColors appColors, AppTextStyles appTextStyles) {
    var fineDetailsList =
        userFineDetails.map((e) => e.fineDetailsList).expand((e) => e).toList();

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: BoxDecoration(
        color: appColors.surface,
      ),
      child: userFineDetails.isEmpty && fineDetailsList.isEmpty
          ? const Center(child: Text('Ingen bøder tildelt endnu.'))
          : Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Bødeoverblik', style: appTextStyles.sectionHeader),
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: DataTable(
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: SizedBox(
                            width: width * .4,
                            child: Text('Spiller',
                                style: appTextStyles.bodyBold))),
                    DataColumn(
                        label: SizedBox(
                            child: Text('Skyldigt beløb',
                                style: appTextStyles.bodyBold,
                                textAlign: TextAlign.right))),
                  ],
                  rows: userFineDetails
                      .map((userFine) => userFine.userDetails.id)
                      .toSet()
                      .map((userId) {
                        var userFine = userFineDetails.firstWhere(
                            (userFine) => userFine.userDetails.id == userId);
                        var totalOwedAmount = userFine.fineDetailsList
                            .where((x) => !x.hasBeenPaid)
                            .fold(
                                0,
                                (sum, fineDetail) =>
                                    sum + fineDetail.owedAmount);

                        return {
                          'userName': userFine.userDetails.name,
                          'totalOwedAmount': totalOwedAmount,
                        };
                      })
                      .where(
                          (x) => int.parse(x['totalOwedAmount'].toString()) > 0)
                      .map((x) => DataRow(
                            cells: [
                              DataCell(Text(x['userName'].toString(),
                                  style: appTextStyles.body)),
                              DataCell(Text('${x['totalOwedAmount']},-',
                                  style: appTextStyles.body)),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ]),
    );
  }

  Widget getButtonItem(String buttonText, IconData buttonIcon,
      AppColors appColors, AppTextStyles appTextStyles,
      {Function()? onTap}) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 100,
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
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          children: [
            Icon(buttonIcon, color: appColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              buttonText,
              style: appTextStyles.caption.copyWith(
                  color: appColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget verticalDividerSection(AppColors appColors) {
    return SizedBox(
      height: 50,
      child: VerticalDivider(
        color: appColors.divider,
        thickness: 1,
        width: 1,
      ),
    );
  }

  Widget dividerSection(AppColors appColors) {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        color: appColors.divider,
        thickness: 1,
        height: 1,
      ),
    );
  }
}
