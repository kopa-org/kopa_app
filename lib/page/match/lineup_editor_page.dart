import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/football_pitch.dart';
import 'package:kopa/component/card/player_positions_card.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/crash_reporting.dart';

class LineupEditorPage extends StatefulWidget {
  final MatchDetails match;
  final int playerCount;

  const LineupEditorPage({
    super.key,
    required this.match,
    required this.playerCount,
  });

  @override
  State<LineupEditorPage> createState() => _LineupEditorPageState();
}

class _LineupEditorPageState extends State<LineupEditorPage> {
  late String _formationLabel;
  late PlayerFormation _formation;
  late List<_LineupPlayer?> _starters;
  late List<_LineupPlayer> _bench;
  bool _saving = false;
  bool _showDragHint = false;
  String? _draggingName;

  @override
  void initState() {
    super.initState();
    _formationLabel = widget.match.formation;
    _formation = PlayerFormation.fromString(
      _formationLabel,
      playerCount: widget.playerCount,
    );
    _syncInitialPlayers();
    _loadDragHintPreference();
  }

  Future<void> _loadDragHintPreference() async {
    final hasSeenHint = await SecureStorageService.hasSeenLineupDragHint();
    if (!mounted || hasSeenHint) return;
    setState(() => _showDragHint = true);
  }

  void _syncInitialPlayers() {
    final attending = (widget.match.attendanceDetailsList ?? [])
        .where((attendance) => attendance.isAttending)
        .map(_LineupPlayer.fromAttendance)
        .toList();
    final anySelected = attending.any((player) => player.selected);
    final players = anySelected
        ? attending
        : attending.map((player) => player.copyWith(selected: true)).toList();

    _starters = List<_LineupPlayer?>.filled(_formation.slots.length, null);

    for (final player in players) {
      final slot = player.attendance.lineupSlot;
      if (slot != null && slot >= 0 && slot < _starters.length) {
        _starters[slot] = player.copyWith(selected: true);
      }
    }

    final placedIds = _starters
        .whereType<_LineupPlayer>()
        .map((player) => player.user.id)
        .toSet();
    final selectedPool = players.where((player) => player.selected).toList();
    var nextPoolIndex = 0;

    for (var slot = 0; slot < _starters.length; slot++) {
      if (_starters[slot] != null) continue;

      while (nextPoolIndex < selectedPool.length &&
          placedIds.contains(selectedPool[nextPoolIndex].user.id)) {
        nextPoolIndex++;
      }

      if (nextPoolIndex >= selectedPool.length) break;
      final player = selectedPool[nextPoolIndex].copyWith(selected: true);
      _starters[slot] = player;
      placedIds.add(player.user.id);
    }

    _bench =
        players.where((player) => !placedIds.contains(player.user.id)).toList()
          ..sort((a, b) {
            if (a.selected != b.selected) return a.selected ? -1 : 1;
            return a.user.name.compareTo(b.user.name);
          });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _EditorHeader(
              colors: colors,
              styles: styles,
              saving: _saving,
              onClose: () => Navigator.of(context).pop(false),
              onSave: _save,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _LineupCard(
                    colors: colors,
                    styles: styles,
                    formation: _formation,
                    formationLabel: _formation.label,
                    starters: _starters,
                    draggingName: _draggingName,
                    showDragHint: _showDragHint,
                    onDragStarted: (player) {
                      _handleDragStarted(player);
                    },
                    onDragEnd: _handleDragEnded,
                    onSlotAccept: _moveToSlot,
                    onSlotTap: _pickPlayerForSlot,
                    onEditFormation: _showFormationSheet,
                  ),
                  const SizedBox(height: 16),
                  _BenchSection(
                    colors: colors,
                    styles: styles,
                    bench: _bench,
                    onDragStarted: (player) {
                      _handleDragStarted(player);
                    },
                    onDragEnd: _handleDragEnded,
                    onBenchAccept: _moveToBench,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragStarted(_LineupPlayer player) {
    setState(() => _draggingName = player.user.name);
  }

  void _handleDragEnded() {
    if (!mounted) return;
    setState(() => _draggingName = null);
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    final lineup = <Map<String, dynamic>>[];
    for (var slot = 0; slot < _starters.length; slot++) {
      final player = _starters[slot];
      if (player == null) continue;
      lineup.add({'user_id': player.user.id, 'lineup_slot': slot});
    }
    for (final player in _bench.where((player) => player.selected)) {
      lineup.add({'user_id': player.user.id, 'lineup_slot': null});
    }

    try {
      final updatedMatch = await MatchRepository.updateMatchLineup(
        widget.match.id,
        _formation.label,
        lineup,
      );
      if (_showDragHint) {
        await SecureStorageService.setLineupDragHintSeen();
      }
      if (mounted) Navigator.of(context).pop(updatedMatch);
    } catch (error, stack) {
      CrashReporting.logWebError(error, stack);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunne ikke gemme holdopstillingen. Prøv igen.'),
        ),
      );
    }
  }

  void _moveToSlot(_LineupDragData data, int targetSlot) {
    setState(() {
      final dragged = _takeDraggedPlayer(data)?.copyWith(selected: true);
      if (dragged == null) return;

      final displaced = _starters[targetSlot];
      _starters[targetSlot] = dragged;
      if (displaced != null && displaced.user.id != dragged.user.id) {
        _bench.add(displaced.copyWith(selected: true));
      }
      _sortBench();
      _draggingName = null;
    });
  }

  void _moveToBench(_LineupDragData data) {
    setState(() {
      final dragged = _takeDraggedPlayer(data)?.copyWith(selected: true);
      if (dragged == null) return;
      _bench.add(dragged);
      _sortBench();
      _draggingName = null;
    });
  }

  _LineupPlayer? _takeDraggedPlayer(_LineupDragData data) {
    if (data.fromSlot != null) {
      final slot = data.fromSlot!;
      if (slot < 0 || slot >= _starters.length) return null;
      final player = _starters[slot];
      _starters[slot] = null;
      return player;
    }

    final index =
        _bench.indexWhere((player) => player.user.id == data.player.user.id);
    if (index == -1) return data.player;
    return _bench.removeAt(index);
  }

  Future<void> _pickPlayerForSlot(int slot) async {
    if (_bench.isEmpty) return;

    final selected = await showCupertinoModalPopup<_LineupPlayer>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Vælg spiller'),
        actions: _bench
            .map(
              (player) => CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(player),
                child: Text(player.user.name),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annullér'),
        ),
      ),
    );

