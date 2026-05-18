import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class _EventDraft {
  MatchEventType type;
  int? primaryId;
  int? secondaryId;
  int? minute;

  _EventDraft({
    this.type = MatchEventType.goal,
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
  await showCupertinoModalPopup(
    context: context,
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
  int _currentStep = 0;
  _EventDraft _draft = _EventDraft();
  final List<_EventDraft> _staged = [];
  bool _isSaving = false;

  final ScrollController _stagedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  String getPrimaryLabel(MatchEventType type) {
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

  String? getSecondaryLabel(MatchEventType type) {
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
          .where((d) => d.primaryId != null)
          .map((d) => CreateMatchEventCommand(
                eventId: widget.matchId,
                type: d.type,
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
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: appColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              CupertinoNavigationBar(
                backgroundColor: appColors.surface,
                middle: Text('Tilføj begivenhed', style: appTextStyles.sectionHeader),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.chevron_back, color: appColors.primary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Top navigation/progress area (placeholder)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = index == _currentStep;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? appColors.primary : appColors.divider,
                      ),
                    );
                  }),
                ),
              ),

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

              // Bottom area (placeholder for staged events count and add button)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_staged.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${_staged.length} begivenheder i kø',
                          style: appTextStyles.caption.copyWith(color: appColors.textSecondary),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Button(
                            buttonText: 'Tilføj til liste',
                            width: double.infinity,
                            onPressed: () {
                              // Placeholder logic for now
                              if (_draft.primaryId != null && _draft.minute != null) {
                                setState(() {
                                  _staged.add(_draft);
                                  _draft = _EventDraft(type: _draft.type);
                                  _currentStep = 0;
                                  _pageController.jumpToPage(0);
                                });
                              }
                            },
                            enabled: _draft.primaryId != null && _draft.minute != null,
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
              ),
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
              color: isSelected ? appColors.primary.withOpacity(0.05) : appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? appColors.primary : appColors.divider,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
    return Center(child: Text('Step 1: Vælg Tidspunkt', style: appTextStyles.body));
  }

  Widget _buildPrimaryPlayerStep(AppTextStyles appTextStyles, AppColors appColors) {
    return Center(child: Text('Step 2: Vælg Primær Spiller', style: appTextStyles.body));
  }

  Widget _buildSecondaryPlayerStep(AppTextStyles appTextStyles, AppColors appColors) {
    return Center(child: Text('Step 3: Vælg Sekundær Spiller', style: appTextStyles.body));
  }
}
