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
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class _EventDraft {
  MatchEventType? type;
  int? primaryId;
  int? secondaryId;
  int? minute;

  _EventDraft();
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

class _AddMatchEventScreenState extends State<_AddMatchEventScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late FixedExtentScrollController _minuteScrollController;
  int _currentStep = 0;
  _EventDraft _draft = _EventDraft();
  final List<_EventDraft> _staged = [];
  bool _isSaving = false;
  bool _isFlyingDown = false;

  int _animatingIndex = -1;
  final GlobalKey _newItemKey = GlobalKey();

  final ScrollController _stagedScrollController = ScrollController();

  // Keys to track positions
  final GlobalKey _headerTypeKey = GlobalKey();
  final GlobalKey _headerTimeKey = GlobalKey();
  final GlobalKey _headerPrimaryKey = GlobalKey();
  final GlobalKey _headerSecondaryKey = GlobalKey();
  final GlobalKey _draftContainerKey = GlobalKey();

  final List<GlobalKey> _minuteKeys =
      List.generate(121, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
    _minuteScrollController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _minuteScrollController.dispose();
    _stagedScrollController.dispose();
    super.dispose();
  }

  void _animateSelection({
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required Widget child,
    required VoidCallback onComplete,
    Size? customSourceSize,
  }) {
    final RenderBox? sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox == null || targetBox == null) {
      onComplete();
      return;
    }

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final targetPos = targetBox.localToGlobal(Offset.zero);
    final sourceSize = customSourceSize ?? sourceBox.size;

    final controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    final scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final positionAnimation = Tween<Offset>(begin: sourcePos, end: targetPos)
        .animate(CurvedAnimation(
            parent: controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeInOutBack)));

    final OverlayEntry entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Positioned(
          left: positionAnimation.value.dx,
          top: positionAnimation.value.dy,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: SizedBox(
              width: sourceSize.width,
              height: sourceSize.height,
              child: Material(color: Colors.transparent, child: child),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    controller.forward().then((_) {
      entry.remove();
      controller.dispose();
      onComplete();
    });
  }

  void _onStepComplete(int nextStep) {
    _pageController.animateToPage(nextStep,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep = nextStep);
  }

  void _syncAndConfirm({required bool thenSave}) {
    final List<(GlobalKey, Widget)> itemsToFly = [];
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    if (_draft.type != null) {
      itemsToFly.add((
        _headerTypeKey,
        Center(
            child: Text(_getEmoji(_draft.type),
                style: const TextStyle(
                    fontSize: 24, decoration: TextDecoration.none)))
      ));
    }
    if (_draft.minute != null) {
      itemsToFly.add((
        _headerTimeKey,
        Center(
            child: Text('${_draft.minute}\'',
                style: appTextStyles.bodyBold
                    .copyWith(decoration: TextDecoration.none)))
      ));
    }
    if (_draft.primaryId != null) {
      itemsToFly.add((
        _headerPrimaryKey,
        Center(
            child: AppAvatar(
                initials: _getInitials(getUserName(_draft.primaryId)),
                radius: 15))
      ));
    }
    if (_draft.secondaryId != null) {
      itemsToFly.add((
        _headerSecondaryKey,
        Center(
            child: AppAvatar(
                initials: _getInitials(getUserName(_draft.secondaryId)),
                radius: 15))
      ));
    }

    if (itemsToFly.isEmpty) {
      setState(() {
        _staged.add(_draft);
        _draft = _EventDraft();
        _currentStep = 0;
        _pageController.jumpToPage(0);
      });
      if (thenSave) saveAll();
      return;
    }

    setState(() {
      _isFlyingDown = true;
      _staged.add(_draft);
      _animatingIndex = _staged.length - 1;
      _draft = _EventDraft();
      _currentStep = 0;
      _pageController.jumpToPage(0);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stagedScrollController.hasClients) {
        _stagedScrollController
            .jumpTo(_stagedScrollController.position.maxScrollExtent);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? targetBox =
            _newItemKey.currentContext?.findRenderObject() as RenderBox?;
        final Offset targetPos;

        if (targetBox != null) {
          targetPos =
              targetBox.localToGlobal(targetBox.size.center(Offset.zero));
        } else {
          final RenderBox? containerBox = _draftContainerKey.currentContext
              ?.findRenderObject() as RenderBox?;
          targetPos = containerBox
                  ?.localToGlobal(containerBox.size.center(Offset.zero)) ??
              Offset.zero;
        }

        _animateFlyDown(
          items: itemsToFly,
          targetPos: targetPos,
          onComplete: () {
            setState(() {
              _isFlyingDown = false;
              _animatingIndex = -1;
            });
            if (thenSave) saveAll();
          },
        );
      });
    });
  }

  void _animateFlyDown({
    required List<(GlobalKey, Widget)> items,
    required Offset targetPos,
    required VoidCallback onComplete,
  }) {
    final controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    final List<OverlayEntry> entries = [];

    for (final item in items) {
      final RenderBox? sourceBox =
          item.$1.currentContext?.findRenderObject() as RenderBox?;
      if (sourceBox == null) continue;

      final sourcePos = sourceBox.localToGlobal(Offset.zero);
      final sourceSize = sourceBox.size;

      final endPos =
          targetPos - Offset(sourceSize.width / 2, sourceSize.height / 2);

      final posAnim = Tween<Offset>(begin: sourcePos, end: endPos).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));

      final opacityAnim = TweenSequence([
        TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
        TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      final scaleAnim = TweenSequence([
        TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1), weight: 20),
        TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 0.5), weight: 80),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      entries.add(OverlayEntry(
        builder: (context) => AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Positioned(
            left: posAnim.value.dx,
            top: posAnim.value.dy,
            child: Opacity(
              opacity: opacityAnim.value,
              child: Transform.scale(
                scale: scaleAnim.value,
                child: SizedBox(
                    width: sourceSize.width,
                    height: sourceSize.height,
                    child: Material(color: Colors.transparent, child: item.$2)),
              ),
            ),
          ),
        ),
      ));
    }

    for (var entry in entries) {
      Overlay.of(context).insert(entry);
    }

    controller.forward().then((_) {
      for (var entry in entries) {
        entry.remove();
      }
      controller.dispose();
      onComplete();
    });
  }

  String getUserName(int? id) {
    if (id == null) return '';
    try {
      return widget.squad.firstWhere((u) => u.id == id).name;
    } catch (_) {
      return 'Ukendt';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '?';
    }
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
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
                minute: d.minute,
                teamId: widget.currentUserData.teamDetails!.id,
                goalscorerUserId: d.primaryId!,
                assistMakerUserId: d.secondaryId,
              ))
          .toList();

      if (commands.isEmpty) {
        setState(() => _isSaving = false);
        return;
      }

      await MatchRepository.createMatchEvents(commands);
      for (final command in commands) {
        AppAnalytics.logEvent(
          'match_event_added',
          parameters: {'event_type': command.type.name},
        );
      }
      await widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Scaffold(
      backgroundColor: appColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            CupertinoNavigationBar(
              backgroundColor: appColors.surface,
              middle:
                  Text('Tilføj begivenhed', style: appTextStyles.sectionHeader),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                    _currentStep == 0
                        ? CupertinoIcons.xmark
                        : CupertinoIcons.chevron_back,
                    color: appColors.primary),
                onPressed: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    _onStepComplete(_currentStep - 1);
                  }
                },
              ),
            ),
            _buildHeader(appTextStyles, appColors),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTypeStep(appTextStyles, appColors),
                  _buildTimeStep(appTextStyles, appColors),
                  _buildPrimaryPlayerStep(appTextStyles, appColors),
                  _buildSecondaryPlayerStep(appTextStyles, appColors),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _staged.isEmpty && !_isFlyingDown ? 0 : 90,
              key: _draftContainerKey,
              child:
                  ClipRect(child: _buildStagedDraft(appTextStyles, appColors)),
            ),
            _buildBottomTray(appColors, appTextStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppTextStyles appTextStyles, AppColors appColors) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: appColors.surface,
          border:
              Border(bottom: BorderSide(color: appColors.divider, width: 0.5))),
      child: Row(
        children: [
          _buildHeaderChip(
              _headerTypeKey,
              _draft.type != null ? _getEmoji(_draft.type) : null,
              appColors,
              appTextStyles),
          _buildHeaderChip(
              _headerTimeKey,
              _draft.minute != null ? '${_draft.minute}\'' : null,
              appColors,
              appTextStyles),
          _buildHeaderAvatarChip(
              _headerPrimaryKey,
              _draft.primaryId != null
                  ? _getInitials(getUserName(_draft.primaryId))
                  : null,
              appColors,
              appTextStyles),
          _buildHeaderAvatarChip(
              _headerSecondaryKey,
              _draft.secondaryId != null
                  ? _getInitials(getUserName(_draft.secondaryId))
                  : null,
              appColors,
              appTextStyles),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(GlobalKey key, String? value, AppColors appColors,
      AppTextStyles appTextStyles) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value != null
              ? appColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value != null
                  ? Colors.transparent
                  : appColors.divider.withValues(alpha: 0.3)),
        ),
        child: Text(value ?? '-',
            style: appTextStyles.bodyBold.copyWith(
                fontSize: 13,
                color: value != null
                    ? appColors.primary
                    : appColors.textSecondary.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _buildHeaderAvatarChip(GlobalKey key, String? initials,
      AppColors appColors, AppTextStyles appTextStyles) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        key: key,
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: initials != null
              ? appColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
              color: initials != null
                  ? Colors.transparent
                  : appColors.divider.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: initials != null
            ? AppAvatar(initials: initials, radius: 17)
            : Text('-',
                style: appTextStyles.bodyBold.copyWith(
                    color: appColors.textSecondary.withValues(alpha: 0.5))),
      ),
    );
  }

  Widget _buildTypeStep(AppTextStyles appTextStyles, AppColors appColors) {
    final types = [
      (MatchEventType.goal, 'Mål', '⚽', GlobalKey()),
      (MatchEventType.substitution, 'Udskiftning', '🔄', GlobalKey()),
      (MatchEventType.yellowCard, 'Gult kort', '🟨', GlobalKey()),
      (MatchEventType.redCard, 'Rødt kort', '🟥', GlobalKey()),
      (MatchEventType.penaltyKick, 'Straffespark', '🎯', GlobalKey()),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return GestureDetector(
          onTap: () {
            _animateSelection(
              sourceKey: type.$4,
              targetKey: _headerTypeKey,
              child: Center(
                  child: Text(type.$3,
                      style: const TextStyle(
                          fontSize: 32, decoration: TextDecoration.none))),
              onComplete: () {
                setState(() => _draft.type = type.$1);
                _onStepComplete(1);
              },
            );
          },
          child: Container(
            key: type.$4,
            decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appColors.divider, width: 2)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(type.$3, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(type.$2, style: appTextStyles.bodyBold)
            ]),
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
            onSelectedItemChanged: (index) {},
            children: List.generate(
                121,
                (index) => Center(
                    child: Text(
                        key: _minuteKeys[index],
                        "$index'",
                        style: appTextStyles.body.copyWith(fontSize: 20)))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                  child: Button(
                      buttonText: 'Overspring',
                      width: double.infinity,
                      onPressed: () {
                        setState(() => _draft.minute = null);
                        _onStepComplete(2);
                      })),
              const SizedBox(width: 12),
              Expanded(
                  child: Button(
                      buttonText: 'Næste',
                      width: double.infinity,
                      onPressed: () {
                        final selectedIndex =
                            _minuteScrollController.selectedItem;
                        _animateSelection(
                          sourceKey: _minuteKeys[selectedIndex],
                          targetKey: _headerTimeKey,
                          child: Center(
                              child: Text("$selectedIndex'",
                                  style: appTextStyles.body.copyWith(
                                      fontSize: 20,
                                      decoration: TextDecoration.none))),
                          onComplete: () {
                            setState(() => _draft.minute = selectedIndex);
                            _onStepComplete(2);
                          },
                        );
                      })),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryPlayerStep(
      AppTextStyles appTextStyles, AppColors appColors) {
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
              final itemKey = GlobalKey();
              final initials = _getInitials(user.name);
              return PlayerListItem(
                key: itemKey,
                name: user.name,
                onTap: () {
                  // Capture specific avatar position relative to the whole item
                  _animateSelection(
                    sourceKey: itemKey,
                    targetKey: _headerPrimaryKey,
                    customSourceSize: const Size(40, 40),
                    child: AppAvatar(initials: initials, radius: 20),
                    onComplete: () {
                      setState(() => _draft.primaryId = user.id);
                      if (getSecondaryLabel(_draft.type) != null) {
                        _onStepComplete(3);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryPlayerStep(
      AppTextStyles appTextStyles, AppColors appColors) {
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
              final itemKey = GlobalKey();
              final initials = _getInitials(user.name);
              return PlayerListItem(
                key: itemKey,
                name: user.name,
                onTap: () {
                  _animateSelection(
                    sourceKey: itemKey,
                    targetKey: _headerSecondaryKey,
                    customSourceSize: const Size(40, 40),
                    child: AppAvatar(initials: initials, radius: 20),
                    onComplete: () {
                      setState(() => _draft.secondaryId = user.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStagedDraft(AppTextStyles appTextStyles, AppColors appColors) {
    return Container(
      decoration: BoxDecoration(
          color: appColors.primary.withValues(alpha: 0.05),
          border:
              Border(top: BorderSide(color: appColors.divider, width: 0.5))),
      child: ListView.builder(
        controller: _stagedScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _staged.length,
        itemBuilder: (context, index) {
          final event = _staged[index];
          final isNew = index == _animatingIndex;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isNew ? 0.0 : 1.0,
            child: Container(
              key: isNew ? _newItemKey : null,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appColors.divider)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getEmoji(event.type),
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getUserName(event.primaryId),
                          style: appTextStyles.caption
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(
                          event.minute != null
                              ? '${event.minute}\''
                              : 'Ingen tid',
                          style: appTextStyles.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                      onTap: () => setState(() => _staged.removeAt(index)),
                      child: Icon(CupertinoIcons.xmark_circle_fill,
                          size: 16, color: appColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomTray(AppColors appColors, AppTextStyles appTextStyles) {
    final isSubstitution = _draft.type == MatchEventType.substitution;
    final hasRequired = _draft.type != null &&
        _draft.primaryId != null &&
        (!isSubstitution || _draft.secondaryId != null);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: appColors.surface, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4))
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (hasRequired)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _syncAndConfirm(thenSave: false),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: appColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: appColors.primary)),
                        child: Text('Tilføj flere',
                            style: TextStyle(
                                color: appColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: hasRequired
                      ? () => _syncAndConfirm(thenSave: true)
                      : null,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: hasRequired
                            ? Colors.green
                            : appColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: _isSaving
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text('Gem & Afslut',
                            style: TextStyle(
                                color: hasRequired
                                    ? Colors.white
                                    : appColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
