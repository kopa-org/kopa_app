import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kopa/cubits/match_programme_cubit.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/event_type.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class CreateMatchPage extends StatefulWidget {
  final List<MatchDetails> matches;
  final KopaEventType eventType;
  final MatchDetails? initialMatch;

  const CreateMatchPage({
    super.key,
    required this.matches,
    this.eventType = KopaEventType.match,
    this.initialMatch,
  });

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedMeetingTime;
  DateTime? _repeatUntil;
  final Map<int, TimeOfDay> _repeatTimes = {};
  bool _repeatTraining = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final training = widget.initialMatch;
    if (training != null) {
      _selectedDate = training.date.toLocal();
      _locationController.text = training.location;
      _categoryController.text = training.category ?? '';
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
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
                middle: Text(l10n.eventSelectDateTime,
                    style: appTextStyles.sectionHeader),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(l10n.commonCancel,
                      style: TextStyle(color: appColors.error)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(l10n.commonOk,
                      style: TextStyle(color: appColors.primary)),
                  onPressed: () {
                    setState(() {
                      _selectedDate = tempPickedDate;
                      if (_repeatTraining && _repeatTimes.isEmpty) {
                        _repeatTimes[tempPickedDate.weekday] =
                            TimeOfDay.fromDateTime(tempPickedDate);
                      }
                      if (_repeatTraining && _repeatUntil == null) {
                        _repeatUntil = DateUtils.dateOnly(
                          tempPickedDate.add(const Duration(days: 90)),
                        );
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: tempPickedDate,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) =>
                      tempPickedDate = newDate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickTrainingTime(int weekday) async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final currentTime = _repeatTimes[weekday] ??
        TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now());
    var selectedTime = DateTime(
      2000,
      1,
      1,
      currentTime.hour,
      currentTime.minute,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 270,
        color: appColors.surface,
        child: Column(
          children: [
            CupertinoNavigationBar(
              backgroundColor: appColors.surface,
              middle: Text(_weekdayLabel(l10n, weekday),
                  style: appTextStyles.sectionHeader),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(popupContext).pop(),
                child: Text(l10n.commonCancel,
                    style: TextStyle(color: appColors.error)),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _repeatTimes[weekday] =
                        TimeOfDay.fromDateTime(selectedTime);
                  });
                  Navigator.of(popupContext).pop();
                },
                child: Text(l10n.commonOk,
                    style: TextStyle(color: appColors.primary)),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selectedTime,
                use24hFormat: true,
                onDateTimeChanged: (value) => selectedTime = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRepeatUntil() async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final startDate = DateUtils.dateOnly(_selectedDate ?? DateTime.now());
    var selectedDate = DateUtils.dateOnly(
      _repeatUntil ?? startDate.add(const Duration(days: 90)),
    );
    if (selectedDate.isBefore(startDate)) selectedDate = startDate;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 300,
        color: appColors.surface,
        child: Column(
          children: [
            CupertinoNavigationBar(
              backgroundColor: appColors.surface,
              middle: Text(l10n.eventRepeatUntil,
                  style: appTextStyles.sectionHeader),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(popupContext).pop(),
                child: Text(l10n.commonCancel,
                    style: TextStyle(color: appColors.error)),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => _repeatUntil = selectedDate);
                  Navigator.of(popupContext).pop();
                },
                child: Text(l10n.commonOk,
                    style: TextStyle(color: appColors.primary)),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumDate: startDate,
                onDateTimeChanged: (value) =>
                    selectedDate = DateUtils.dateOnly(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final isTraining = widget.eventType.isTraining;
    final isEditing = widget.initialMatch != null;

    return CupertinoPageScaffold(
        backgroundColor: appColors.background,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: appColors.background,
          middle: Text(
            isEditing
                ? l10n.eventEditTraining
                : isTraining
                    ? l10n.eventCreateTraining
                    : l10n.eventCreateMatch,
            style: appTextStyles.sectionHeader,
          ),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context, false),
            child: Icon(CupertinoIcons.clear, color: appColors.textPrimary),
          ),
          trailing: BlocBuilder<MatchProgrammeCubit, MatchProgrammeState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: state.isCreating || _isSaving
                    ? null
                    : () async {
                        final saved = await _saveEvent();
                        if (saved && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                child: state.isCreating || _isSaving
                    ? const CupertinoActivityIndicator()
                    : Text(
                        isEditing
                            ? l10n.eventSaveTraining
                            : l10n.eventCreateAction,
                        style: appTextStyles.bodyBold
                            .copyWith(color: appColors.primary),
                      ),
              );
            },
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 15, bottom: 24),
            child: CupertinoFormSection.insetGrouped(
              backgroundColor: appColors.background,
              children: [
                if (!isTraining) ...[
                  _buildFormRow('Hjemmehold', _teamAController,
                      'Fx Sønderjyske', appTextStyles),
                  _buildFormRow(
                      'Udehold', _teamBController, 'Fx AGF', appTextStyles),
                ],
                CupertinoFormRow(
                  prefix: Text(
                    isTraining ? l10n.eventTrainingTime : 'Tidspunkt',
                    style: appTextStyles.bodyBold,
                  ),
                  child: GestureDetector(
                    onTap: _pickDateTime,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('dd.MM.yyyy - HH:mm')
                                .format(_selectedDate!)
                            : l10n.eventSelectDateTime,
                        style: appTextStyles.body.copyWith(
                            color: _selectedDate != null
                                ? appColors.textPrimary
                                : appColors.divider),
                      ),
                    ),
                  ),
                ),
                _buildFormRow(
                  'Lokation',
                  _locationController,
                  isTraining
                      ? l10n.eventCreateTrainingLocationHint
                      : 'Fx Sydbank Park',
                  appTextStyles,
                ),
                if (isTraining)
                  _buildFormRow(
                    l10n.eventTrainingCategory,
                    _categoryController,
                    l10n.eventTrainingCategoryHint,
                    appTextStyles,
                  ),
                if (isTraining && !isEditing) ...[
                  CupertinoFormRow(
                    prefix: Text(l10n.eventRepeatWeekly,
                        style: appTextStyles.bodyBold),
                    child: CupertinoSwitch(
                      value: _repeatTraining,
                      onChanged: (value) {
                        setState(() {
                          _repeatTraining = value;
                          if (value &&
                              _repeatTimes.isEmpty &&
                              _selectedDate != null) {
                            _repeatTimes[_selectedDate!.weekday] =
                                TimeOfDay.fromDateTime(_selectedDate!);
                          }
                          if (value &&
                              _repeatUntil == null &&
                              _selectedDate != null) {
                            _repeatUntil = DateUtils.dateOnly(
                              _selectedDate!.add(const Duration(days: 90)),
                            );
                          }
                        });
                      },
                    ),
                  ),
                  if (_repeatTraining) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.eventRepeatWeekdays,
                          style: appTextStyles.bodyBold
                              .copyWith(color: appColors.textSecondary),
                        ),
                      ),
                    ),
                    for (var weekday = DateTime.monday;
                        weekday <= DateTime.sunday;
                        weekday++)
                      CupertinoFormRow(
                        prefix: Text(_weekdayLabel(l10n, weekday),
                            style: appTextStyles.body),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_repeatTimes.containsKey(weekday))
                              CupertinoButton(
                                padding: const EdgeInsets.only(right: 8),
                                onPressed: () => _pickTrainingTime(weekday),
                                child: Text(
                                  _formatTimeOfDay(_repeatTimes[weekday]!),
                                  style: appTextStyles.body
                                      .copyWith(color: appColors.primary),
                                ),
                              ),
                            CupertinoSwitch(
                              value: _repeatTimes.containsKey(weekday),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected) {
                                    final start =
                                        _selectedDate ?? DateTime.now();
                                    _repeatTimes[weekday] =
                                        TimeOfDay.fromDateTime(start);
                                  } else {
                                    _repeatTimes.remove(weekday);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    CupertinoFormRow(
                      prefix: Text(l10n.eventRepeatUntil,
                          style: appTextStyles.bodyBold),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _pickRepeatUntil,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Text(
                            _repeatUntil == null
                                ? l10n.eventRepeatUntilHint
                                : DateFormat('dd.MM.yyyy')
                                    .format(_repeatUntil!),
                            style: appTextStyles.body.copyWith(
                              color: _repeatUntil == null
                                  ? appColors.divider
                                  : appColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
                if (!isTraining)
                  _buildFormRow('Noter', _noteController, 'Evt. kommentarer',
                      appTextStyles,
                      maxLines: 2),
              ],
            ),
          ),
        ));
  }

  Widget _buildFormRow(String label, TextEditingController ctl, String hint,
      AppTextStyles styles,
      {int maxLines = 1}) {
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

  Future<bool> _saveEvent() async {
    final teamA = _teamAController.text.trim();
    final teamB = _teamBController.text.trim();
    final location = _locationController.text.trim();
    final category = _categoryController.text.trim();
    final notes = _noteController.text.trim();
    final date = _selectedDate;
    final meetingTime = _selectedMeetingTime;
    final l10n = AppLocalizations.of(context)!;
    final isTraining = widget.eventType.isTraining;

    if (location.isEmpty ||
        date == null ||
        (!isTraining && (teamA.isEmpty || teamB.isEmpty))) {
      await _showError(
        isTraining
            ? l10n.eventCreateTrainingMissingFields
            : 'Udfyld begge hold, lokation og vælg dato.',
      );
      return false;
    }

    if (!isTraining && teamA.toLowerCase() == teamB.toLowerCase()) {
      await _showError('Første og andet hold må ikke være ens.');
      return false;
    }

    List<DateTime>? occurrences;
    if (isTraining && _repeatTraining) {
      if (_repeatTimes.isEmpty) {
        await _showError(l10n.eventRepeatMissingWeekday);
        return false;
      }

      final repeatUntil = _repeatUntil;
      if (repeatUntil == null) {
        await _showError(l10n.eventRepeatMissingEndDate);
        return false;
      }
      if (DateUtils.dateOnly(repeatUntil).isBefore(DateUtils.dateOnly(date))) {
        await _showError(l10n.eventRepeatEndBeforeStart);
        return false;
      }

      occurrences = _buildTrainingOccurrences(date, repeatUntil);
      if (occurrences.length > 730) {
        await _showError(l10n.eventRepeatTooMany);
        return false;
      }
    }

    setState(() => _isSaving = true);
    var saved = false;
    try {
      final training = widget.initialMatch;
      if (training != null) {
        await MatchRepository.updateTraining(
          id: training.id,
          date: date,
          location: location,
          category: category.isEmpty ? null : category,
        );
        saved = true;
      } else {
        saved = await context.read<MatchProgrammeCubit>().createEvent(
              type: widget.eventType,
              homeTeam: isTraining ? null : teamA,
              awayTeam: isTraining ? null : teamB,
              date: date,
              location: location,
              meetingTime: isTraining ? null : meetingTime,
              category: isTraining ? category : null,
              notes: notes,
              occurrences: occurrences,
            );
      }
    } catch (_) {
      saved = false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!saved) {
      await _showError(
        widget.initialMatch != null
            ? l10n.eventUpdateTrainingFailed
            : isTraining
                ? l10n.eventCreateTrainingFailed
                : l10n.eventCreateMatchFailed,
      );
    }
    return saved;
  }

  List<DateTime> _buildTrainingOccurrences(DateTime start, DateTime until) {
    final occurrences = <DateTime>[];
    final lastDate = DateUtils.dateOnly(until);
    final firstDate = DateUtils.dateOnly(start);
    for (var offset = 0;; offset++) {
      final day =
          DateTime(firstDate.year, firstDate.month, firstDate.day + offset);
      if (day.isAfter(lastDate)) break;
      final time = _repeatTimes[day.weekday];
      if (time != null) {
        occurrences.add(DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ));
      }
    }
    return occurrences;
  }

  String _weekdayLabel(AppLocalizations l10n, int weekday) => switch (weekday) {
        DateTime.monday => l10n.eventWeekdayMonday,
        DateTime.tuesday => l10n.eventWeekdayTuesday,
        DateTime.wednesday => l10n.eventWeekdayWednesday,
        DateTime.thursday => l10n.eventWeekdayThursday,
        DateTime.friday => l10n.eventWeekdayFriday,
        DateTime.saturday => l10n.eventWeekdaySaturday,
        DateTime.sunday => l10n.eventWeekdaySunday,
        _ => '',
      };

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

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
