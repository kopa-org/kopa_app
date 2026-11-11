import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/page/wrapped/wrapped_settings_sheet.dart';
import 'package:kopa/page/wrapped/wrapped_slides.dart';
import 'package:kopa/repository/season_wrapped_repository.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:share_plus/share_plus.dart';

/// The full-screen Season Wrapped story: tap right for the next slide, left
/// for the previous one. The last slide shares the awards card or moves on
/// to the next season.
class SeasonWrappedPage extends StatefulWidget {
  final SeasonWrapped wrapped;
  final int teamId;
  final int currentUserId;
  final bool canCustomize;

  const SeasonWrappedPage({
    super.key,
    required this.wrapped,
    required this.teamId,
    required this.currentUserId,
    required this.canCustomize,
  });

  /// Opens the story. Resolves once the viewer leaves it.
  static Future<void> open(
    BuildContext context, {
    required SeasonWrapped wrapped,
    required int teamId,
    required int currentUserId,
    required bool canCustomize,
  }) {
    AppAnalytics.logEvent('season_wrapped_opened');
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => SeasonWrappedPage(
          wrapped: wrapped,
          teamId: teamId,
          currentUserId: currentUserId,
          canCustomize: canCustomize,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  State<SeasonWrappedPage> createState() => _SeasonWrappedPageState();
}

class _SeasonWrappedPageState extends State<SeasonWrappedPage> {
  final _shareKey = GlobalKey();
  late SeasonWrapped _wrapped = widget.wrapped;
  int _index = 0;
  bool _sharing = false;

  List<String> get _slides => _wrapped.slides;
  String get _slide => _slides[_index.clamp(0, _slides.length - 1)];
  bool get _isLast => _index >= _slides.length - 1;

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _slides.length - 1);
    if (next == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = next);
  }

  Future<void> _customize() async {
    final saved = await showWrappedSettingsSheet(
      context,
      teamId: widget.teamId,
      wrapped: _wrapped,
    );
    if (!saved || !mounted) return;
    try {
      final updated =
          await SeasonWrappedRepository.getSeasonWrapped(widget.teamId);
      if (!mounted) return;
      setState(() {
        _wrapped = updated;
        _index = _index.clamp(0, updated.slides.length - 1);
      });
    } catch (_) {
      // Keep the story as it was; the next open shows the new settings.
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final text = AppLocalizations.of(context)!.wrappedShareText;
    try {
      final boundary = _shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 3);
      final bytes = await image?.toByteData(format: ui.ImageByteFormat.png);
      AppAnalytics.logEvent('season_wrapped_shared');
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: bytes == null
              ? null
              : [
                  XFile.fromData(
                    bytes.buffer.asUint8List(),
                    mimeType: 'image/png',
                    name: 'kopa-season-wrapped.png',
                  ),
                ],
        ),
      );
    } catch (_) {
      // Sharing is best effort; the story stays open either way.
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _close() {
    AppAnalytics.logEvent(
      'season_wrapped_closed',
      parameters: {'slide': _slide, 'completed': _isLast},
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chrome = WrappedColors.chrome(_slide);
    final dark = WrappedSlide.isDark(_slide);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: WrappedSlide.background(_slide),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: WrappedSlide(
                  key: ValueKey(_slide),
                  slide: _slide,
                  wrapped: _wrapped,
                  currentUserId: widget.currentUserId,
                  shareKey: _shareKey,
                  onShare: _sharing ? null : _share,
                  onContinue: _close,
                ),
              ),
            ),
            if (!_isLast)
              Positioned.fill(
                top: 80,
                child: Row(
                  children: [
                    Expanded(
                      flex: 34,
                      child: Semantics(
                        button: true,
                        label: l10n.wrappedPrevious,
                        child: GestureDetector(
                          key: const ValueKey('wrapped_previous'),
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _go(-1),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 66,
                      child: Semantics(
                        button: true,
                        label: l10n.wrappedNext,
                        child: GestureDetector(
                          key: const ValueKey('wrapped_next'),
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _go(1),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                height: 60,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _go(-1),
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < _slides.length; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 3,
                              decoration: BoxDecoration(
                                color: chrome.withValues(
                                  alpha: i <= _index ? 0.95 : 0.28,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.wrappedProgress(_index + 1, _slides.length),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: chrome.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (widget.canCustomize)
                          IconButton(
                            key: const ValueKey('wrapped_customize'),
                            tooltip: l10n.wrappedCustomize,
                            onPressed: _customize,
                            icon: Icon(Icons.tune_rounded, color: chrome),
                          ),
                        IconButton(
                          key: const ValueKey('wrapped_close'),
                          tooltip: l10n.wrappedClose,
                          onPressed: _close,
                          icon: Icon(Icons.close_rounded, color: chrome),
                        ),
                      ],
                    ),
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
