import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

/// One tab in an [ExpandingSegmentedControl].
class ExpandingSegment<T> {
  final T value;
  final String label;
  final IconData icon;

  /// Replaces [icon] for custom artwork (e.g. an SVG), drawn in the colour
  /// the tab currently uses.
  final Widget Function(Color color)? customIcon;

  /// Key for the tab button.
  final String? keyName;

  const ExpandingSegment({
    required this.value,
    required this.label,
    required this.icon,
    this.customIcon,
    this.keyName,
  });
}

/// The app's tab menu (match details, fine box). Built on google_nav_bar's
/// [GNav], the same widget as the bottom navigation: unselected tabs show
/// only their icon, and the selected one animates open into a grass-green
/// pill with its label. The track is white with a white outline, and the
/// pill runs flush to the track's ends.
class ExpandingSegmentedControl<T> extends StatelessWidget {
  final List<ExpandingSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Draws the rounded track behind the tabs (match details under its header).
  final bool showTrack;
  final double height;

  /// Selected tab colours; defaults to white on grass green.
  final Color? selectedForeground;
  final Color? selectedBackground;
  final Color? trackColor;

  /// Key for the track container.
  final Key? trackKey;

  const ExpandingSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.showTrack = true,
    this.height = 44,
    this.selectedForeground,
    this.selectedBackground,
    this.trackColor,
    this.trackKey,
  });

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final activeForeground = selectedForeground ?? colors.white;
    final inactiveForeground = colors.textSecondary;
    final selectedIndex =
        segments.indexWhere((segment) => segment.value == selected);
    final verticalPadding = ((height - _iconSize) / 2).clamp(0.0, 40.0);

    final nav = GNav(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onTabChange: (index) => onChanged(segments[index].value),
      gap: 6,
      iconSize: _iconSize,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: verticalPadding,
      ),
      tabBorderRadius: height / 2,
      color: inactiveForeground,
      activeColor: activeForeground,
      tabBackgroundColor: selectedBackground ?? colors.grass,
      textStyle: styles.body3.copyWith(
        color: activeForeground,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      duration: MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      tabs: [
        for (var index = 0; index < segments.length; index++)
          GButton(
            key: segments[index].keyName == null
                ? null
                : ValueKey<String>(segments[index].keyName!),
            icon: segments[index].icon,
            text: segments[index].label,
            semanticLabel: segments[index].label,
            leading: segments[index].customIcon?.call(
                  index == selectedIndex
                      ? activeForeground
                      : inactiveForeground,
                ),
          ),
      ],
    );

    // GNav cannot shorten labels and sizes itself, so give it the track's
    // width and height and let it shrink only when it would not fit (large
    // text, narrow phones, the collapsing match header). Normal sizes are
    // unaffected.
    final fitted = SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: nav,
          ),
        ),
      ),
    );

    if (!showTrack) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: fitted,
      );
    }

    // Same radius as the pills so the selected one sits flush at the ends.
    // The outline is painted on top, so it does not change the layout.
    return Container(
      key: trackKey,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: trackColor ?? colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: fitted,
    );
  }
}
