import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/football_pitch.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PlayerPositionsCard extends StatelessWidget {
  final int playerCount;
  final String formation;
  final List<UserDetails> players;
  final List<UserDetails?>? positionedPlayers;
  final VoidCallback? onEditFormation;
  final bool preservePlayerOrder;

  const PlayerPositionsCard({
    super.key,
    required this.playerCount,
    required this.formation,
    required this.players,
    this.positionedPlayers,
    this.onEditFormation,
    this.preservePlayerOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final playerFormation = PlayerFormation.fromString(
      formation,
      playerCount: playerCount,
    );
    final starters = positionedPlayers == null
        ? _startingPlayersForFormation(playerFormation)
        : _normalizePositionedPlayers(
            positionedPlayers!,
            playerFormation.slots.length,
          );
    final bench = _benchPlayersFor(starters, playerFormation);

    return KopaCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Holdopstilling',
            style: styles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormationChip(formation: playerFormation.label),
              if (onEditFormation != null) ...[
                const SizedBox(width: Spacing.sm),
                CupertinoButton(
                  minimumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                  onPressed: onEditFormation,
                  child: Icon(
                    CupertinoIcons.pencil_circle,
                    color: colors.primary,
                    size: 26,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _BenchLegend(bench: bench),
          const SizedBox(height: Spacing.sm),
          AspectRatio(
            aspectRatio: 0.72,
            child: _Pitch(
              colors: colors,
              styles: styles,
              slots: playerFormation.slots,
              players: starters,
            ),
          ),
        ],
      ),
    );
  }

  List<UserDetails?> _startingPlayersForFormation(PlayerFormation formation) {
    final sortedPlayers = preservePlayerOrder
        ? [...players]
        : _sortPlayersForFormation(players, formation);

    return sortedPlayers.take(formation.slots.length).toList();
  }

  List<UserDetails?> _normalizePositionedPlayers(
    List<UserDetails?> positionedPlayers,
    int slotCount,
  ) {
    return List<UserDetails?>.generate(
      slotCount,
      (slot) =>
          slot < positionedPlayers.length ? positionedPlayers[slot] : null,
    );
  }

  List<UserDetails> _benchPlayersFor(
    List<UserDetails?> starters,
    PlayerFormation formation,
  ) {
    if (positionedPlayers == null) {
      final sortedPlayers = preservePlayerOrder
          ? [...players]
          : _sortPlayersForFormation(players, formation);

      return sortedPlayers.skip(formation.slots.length).toList();
    }

    final starterIds =
        starters.whereType<UserDetails>().map((player) => player.id).toSet();

    return players.where((player) => !starterIds.contains(player.id)).toList();
  }

  List<UserDetails> _sortPlayersForFormation(
    List<UserDetails> players,
    PlayerFormation formation,
  ) {
    final remaining = [...players];
    final ordered = <UserDetails>[];

    for (final role in formation.slots.map((slot) => slot.role)) {
      final matchIndex = remaining.indexWhere(
        (player) => _positionMatchesRole(player.position, role),
      );
      if (matchIndex == -1) continue;
      ordered.add(remaining.removeAt(matchIndex));
    }

    ordered.addAll(remaining);
    return ordered;
  }

  bool _positionMatchesRole(String? position, FormationRole role) {
    final value = position?.toLowerCase().trim() ?? '';
    if (value.isEmpty) return false;

    return switch (role) {
      FormationRole.goalkeeper => value.contains('keeper') ||
          value.contains('målmand') ||
          value == 'gk' ||
          value == 'keeper',
      FormationRole.defender => value.contains('def') ||
          value.contains('back') ||
          value.contains('forsvar') ||
          value == 'cb' ||
          value == 'lb' ||
          value == 'rb',
      FormationRole.midfielder => value.contains('mid') ||
          value.contains('midt') ||
          value == 'cm' ||
          value == 'dm' ||
          value == 'am',
      FormationRole.forward => value.contains('angreb') ||
          value.contains('attack') ||
          value.contains('wing') ||
          value.contains('forward') ||
          value.contains('striker') ||
          value == 'st' ||
          value == 'fw',
    };
  }
}

class _FormationChip extends StatelessWidget {
  final String formation;

  const _FormationChip({required this.formation});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: colors.lightGrass55,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      ),
      child: Text(
        formation,
        style: styles.caption.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BenchLegend extends StatelessWidget {
  final List<UserDetails> bench;

  const _BenchLegend({required this.bench});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final labels = bench.isEmpty
        ? const ['Ingen bænk']
        : bench.take(4).map((player) => _initials(player.name)).toList();

    return Column(
      children: [
        Text(
          'På bænken:',
          style: styles.caption.copyWith(color: colors.grey4),
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Spacing.sm,
          runSpacing: 4,
          children: labels
              .map(
                (label) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.lightGrass,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: styles.caption.copyWith(
                        color: colors.grey5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _Pitch extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles styles;
  final List<FormationSlot> slots;
  final List<UserDetails?> players;

  const _Pitch({
    required this.colors,
    required this.styles,
    required this.slots,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return FootballPitch(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Stack(
        children: [
          for (var i = 0; i < slots.length; i++)
            _PositionedPlayer(
              slot: slots[i],
              player: i < players.length ? players[i] : null,
              colors: colors,
              styles: styles,
            ),
        ],
      ),
    );
  }
}

class _PositionedPlayer extends StatelessWidget {
  final FormationSlot slot;
  final UserDetails? player;
  final AppColors colors;
  final AppTextStyles styles;

  const _PositionedPlayer({
    required this.slot,
    required this.player,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(slot.x * 2 - 1, slot.y * 2 - 1),
        child: Tooltip(
          message: player?.name ?? slot.fallbackName,
          child: player == null
              ? _EmptyPositionBadge(
                  label: slot.fallbackLabel,
                  styles: styles,
                )
              : _PlayerPositionBadge(
                  name: player!.name,
                  label: slot.fallbackLabel,
                  colors: colors,
                  styles: styles,
                ),
        ),
      ),
    );
  }
}

class _PlayerPositionBadge extends StatelessWidget {
  final String name;
  final String label;
  final AppColors colors;
  final AppTextStyles styles;

  const _PlayerPositionBadge({
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

class _EmptyPositionBadge extends StatelessWidget {
  final String label;
  final AppTextStyles styles;

  const _EmptyPositionBadge({
    required this.label,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: styles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

enum FormationRole { goalkeeper, defender, midfielder, forward }

class PlayerFormation {
  final String label;
  final List<FormationSlot> slots;

  const PlayerFormation({required this.label, required this.slots});

  factory PlayerFormation.fromString(String formation,
      {required int playerCount}) {
    final lineCounts = _parseFormation(formation) ??
        _parseFormation(playerCount == 11 ? '4-3-3' : '2-3-1')!;

    return PlayerFormation(
      label: lineCounts.join('-'),
      slots: _buildSlots(lineCounts),
    );
  }

  static List<int>? _parseFormation(String formation) {
    final parts = formation
        .trim()
        .split('-')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    final counts = <int>[];
    for (final part in parts) {
      final count = int.tryParse(part);
      if (count == null || count < 1 || count > 5) return null;
      counts.add(count);
    }

    return counts;
  }

  static List<FormationSlot> _buildSlots(List<int> lineCounts) {
    final slots = <FormationSlot>[
      const FormationSlot(
        0.50,
        0.08,
        FormationRole.goalkeeper,
        'MM',
        'Målmand',
      ),
    ];

    final lineYValues = _lineYValues(lineCounts.length);
    for (var lineIndex = 0; lineIndex < lineCounts.length; lineIndex++) {
      final count = lineCounts[lineIndex];
      final y = lineYValues[lineIndex];
      final role = _roleForLine(lineIndex, lineCounts.length);
      final fallbackLabel = _fallbackLabelForRole(role);
      final fallbackName = _fallbackNameForRole(role);

      for (var playerIndex = 0; playerIndex < count; playerIndex++) {
        final x = count == 1 ? 0.50 : 0.18 + (0.64 / (count - 1)) * playerIndex;
        slots.add(
          FormationSlot(x, y, role, fallbackLabel, fallbackName),
        );
      }
    }

    return slots;
  }

  static List<double> _lineYValues(int lineCount) {
    if (lineCount == 1) return const [0.58];
    return List<double>.generate(
      lineCount,
      (index) => 0.28 + (0.52 / (lineCount - 1)) * index,
    );
  }

  static FormationRole _roleForLine(int lineIndex, int lineCount) {
    if (lineIndex == 0) return FormationRole.defender;
    if (lineIndex == lineCount - 1) return FormationRole.forward;
    return FormationRole.midfielder;
  }

  static String _fallbackLabelForRole(FormationRole role) {
    return switch (role) {
      FormationRole.goalkeeper => 'MM',
      FormationRole.defender => 'F',
      FormationRole.midfielder => 'M',
      FormationRole.forward => 'A',
    };
  }

  static String _fallbackNameForRole(FormationRole role) {
    return switch (role) {
      FormationRole.goalkeeper => 'Målmand',
      FormationRole.defender => 'Forsvar',
      FormationRole.midfielder => 'Midtbane',
      FormationRole.forward => 'Angreb',
    };
  }
}

class FormationSlot {
  final double x;
  final double y;
  final FormationRole role;
  final String fallbackLabel;
  final String fallbackName;

  const FormationSlot(
    this.x,
    this.y,
    this.role,
    this.fallbackLabel,
    this.fallbackName,
  );
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return parts
      .take(2)
      .map((part) => part.characters.first)
      .join()
      .toUpperCase();
}

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.split(RegExp(r'\s+')).first;
}