    if (selected == null) return;
    _moveToSlot(_LineupDragData(player: selected), slot);
  }

  Future<void> _showFormationSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FormationSheet(
        currentFormation: _formation.label,
        formations: _suggestedFormations(widget.playerCount),
      ),
    );

    if (selected == null || selected == _formation.label) return;

    setState(() {
      final existing = [
        ..._starters.whereType<_LineupPlayer>(),
        ..._bench,
      ];
      _formationLabel = selected;
      _formation = PlayerFormation.fromString(
        _formationLabel,
        playerCount: widget.playerCount,
      );
      _starters = List<_LineupPlayer?>.filled(_formation.slots.length, null);
      for (var i = 0; i < _starters.length && i < existing.length; i++) {
        _starters[i] = existing[i].copyWith(selected: true);
      }
      _bench = existing.skip(_starters.length).toList();
      _sortBench();
    });
  }

  List<String> _suggestedFormations(int playerCount) {
    if (playerCount == 11) {
      return const ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1'];
    }

    return const ['2-3-1', '3-2-1', '2-2-2', '3-1-2'];
  }

  void _sortBench() {
    _bench.sort((a, b) {
      if (a.selected != b.selected) return a.selected ? -1 : 1;
      return a.user.name.compareTo(b.user.name);
    });
  }
}

