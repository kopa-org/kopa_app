import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class _EventDraft {
  MatchEventType? type;
  int? primaryId;
  int? secondaryId;
  int? minute;

  _EventDraft({
    this.type,
    this.primaryId,
    this.secondaryId,
    this.minute,
  });

  _EventDraft copyWith({
    MatchEventType? type,
    int? primaryId,
    int? secondaryId,
    int? minute,
  }) {
    return _EventDraft(
      type: type ?? this.type,
      primaryId: primaryId ?? this.primaryId,
      secondaryId: secondaryId ?? this.secondaryId,
      minute: minute ?? this.minute,
    );
  }
}

Future<void> showAddMatchEventModal(
  BuildContext context,
  int matchId,
  List<UserDetails> squad,
  UserDetails currentUserData,
  Future<void> Function() onSaved,
) async {
  await showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    enableDrag: false,
    builder: (modalContext) => _AddMatchEventScreen(
      matchId: matchId,
      squad: squad,
      currentUserData: currentUserData,
      onSaved: onSaved,
    ),
  );
}

class _AddMatchEventScreen extends StatefulWidget {
  final int matchId;
  final List<UserDetails> squad;
  final UserDetails currentUserData;
  final Future<void> Function() onSaved;

  const _AddMatchEventScreen({
    required this.matchId,
    required this.squad,
    required this.currentUserData,
    required this.onSaved,
  });

  @override
  State<_AddMatchEventScreen> createState() => _AddMatchEventScreenState();
}

class _AddMatchEventScreenState extends State<_AddMatchEventScreen> {
  late PageController _pageController;
  late FixedExtentScrollController _minuteScrollController;
  int _currentStep = 0;
  _EventDraft _draft = _EventDraft();
  final List<_EventDraft> _staged = [];
  bool _isSaving = false;

  final ScrollController _stagedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
    _minuteScrollController = FixedExtentScrollController(initialItem: _draft.minute ?? 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _minuteScrollController.dispose();
    _stagedScrollController.dispose();
    super.dispose();
  }

  String getUserName(int? id) {
    if (id == null) return '';
    try {
      return widget.squad.firstWhere((u) => u.id == id).name;
    } catch (_) {
      return 'Ukendt';
    }
  }

  String _getTypeName(MatchEventType? type) {
    if (type == null) return '?';
    switch (type) {
      case MatchEventType.goal:
        return 'Mål';
      case MatchEventType.substitution:
        return 'Udskiftning';
      case MatchEventType.yellowCard:
        return 'Gult kort';
      case MatchEventType.redCard:
        return 'Rødt kort';
      case MatchEventType.penaltyKick:
        return 'Straffespark';
    }
  }

  String _getEmoji(MatchEventType? type) {
    if (type == null) return '❓';
    switch (type) {
      case MatchEventType.goal:
        return '⚽';
      case MatchEventType.substitution:
        return '🔄';
      case MatchEventType.yellowCard:
        return '🟨';
      case MatchEventType.redCard:
        return '🟥';
      case MatchEventType.penaltyKick:
        return '🎯';
    }
  }

  String getPrimaryLabel(MatchEventType? type) {
    if (type == null) return 'Spiller';
    switch (type) {
      case MatchEventType.goal:
        return 'Målscorer';
      case MatchEventType.substitution:
        return 'Spiller ind';
      case MatchEventType.penaltyKick:
        return 'Skytte';
      case MatchEventType.yellowCard:
      case MatchEventType.redCard:
        return 'Spiller';
    }
  }

  String? getSecondaryLabel(MatchEventType? type) {
    if (type == null) return null;
    switch (type) {
      case MatchEventType.goal:
        return 'Assist';
      case MatchEventType.substitution:
        return 'Spiller ud';
      default:
        return null;
    }
  }

