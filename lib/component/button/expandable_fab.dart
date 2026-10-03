import 'package:kopa/theme/app_colors.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A floating action button that expands its child actions in a quarter arc.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
    this.openButtonKey,
    this.heroTag,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.icon = const Icon(Icons.add),
    this.closeIcon = const Icon(Icons.close),
    this.expandVertically = false,
    this.expandedWidth,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final Key? openButtonKey;
  final Object? heroTag;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget icon;
  final Widget closeIcon;
  final bool expandVertically;
  final double? expandedWidth;

  @override
  State<ExpandableFab> createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  /// Collapses the actions after an action opens its destination.
  void close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final extent = widget.children.isEmpty
        ? 56.0
        : widget.distance *
                (widget.expandVertically ? widget.children.length : 1) +
            60.0;
    return SizedBox(
      width: widget.expandedWidth ?? extent,
      height: extent,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(context),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ??
        theme.floatingActionButtonTheme.backgroundColor ??
        AppColors.of(context).primary;
    final foregroundColor = widget.foregroundColor ??
        theme.floatingActionButtonTheme.foregroundColor ??
        AppColors.of(context).white;

    return FloatingActionButton(
      heroTag: null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onPressed: _toggle,
      child: widget.closeIcon,
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    if (widget.children.isEmpty) return const [];

    final children = <Widget>[];
    final count = widget.children.length;
    final step = count == 1 ? 0.0 : 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: widget.expandVertically ? 90 : angleInDegrees,
          maxDistance:
              widget.distance * (widget.expandVertically ? count - i : 1),
          isVertical: widget.expandVertically,
          progress: _expandAnimation,
          isOpen: _open,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            key: widget.openButtonKey,
            heroTag: widget.heroTag,
            tooltip: widget.tooltip,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            onPressed: _toggle,
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.isVertical,
    required this.progress,
    required this.isOpen,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final bool isVertical;
  final Animation<double> progress;
  final bool isOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: isVertical
              ? child!
              : Transform.scale(
                  scale: 0.82 + (0.18 * progress.value),
                  child: Transform.rotate(
                    angle: (1.0 - progress.value) * math.pi / 2,
                    child: child!,
                  ),
                ),
        );
      },
      child: IgnorePointer(
        ignoring: !isOpen,
        child: FadeTransition(opacity: progress, child: child),
      ),
    );
  }
}