class _EditorHeader extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles styles;
  final bool saving;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const _EditorHeader({
    required this.colors,
    required this.styles,
    required this.saving,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: saving ? null : onClose,
            child: Icon(
              isIOS ? CupertinoIcons.back : Icons.arrow_back,
              color: colors.dirt,
            ),
          ),
          Expanded(
            child: Text(
              'Rediger Holdopstilling',
              textAlign: TextAlign.center,
              style: styles.h5.copyWith(fontSize: 20),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 29),
            borderRadius: BorderRadius.circular(12),
            color: colors.primary,
            onPressed: saving ? null : onSave,
            child: saving
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    'Gem',
                    style: styles.caption2.copyWith(
                      color: colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LineupCard extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles styles;
  final PlayerFormation formation;
  final String formationLabel;
  final List<_LineupPlayer?> starters;
  final String? draggingName;
  final bool showDragHint;
  final ValueChanged<_LineupPlayer> onDragStarted;
  final VoidCallback onDragEnd;
  final void Function(_LineupDragData data, int slot) onSlotAccept;
  final ValueChanged<int> onSlotTap;
  final VoidCallback onEditFormation;

  const _LineupCard({
    required this.colors,
    required this.styles,
    required this.formation,
    required this.formationLabel,
    required this.starters,
    required this.draggingName,
    required this.showDragHint,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onSlotAccept,
    required this.onSlotTap,
    required this.onEditFormation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showDragHint) ...[
            _LineupDragHint(colors: colors, styles: styles),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 340,
            child: FootballPitch(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  for (var i = 0; i < formation.slots.length; i++)
                    _LineupSlotTarget(
                      slotIndex: i,
                      slot: formation.slots[i],
                      player: i < starters.length ? starters[i] : null,
                      colors: colors,
                      styles: styles,
                      onAccept: (data) => onSlotAccept(data, i),
                      onTap: () => onSlotTap(i),
                      onDragStarted: onDragStarted,
                      onDragEnd: onDragEnd,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (draggingName == null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 33),
              borderRadius: BorderRadius.circular(100),
              color: colors.background,
              onPressed: onEditFormation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rediger formation ($formationLabel)',
                    style: styles.body4.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(CupertinoIcons.pencil, size: 14, color: colors.primary),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF105230),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Flyt spiller: Slip for at placere $draggingName',
                textAlign: TextAlign.center,
                style: styles.caption2.copyWith(
                  color: colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LineupSlotTarget extends StatelessWidget {
  final int slotIndex;
  final FormationSlot slot;
  final _LineupPlayer? player;
  final AppColors colors;
  final AppTextStyles styles;
  final ValueChanged<_LineupDragData> onAccept;
  final VoidCallback onTap;
  final ValueChanged<_LineupPlayer> onDragStarted;
  final VoidCallback onDragEnd;

  const _LineupSlotTarget({
    required this.slotIndex,
    required this.slot,
    required this.player,
    required this.colors,
    required this.styles,
    required this.onAccept,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(slot.x * 2 - 1, slot.y * 2 - 1),
        child: DragTarget<_LineupDragData>(
          onAcceptWithDetails: (details) => onAccept(details.data),
          builder: (context, candidateData, rejectedData) {
            final highlighted = candidateData.isNotEmpty;
            final content = player == null
                ? _EmptySlotBadge(
                    label: slot.fallbackLabel,
                    highlighted: highlighted,
                    styles: styles,
                  )
                : _DraggablePlayerBadge(
                    player: player!,
                    label: slot.fallbackLabel,
                    fromSlot: slotIndex,
                    colors: colors,
                    styles: styles,
                    onDragStarted: onDragStarted,
                    onDragEnd: onDragEnd,
                  );

            return GestureDetector(onTap: onTap, child: content);
          },
        ),
      ),
    );
  }
}

class _BenchSection extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles styles;
  final List<_LineupPlayer> bench;
  final ValueChanged<_LineupPlayer> onDragStarted;
  final VoidCallback onDragEnd;
  final ValueChanged<_LineupDragData> onBenchAccept;

  const _BenchSection({
    required this.colors,
    required this.styles,
    required this.bench,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onBenchAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_LineupDragData>(
      onAcceptWithDetails: (details) => onBenchAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bænken (${bench.where((player) => player.selected).length} spillere)',
              style: styles.subtitle2.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (bench.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: colors.divider.withValues(alpha: 0.4)),
                ),
                child: Text('Ingen spillere på bænken', style: styles.body3),
              )
            else
              SizedBox(
                height: 98,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: bench.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final player = bench[index];
                    return _BenchPlayerCard(
                      player: player,
                      colors: colors,
                      styles: styles,
                      onDragStarted: onDragStarted,
                      onDragEnd: onDragEnd,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DraggablePlayerBadge extends StatelessWidget {
  final _LineupPlayer player;
  final String label;
  final int? fromSlot;
  final AppColors colors;
  final AppTextStyles styles;
  final ValueChanged<_LineupPlayer> onDragStarted;
  final VoidCallback onDragEnd;

  const _DraggablePlayerBadge({
    required this.player,
    required this.label,
    required this.fromSlot,
    required this.colors,
    required this.styles,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _PlayerBadge(
      name: player.user.name,
      label: label,
      colors: colors,
      styles: styles,
    );

    return LongPressDraggable<_LineupDragData>(
      data: _LineupDragData(player: player, fromSlot: fromSlot),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.05, child: badge),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: badge),
      onDragStarted: () => onDragStarted(player),
      onDragEnd: (_) => onDragEnd(),
      onDraggableCanceled: (_, __) => onDragEnd(),
      child: badge,
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String name;
  final String label;
  final AppColors colors;
  final AppTextStyles styles;

  const _PlayerBadge({
    required this.name,
    required this.label,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _firstName(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: styles.caption3.copyWith(
                color: const Color(0xFF105230),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            label,
            style: styles.label.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineupDragHint extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles styles;

  const _LineupDragHint({
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app, color: colors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hold på en spiller og træk for at bytte plads',
              style: styles.caption1.copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(CupertinoIcons.arrow_right_arrow_left,
              color: colors.primary, size: 16),
        ],
      ),
    );
  }
}

class _BenchPlayerCard extends StatelessWidget {
  final _LineupPlayer player;
  final AppColors colors;
  final AppTextStyles styles;
  final ValueChanged<_LineupPlayer> onDragStarted;
  final VoidCallback onDragEnd;

  const _BenchPlayerCard({
    required this.player,
    required this.colors,
    required this.styles,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: player.selected
              ? colors.divider.withValues(alpha: 0.35)
              : colors.warning,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: player.selected ? colors.lightGrass : colors.lightGrass55,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _firstName(player.user.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.caption2.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            _positionShortLabel(player.user.position),
            style: styles.caption3.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return LongPressDraggable<_LineupDragData>(
      data: _LineupDragData(player: player),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.04, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDragStarted: () => onDragStarted(player),
      onDragEnd: (_) => onDragEnd(),
      onDraggableCanceled: (_, __) => onDragEnd(),
      child: card,
    );
  }
}

class _EmptySlotBadge extends StatelessWidget {
  final String label;
  final bool highlighted;
  final AppTextStyles styles;

  const _EmptySlotBadge({
    required this.label,
    required this.highlighted,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: highlighted ? 2.4 : 1.6,
          style: BorderStyle.solid,
        ),
        color: highlighted
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: styles.caption3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FormationSheet extends StatelessWidget {
  final String currentFormation;
  final List<String> formations;

  const _FormationSheet({
    required this.currentFormation,
    required this.formations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.82;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF877B70),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Vælg formation', style: styles.h5.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              'Vælg formationen der passer bedst til jeres næste kamp',
              style: styles.caption1.copyWith(color: colors.grey7),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final formation in formations) ...[
                      _FormationOption(
                        formation: formation,
                        selected: formation == currentFormation,
                        colors: colors,
                        styles: styles,
                        onTap: () => Navigator.of(context).pop(formation),
                      ),
                      if (formation != formations.last)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormationOption extends StatelessWidget {
  final String formation;
  final bool selected;
  final AppColors colors;
  final AppTextStyles styles;
  final VoidCallback onTap;

  const _FormationOption({
    required this.formation,
    required this.selected,
    required this.colors,
    required this.styles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? colors.background : colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? colors.primary : colors.divider),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 40,
              child: FootballPitch(
                borderRadius: BorderRadius.circular(6),
                linePadding: const EdgeInsets.all(4),
                borderWidth: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formation $formation',
                    style: styles.body4.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formationDescription(formation),
                    style: styles.caption1.copyWith(color: colors.grey7),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.check_mark,
                    color: colors.white, size: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _LineupPlayer {
  final EventAttendanceDetails attendance;
  final bool selected;

  const _LineupPlayer({
    required this.attendance,
    required this.selected,
  });

  factory _LineupPlayer.fromAttendance(EventAttendanceDetails attendance) {
    return _LineupPlayer(
      attendance: attendance,
      selected: attendance.isSelected == true,
    );
  }

  UserDetails get user => attendance.userDetails;

  _LineupPlayer copyWith({bool? selected}) {
    return _LineupPlayer(
      attendance: attendance,
      selected: selected ?? this.selected,
    );
  }
}

class _LineupDragData {
  final _LineupPlayer player;
  final int? fromSlot;

  const _LineupDragData({
    required this.player,
    this.fromSlot,
  });
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _positionShortLabel(String? position) {
  final value = position?.toLowerCase().trim() ?? '';
  return switch (value) {
    'goalkeeper' => 'MM',
    'centre_back' => 'CB',
    'back_wingback' => 'F',
    'defensive_midfield' => 'DM',
    'midfield' => 'CM',
    'attacking_midfield' => 'OM',
    'wing' => 'K',
    'striker' => 'A',
    _ => 'SP',
  };
}

String _formationDescription(String formation) {
  return switch (formation) {
    '2-3-1' => 'Standard 7-mands',
    '3-2-1' => 'Defensiv balance',
    '2-2-2' => 'Symmetrisk kontrol',
    '3-1-2' => 'Offensiv bredde',
    '4-3-3' => 'Offensiv bredde',
    '4-4-2' => 'Klassisk balance',
    '3-5-2' => 'Midtbanekontrol',
    '4-2-3-1' => 'Kontrolleret pres',
    _ => 'Tilpasset opstilling',
  };
}