  Future<void> saveAll() async {
    if (_staged.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final commands = _staged
          .where((d) => d.primaryId != null && d.type != null)
          .map((d) => CreateMatchEventCommand(
                eventId: widget.matchId,
                type: d.type!,
                minute: d.minute ?? 0,
                teamId: widget.currentUserData.teamDetails.id,
                goalscorerUserId: d.primaryId!,
                assistMakerUserId: d.secondaryId,
              ))
          .toList();

      if (commands.isEmpty) {
        setState(() => _isSaving = false);
        return;
      }

      await MatchRepository.createMatchEvents(commands);
      await widget.onSaved();
      if (mounted) {
        // Pop main modal
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildProgressTrack(AppTextStyles appTextStyles, AppColors appColors) {
    final secondaryLabel = getSecondaryLabel(_draft.type);
    final steps = [
      (0, 'Type', '${_getEmoji(_draft.type)} ${_getTypeName(_draft.type)}'),
      (1, 'Tid', "${_draft.minute ?? 0}'"),
      (2, getPrimaryLabel(_draft.type), getUserName(_draft.primaryId)),
      if (secondaryLabel != null) (3, secondaryLabel, getUserName(_draft.secondaryId)),
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appColors.divider, width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final stepIndex = step.$1;
          final label = step.$2;
          final value = step.$3;
          final isActive = _currentStep == stepIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                _pageController.animateToPage(stepIndex,
                    duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                setState(() => _currentStep = stepIndex);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? appColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? appColors.primary : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: appTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: isActive ? appColors.primary : appColors.textSecondary,
                      ),
                    ),
                    Text(
                      value.isEmpty ? 'Vælg...' : value,
                      style: appTextStyles.bodyBold.copyWith(
                        fontSize: 13,
                        color: isActive ? appColors.primary : appColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Gennemse begivenheder', style: appTextStyles.sectionHeader),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _staged.length,
                          itemBuilder: (context, index) {
                            final event = _staged[index];
                            return ListTile(
                              leading:
                                  Text(_getEmoji(event.type), style: const TextStyle(fontSize: 24)),
                              title: Text("${_getTypeName(event.type)} - ${event.minute}'"),
                              subtitle: Text(
                                  "${getUserName(event.primaryId)}${event.secondaryId != null ? ' (${getUserName(event.secondaryId)})' : ''}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _staged.removeAt(index);
                                  });
                                  setModalState(() {});
                                  if (_staged.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Button(
                          buttonText: _isSaving ? 'Gemmer...' : 'Gem alt (${_staged.length})',
                          width: double.infinity,
                          onPressed: () async {
                            setModalState(() => _isSaving = true);
                            await saveAll();
                          },
                          enabled: !_isSaving && _staged.isNotEmpty,
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
      },
    );
  }

  Widget _buildBottomTray(AppTextStyles appTextStyles, AppColors appColors) {
    final isSubstitution = _draft.type == MatchEventType.substitution;
    final canAdd = _draft.type != null &&
        _draft.primaryId != null &&
        _draft.minute != null &&
        (!isSubstitution || _draft.secondaryId != null);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: appColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_staged.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_staged.length} begivenheder i kø',
                    style: appTextStyles.bodyBold,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showReviewSheet(context),
                    child: Text('Gennemse',
                        style: TextStyle(color: appColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Button(
                  buttonText: 'Tilføj',
                  width: double.infinity,
                  onPressed: () {
                    if (canAdd) {
                      setState(() {
                        _staged.add(_draft);
                        _draft = _EventDraft(); // Reset completely
                        _minuteScrollController.jumpToItem(0);
                        _currentStep = 0;
                        _pageController.jumpToPage(0);
                      });
                    }
                  },
                  enabled: canAdd,
                ),
              ),
              if (_staged.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Button(
                    buttonText: _isSaving ? 'Gemmer...' : 'Gem alt',
                    width: double.infinity,
                    onPressed: saveAll,
                    enabled: !_isSaving,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    if (_staged.isEmpty) return true;

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Kassér ændringer?'),
        content: Text('Du har ${_staged.length} begivenheder i køen, som ikke er blevet gemt endnu.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Fortsæt redigering'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kassér'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Material(
        color: appColors.surface,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              CupertinoNavigationBar(
                backgroundColor: appColors.surface,
                middle: Text('Tilføj begivenhed', style: appTextStyles.sectionHeader),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.chevron_back, color: appColors.primary),
                  onPressed: () async {
                    if (await _confirmDiscard()) {
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ),

              _buildProgressTrack(appTextStyles, appColors),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildTypeStep(appTextStyles, appColors),
                    _buildTimeStep(appTextStyles, appColors),
                    _buildPrimaryPlayerStep(appTextStyles, appColors),
                    _buildSecondaryPlayerStep(appTextStyles, appColors),
                  ],
                ),
              ),

              _buildBottomTray(appTextStyles, appColors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeStep(AppTextStyles appTextStyles, AppColors appColors) {
    final types = [
      (MatchEventType.goal, 'Mål', '⚽'),
      (MatchEventType.substitution, 'Udskiftning', '🔄'),
      (MatchEventType.yellowCard, 'Gult kort', '🟨'),
      (MatchEventType.redCard, 'Rødt kort', '🟥'),
      (MatchEventType.penaltyKick, 'Straffespark', '🎯'),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _draft.type == type.$1;

        return GestureDetector(
          onTap: () {
            setState(() {
              _draft.type = type.$1;
            });
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? appColors.primary.withValues(alpha: 0.05) : appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? appColors.primary : appColors.divider,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.$3,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  type.$2,
                  style: appTextStyles.bodyBold.copyWith(
                    color: isSelected ? appColors.primary : appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeStep(AppTextStyles appTextStyles, AppColors appColors) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text('Vælg minut', style: appTextStyles.sectionHeader),
        const SizedBox(height: 8),
        Expanded(
          child: CupertinoPicker(
            scrollController: _minuteScrollController,
            itemExtent: 48.0,
            onSelectedItemChanged: (index) {
              setState(() {
                _draft.minute = index;
              });
            },
            children: List.generate(
              121,
              (index) => Center(
                child: Text(
                  "$index'",
                  style: appTextStyles.body.copyWith(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Button(
            buttonText: 'Næste',
            width: double.infinity,
            onPressed: () {
              if (_draft.minute == null) {
                setState(() => _draft.minute = 0);
              }
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryPlayerStep(AppTextStyles appTextStyles, AppColors appColors) {
    final label = getPrimaryLabel(_draft.type);
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(label, style: appTextStyles.sectionHeader),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: widget.squad.length,
            itemBuilder: (context, index) {
              final user = widget.squad[index];
              final isSelected = _draft.primaryId == user.id;

              return PlayerListItem(
                name: user.name,
                trailing: isSelected ? Icon(Icons.check_circle, color: appColors.primary) : null,
                onTap: () {
                  setState(() {
                    _draft.primaryId = user.id;
                  });
                  if (getSecondaryLabel(_draft.type) != null) {
                    _pageController.animateToPage(
                      3,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryPlayerStep(AppTextStyles appTextStyles, AppColors appColors) {
    final label = getSecondaryLabel(_draft.type);
    if (label == null) return const SizedBox.shrink();

    final filteredSquad = _draft.type == MatchEventType.substitution
        ? widget.squad.where((u) => u.id != _draft.primaryId).toList()
        : widget.squad;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(label, style: appTextStyles.sectionHeader),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSquad.length,
            itemBuilder: (context, index) {
              final user = filteredSquad[index];
              final isSelected = _draft.secondaryId == user.id;

              return PlayerListItem(
                name: user.name,
                trailing: isSelected ? Icon(Icons.check_circle, color: appColors.primary) : null,
                onTap: () {
                  setState(() {
                    _draft.secondaryId = user.id;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
