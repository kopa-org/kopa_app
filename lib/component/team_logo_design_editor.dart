import 'package:flutter/material.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class TeamLogoDesignEditor extends StatefulWidget {
  final String teamName;
  final TeamLogoDesign design;
  final ValueChanged<TeamLogoDesign> onChanged;
  final String keyPrefix;

  const TeamLogoDesignEditor({
    super.key,
    required this.teamName,
    required this.design,
    required this.onChanged,
    this.keyPrefix = 'team-logo',
  });

  @override
  State<TeamLogoDesignEditor> createState() => _TeamLogoDesignEditorState();
}

class _TeamLogoDesignEditorState extends State<TeamLogoDesignEditor> {
  late TeamLogoDesign _currentDesign;

  @override
  void initState() {
    super.initState();
    _currentDesign = widget.design;
  }

  @override
  void didUpdateWidget(covariant TeamLogoDesignEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.design != widget.design) {
      _currentDesign = widget.design;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final textStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final design = _currentDesign;
    final initials = _initials(
      widget.teamName.isEmpty ? 'Skjold 7' : widget.teamName,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 196,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _LogoPreview(
            initials: initials,
            color: design.color,
            shape: design.shape,
            pattern: design.pattern,
            size: 150,
            selected: true,
          ),
        ),
        const SizedBox(height: 26),
        _LogoFieldLabel(
          text: l10n.teamLogoBackgroundColor,
          colors: colors,
          textStyles: textStyles,
        ),
        const SizedBox(height: 10),
        _LogoColorPicker(
          keyPrefix: widget.keyPrefix,
          selected: design.color,
          onChanged: (color) => _update(color: color),
        ),
        const SizedBox(height: 18),
        _LogoFieldLabel(
          text: l10n.teamLogoShape,
          colors: colors,
          textStyles: textStyles,
        ),
        const SizedBox(height: 10),
        _LogoShapePicker(
          keyPrefix: widget.keyPrefix,
          colors: colors,
          initials: initials,
          color: design.color,
          pattern: design.pattern,
          selected: design.shape,
          onChanged: (shape) => _update(shape: shape),
        ),
        const SizedBox(height: 18),
        _LogoFieldLabel(
          text: l10n.teamLogoPattern,
          colors: colors,
          textStyles: textStyles,
        ),
        const SizedBox(height: 10),
        _LogoPatternPicker(
          keyPrefix: widget.keyPrefix,
          colors: colors,
          color: design.color,
          selected: design.pattern,
          onChanged: (pattern) => _update(pattern: pattern),
        ),
      ],
    );
  }

  void _update({
    Color? color,
    TeamLogoShape? shape,
    TeamLogoPattern? pattern,
  }) {
    final nextDesign = TeamLogoDesign(
      color: color ?? _currentDesign.color,
      shape: shape ?? _currentDesign.shape,
      pattern: pattern ?? _currentDesign.pattern,
    );
    setState(() => _currentDesign = nextDesign);
    widget.onChanged(nextDesign);
  }
}

class _LogoFieldLabel extends StatelessWidget {
  final String text;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _LogoFieldLabel({
    required this.text,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyles.caption.copyWith(
        color: colors.dirt,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LogoColorPicker extends StatelessWidget {
  final String keyPrefix;
  final Color selected;
  final ValueChanged<Color> onChanged;

  const _LogoColorPicker({
    required this.keyPrefix,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final color in _logoColors)
          GestureDetector(
            key: ValueKey(
              '$keyPrefix-color-${TeamLogoDesign.colorToHex(color)}',
            ),
            onTap: () => onChanged(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: selected == color ? 3 : 0,
                ),
                boxShadow: selected == color
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _LogoShapePicker extends StatelessWidget {
  final String keyPrefix;
  final AppColors colors;
  final String initials;
  final Color color;
  final TeamLogoPattern pattern;
  final TeamLogoShape selected;
  final ValueChanged<TeamLogoShape> onChanged;

  const _LogoShapePicker({
    required this.keyPrefix,
    required this.colors,
    required this.initials,
    required this.color,
    required this.pattern,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final shape in TeamLogoShape.values)
          GestureDetector(
            key: ValueKey('$keyPrefix-shape-${shape.name}'),
            onTap: () => onChanged(shape),
            child: _LogoPreview(
              initials: initials,
              color: selected == shape ? color : const Color(0xFFDCE5E2),
              shape: shape,
              pattern: selected == shape ? pattern : TeamLogoPattern.solid,
              size: 56,
              selected: selected == shape,
              textColor:
                  selected == shape ? colors.white : colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _LogoPatternPicker extends StatelessWidget {
  final String keyPrefix;
  final AppColors colors;
  final Color color;
  final TeamLogoPattern selected;
  final ValueChanged<TeamLogoPattern> onChanged;

  const _LogoPatternPicker({
    required this.keyPrefix,
    required this.colors,
    required this.color,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final pattern in TeamLogoPattern.values)
          GestureDetector(
            key: ValueKey('$keyPrefix-pattern-${pattern.name}'),
            onTap: () => onChanged(pattern),
            child: Container(
              width: 56,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected == pattern
                      ? colors.primary
                      : const Color(0xFFD1D6E0),
                  width: selected == pattern ? 2 : 1,
                ),
              ),
              child: _PatternPreview(color: color, pattern: pattern),
            ),
          ),
      ],
    );
  }
}

class _LogoPreview extends StatelessWidget {
  final String initials;
  final Color color;
  final TeamLogoShape shape;
  final TeamLogoPattern pattern;
  final double size;
  final bool selected;
  final Color? textColor;

  const _LogoPreview({
    required this.initials,
    required this.color,
    required this.shape,
    required this.pattern,
    required this.size,
    required this.selected,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: pattern == TeamLogoPattern.solid ? color : null,
        gradient: _logoGradient(color, pattern),
        shape: _logoShape(shape, selected),
        shadows: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: size >= 100 ? 8 : 4,
                  offset: Offset(0, size >= 100 ? 4 : 2),
                ),
              ]
            : null,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size >= 100 ? 48 : 16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _PatternPreview extends StatelessWidget {
  final Color color;
  final TeamLogoPattern pattern;

  const _PatternPreview({
    required this.color,
    required this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        gradient: _logoGradient(color, pattern),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

const _logoColors = <Color>[
  Color(0xFF1B8B4B),
  Color(0xFF15213D),
  Color(0xFFD22B2B),
  Color(0xFF1975F2),
  Color(0xFFF05A00),
  Color(0xFF6E22A8),
  Color(0xFF008E7B),
  Color(0xFF263238),
];

Gradient? _logoGradient(Color color, TeamLogoPattern pattern) {
  final secondary = Color.lerp(color, Colors.white, 0.78)!;
  return switch (pattern) {
    TeamLogoPattern.solid => null,
    TeamLogoPattern.verticalSplit => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, color, secondary, secondary],
        stops: const [0, 0.5, 0.5, 1],
      ),
    TeamLogoPattern.horizontalSplit => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color, secondary, secondary],
        stops: const [0, 0.5, 0.5, 1],
      ),
    TeamLogoPattern.gradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, Colors.white],
      ),
  };
}

ShapeBorder _logoShape(TeamLogoShape shape, bool selected) {
  final side = selected
      ? const BorderSide(color: Colors.white, width: 4)
      : BorderSide.none;
  return switch (shape) {
    TeamLogoShape.circle => CircleBorder(side: side),
    TeamLogoShape.square => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: side,
      ),
    TeamLogoShape.shield => RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        side: side,
      ),
    TeamLogoShape.rounded => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: side,
      ),
  };
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
