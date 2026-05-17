import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class CreateMatchPage extends StatefulWidget {
  final List<MatchDetails> matches;

  const CreateMatchPage({super.key, required this.matches});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedMeetingTime;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    DateTime tempPickedDate = _selectedDate ?? DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: appColors.surface,
          child: Column(
            children: [
              CupertinoNavigationBar(
                backgroundColor: appColors.surface,
                middle: Text('Vælg dato og tid', style: appTextStyles.sectionHeader),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('Annullér', style: TextStyle(color: appColors.error)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('OK', style: TextStyle(color: appColors.primary)),
                  onPressed: () {
                    setState(() => _selectedDate = tempPickedDate);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: tempPickedDate,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) => tempPickedDate = newDate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoPageScaffold(
        backgroundColor: appColors.background,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: appColors.background,
          middle: Text('Opret kamp', style: appTextStyles.sectionHeader),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Icon(CupertinoIcons.clear, color: appColors.textPrimary),
          ),
          trailing: GestureDetector(
            onTap: () async {
              final created = await _createMatch();
              if (created && context.mounted) Navigator.pop(context, true);
            },
            child: Text('Opret', style: appTextStyles.bodyBold.copyWith(color: appColors.primary)),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 15),
          child: SafeArea(
            child: CupertinoFormSection.insetGrouped(
              backgroundColor: appColors.background,
              children: [
                _buildFormRow('Hjemmehold', _teamAController, 'Fx Sønderjyske', appTextStyles),
                _buildFormRow('Udehold', _teamBController, 'Fx AGF', appTextStyles),
                CupertinoFormRow(
                  prefix: Text('Tidspunkt', style: appTextStyles.bodyBold),
                  child: GestureDetector(
                    onTap: _pickDateTime,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Text(
                        _selectedDate != null ? DateFormat('dd.MM.yyyy - HH:mm').format(_selectedDate!) : 'Vælg dato og tid',
                        style: appTextStyles.body.copyWith(color: _selectedDate != null ? appColors.textPrimary : appColors.divider),
                      ),
                    ),
                  ),
                ),
                _buildFormRow('Lokation', _locationController, 'Fx Sydbank Park', appTextStyles),
                _buildFormRow('Noter', _noteController, 'Evt. kommentarer', appTextStyles, maxLines: 2),
              ],
            ),
          ),
        ));
  }

  Widget _buildFormRow(String label, TextEditingController ctl, String hint, AppTextStyles styles, {int maxLines = 1}) {
    return CupertinoFormRow(
      prefix: Text(label, style: styles.bodyBold),
      child: CupertinoTextFormFieldRow(
        controller: ctl,
        placeholder: hint,
        maxLines: maxLines,
        style: styles.body,
      ),
    );
  }

  Future<bool> _createMatch() async {
    final teamA = _teamAController.text.trim();
    final teamB = _teamBController.text.trim();
    final location = _locationController.text.trim();
    final notes = _noteController.text.trim();
    final date = _selectedDate;
    final meetingTime = _selectedMeetingTime;

    if (teamA.isEmpty || teamB.isEmpty || date == null) {
      await _showError('Udfyld begge hold og vælg dato.');
      return false;
    }

    if (teamA.toLowerCase() == teamB.toLowerCase()) {
      await _showError('Første og andet hold må ikke være ens.');
      return false;
    }

    // Create match
    await MatchRepository.createMatch(
      teamA,
      teamB,
      date,
      location,
      meetingTime,
      notes: notes,
    );

    return true;
  }

  Future<void> _showError(String message) async {
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text('Fejl'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }
}
