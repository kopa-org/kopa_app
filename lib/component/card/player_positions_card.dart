import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class PlayerPositionsCard extends StatelessWidget {
  final int playerCount;
  final String formation;
  final List<UserDetails> players;
  final VoidCallback? onEditFormation;

  const PlayerPositionsCard({
    super.key,
    required this.playerCount,
    required this.formation,
    required this.players,
    this.onEditFormation,
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
    final sortedPlayers = _sortPlayersForFormation(players, playerFormation);
    final starters = sortedPlayers.take(playerFormation.slots.length).toList();
    final bench = sortedPlayers.skip(playerFormation.slots.length).toList();

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
  final List<UserDetails> players;

  const _Pitch({
    required this.colors,
    required this.styles,
    required this.slots,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      child: CustomPaint(
        painter: _PitchPainter(colors: colors),
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
    const markerSize = 34.0;
    final label = player == null ? slot.fallbackLabel : _initials(player!.name);

    return Positioned.fill(
      child: Align(
        alignment: Alignment(slot.x * 2 - 1, slot.y * 2 - 1),
        child: Tooltip(
          message: player?.name ?? slot.fallbackName,
          child: Container(
            width: markerSize,
            height: markerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: player == null ? colors.lightGrass95 : colors.lightGrass,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.lightGrass55,
                width: 2,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.caption.copyWith(
                color: colors.dirt,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final AppColors colors;

  const _PitchPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = colors.lightGrass55
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawColor(colors.grass, BlendMode.src);

    final borderRadius = Radius.circular(Spacing.borderRadiusMedium);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, borderRadius),
      linePaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.5),
      size.width * 0.11,
      linePaint,
    );

    _drawPenaltyBox(canvas, size, linePaint, isTop: true);
    _drawPenaltyBox(canvas, size, linePaint, isTop: false);
  }

  void _drawPenaltyBox(
    Canvas canvas,
    Size size,
    Paint paint, {
    required bool isTop,
  }) {
    final boxWidth = size.width * 0.42;
    final boxHeight = size.height * 0.12;
    final goalWidth = size.width * 0.2;
    final goalHeight = size.height * 0.055;
    final left = (size.width - boxWidth) / 2;
    final goalLeft = (size.width - goalWidth) / 2;

    final boxRect = isTop
        ? Rect.fromLTWH(left, 0, boxWidth, boxHeight)
        : Rect.fromLTWH(left, size.height - boxHeight, boxWidth, boxHeight);
    final goalRect = isTop
        ? Rect.fromLTWH(goalLeft, 0, goalWidth, goalHeight)
        : Rect.fromLTWH(
            goalLeft,
            size.height - goalHeight,
            goalWidth,
            goalHeight,
          );

    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(goalRect, const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return oldDelegate.colors != colors;
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
