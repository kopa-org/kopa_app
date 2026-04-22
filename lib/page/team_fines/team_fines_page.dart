import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/future_handler.dart';
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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum TeamOwnerFinesSegments { overview, fineTypes, personal }

class TeamFinesPage extends StatefulWidget {
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

    // Load fine data
    fineBoxDetails = FinesRepository.getFineBox();
    fineTypeDetails = FinesRepository.getFineTypes();

    // Load logged in user via AuthCubit
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUserData = Future.error(Exception('Ingen bruger fundet. Log venligst ind igen.'));
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

    return SizedBox(
      height: double.infinity,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGrey6,
        navigationBar: _buildNavigationBar(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<
                        TeamOwnerFinesSegments>(
                      backgroundColor: CupertinoColors.systemGrey2,
                      groupValue: _selectedSegment,
                      onValueChanged: (TeamOwnerFinesSegments? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSegment = value;
                          });
                        }
                      },
                      children: const <TeamOwnerFinesSegments, Widget>{
                        TeamOwnerFinesSegments.overview: Text(
                          'Overblik',
                          style: TextStyle(
                              color: CupertinoColors.black, fontSize: 13),
                        ),
                        TeamOwnerFinesSegments.fineTypes: Text(
                          'Bødetyper',
                          style: TextStyle(
                              color: CupertinoColors.black, fontSize: 13),
                        ),
                        TeamOwnerFinesSegments.personal: Text(
                          'Personlig',
                          style: TextStyle(
                              color: CupertinoColors.black, fontSize: 13),
                        ),
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: getTeamFinesSegment(width),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? getTeamFinesSegment(double width) {
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
                    _buildOverallBalanceSection(fineBox),
                    if (user.isTeamOwner) _buildActionButtonsOverview(fineBox),
                    if (user.isTeamOwner) _buildMobilePaySection(),
                    _buildUserFineDetailsSection(allUserFineDetails, width),
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
                  _buildActionButtonFineTypes(fineTypes),
                  _buildFineTypesSection(fineTypes, width),
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
                // Ingen bøder for den nuværende bruger endnu
                return _buildEmptyPersonalSection(user);
              }

              final userFineDetails = matches.first;

              return Column(
                children: [
                  _buildPersonalBalanceSection(userFineDetails),
                  _buildActionButtonsPersonal(
                    fineBox,
                    userFineDetails,
                    user,
                  ),
                  _buildPersonalFineDetailsSection(userFineDetails, width),
                ],
              );
            },
          );
        }
      },
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context)
            .popUntil((route) => route.settings.name == '/'),
        child: Icon(CupertinoIcons.chevron_left, semanticLabel: 'Tilbage'),
      ),
      middle: Text('Bødekassen'),
    );
  }

  Widget _buildOverallBalanceSection(FineBoxDetails data) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCurrentBalanceText(data.currentAmount),
            SizedBox(height: 20),
            dividerSection(),
            SizedBox(height: 20),
            _buildBalanceRow(data),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBalanceSection(UserFineDetails userFineDetails) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPersonalBalanceText(userFineDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBalanceText(UserFineDetails userFineDetails) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          userFineDetails.fineDetailsList
              .where((x) => !x.hasBeenPaid)
              .fold(0, (sum, fineDetail) => sum + fineDetail.owedAmount)
              .toString(),
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(
          'Mangler du at betale',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCurrentBalanceText(double currentAmount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentAmount.toString(),
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(
          'I kassen nu',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(FineBoxDetails data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildBalanceColumn(
              data.currentAmount + data.totalOwedAmount, 'Når alle har betalt'),
        ),
        verticalDividerSection(),
        Expanded(
          child: _buildBalanceColumn(data.totalOwedAmount, 'Manglende beløb'),
        ),
      ],
    );
  }

  Widget _buildBalanceColumn(double amount, String label) {
    return Column(
      children: [
        Text(amount.toString(), style: TextStyle(fontSize: 24)),
        SizedBox(height: 5),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButtonsPersonal(FineBoxDetails data,
      UserFineDetails userFineDetails, UserDetails userDetails) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButtonItem('Indbetal', CupertinoIcons.arrow_up_square,
                onTap: () async {
              var hasUserPaidAllFines = userFineDetails.fineDetailsList
                  .where((x) => !x.hasBeenPaid)
                  .isEmpty;

              if (hasUserPaidAllFines) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Info'),
                    content: Text('Du mangler ikke at indbetale nogle bøder.'),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'),
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

  Widget _buildActionButtonsOverview(FineBoxDetails data) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getButtonItem('Tildel', CupertinoIcons.money_dollar,
                onTap: () async {
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => AssignFinesModal(),
              );
              if (result == true) {
                _refreshFineBox();
              }
            }),
            SizedBox(width: 30),
            getButtonItem('Indbetal', CupertinoIcons.arrow_up_square,
                onTap: () async {
              final result = await showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                builder: (context) => DepositModal(fineBoxId: 1),
              );

              if (result != null) {
                _refreshFineBox();
              }
            }),
            SizedBox(width: 30),
            getButtonItem('Hæv', CupertinoIcons.arrow_down_square),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Betaling',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            MobilePayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalFineDetailsSection(
      UserFineDetails userFineDetails, double width) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
      ),
      child: userFineDetails.fineDetailsList.isEmpty
          ? Center(child: Text('Ingen bøder tildelt endnu.'))
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Bødehistorik',
                      style: TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: DataTable(
                    horizontalMargin: 0,
                    columns: [
                      DataColumn(
                          label: SizedBox(
                              width: width * .4, child: Text('Bødetype'))),
                      DataColumn(label: SizedBox(child: Text('Beløb'))),
                      DataColumn(label: SizedBox(child: Text('Betalt'))),
                    ],
                    rows: userFineDetails.fineDetailsList.map((fineDetail) {
                      return DataRow(
                        cells: [
                          DataCell(Text(fineDetail.fineTypeDetails.title)),
                          DataCell(Text('${fineDetail.owedAmount},-')),
                          DataCell(fineDetail.hasBeenPaid
                              ? Icon(CupertinoIcons.checkmark,
                                  color: CupertinoColors.black, size: 16)
                              : Text('')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyPersonalSection(UserDetails user) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: const [
            Text(
              'Ingen bøder tildelt endnu.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonFineTypes(List<FineTypeDetails> fineTypeDetails) {
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Holdets bødetyper',
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (fineTypeDetails.isEmpty)
            const Text(
              'Ingen bødertyper endnu.',
              style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
            )
          else
            FractionallySizedBox(
              widthFactor: 1,
              child: DataTable(
                horizontalMargin: 0,
                columns: [
                  DataColumn(
                    label: SizedBox(width: width * .4, child: Text('Type')),
                  ),
                  DataColumn(label: SizedBox(child: Text('Standardbeløb'))),
                ],
                rows: fineTypeDetails.map((fineTypeDetail) {
                  return DataRow(
                    cells: [
                      DataCell(Text(fineTypeDetail.title)),
                      DataCell(Text('${fineTypeDetail.defaultAmount},-')),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserFineDetailsSection(
      List<UserFineDetails> userFineDetails, double width) {
    var fineDetailsList =
        userFineDetails.map((e) => e.fineDetailsList).expand((e) => e).toList();

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
      ),
      child: userFineDetails.isEmpty && fineDetailsList.isEmpty
          ? Center(child: Text('Ingen bøder tildelt endnu.'))
          : Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Bødeoverblik',
                    style: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: DataTable(
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: SizedBox(
                            width: width * .4, child: Text('Spiller'))),
                    DataColumn(
                        label: SizedBox(
                            child: Text('Skyldigt beløb',
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
                              DataCell(Text(x['userName'].toString())),
                              DataCell(Text('${x['totalOwedAmount']},-')),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ]),
    );
  }

  Widget getButtonItem(String buttonText, IconData buttonIcon,
      {Function()? onTap}) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 100,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          children: [
            Icon(buttonIcon, color: CupertinoColors.black, size: 24),
            SizedBox(height: 8),
            Text(
              buttonText,
              style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget verticalDividerSection() {
    return SizedBox(
      height: 50,
      child: VerticalDivider(
        color: CupertinoColors.systemGrey3,
        thickness: 1,
        width: 1,
      ),
    );
  }

  Widget dividerSection() {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        color: CupertinoColors.systemGrey3,
        thickness: 1,
        height: 1,
      ),
    );
  }
}
