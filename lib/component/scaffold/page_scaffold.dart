import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Returns the bottom obstruction reported by the root main-tab scaffold.
///
/// The root scaffold updates this media-query padding to the measured height
/// of its transparent navigation bar while the tab body remains edge-to-edge.
double mainTabBottomContentPadding(BuildContext context) {
  return MediaQuery.paddingOf(context).bottom;
}

class PageScaffold extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget body;
  final Widget? leading;
  final List<Widget>? trailing;
  final Widget? floatingActionButton;
  final double floatingActionButtonBottomInset;
  final Color? backgroundColor;
  final Future<void> Function()? onRefresh;
  final bool showBackButton;
  final bool showTopBar;
  final bool showTitle;
  final bool useTopSafeArea;
  final bool useBottomSafeArea;
  final ObstructingPreferredSizeWidget? navigationBar;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool _isTabScaffold;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.floatingActionButtonBottomInset = 16,
    this.backgroundColor,
    this.onRefresh,
    this.navigationBar,
    this.showBackButton = false,
    this.showTopBar = true,
    this.showTitle = true,
    this.useTopSafeArea = true,
    this.useBottomSafeArea = true,
    this.systemOverlayStyle,
  }) : _isTabScaffold = false;

  const PageScaffold.tab({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.floatingActionButtonBottomInset = 120,
    this.backgroundColor,
    this.onRefresh,
    this.systemOverlayStyle,
    this.useTopSafeArea = true,
    this.showTopBar = true,
    this.useBottomSafeArea = false,
  })  : showBackButton = false,
        showTitle = false,
        navigationBar = null,
        _isTabScaffold = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final isIOS = theme.platform == TargetPlatform.iOS;
    final bgColor = backgroundColor ?? appColors.background;
    final shouldShowTopBar = showTopBar && _hasTopBarContent;
    // The root tab scaffold uses extendBody, so its Android nav bar overlays
    // nested tab scaffolds. Lift their FAB by the reported bar height.
    // Pushed pages inside a tab branch also sit under that bar. Material's
    // Scaffold only clears the system inset (viewPadding), so add whatever
    // extra bottom obstruction the shell reports through padding.
    final pushedPageObstruction = math.max(
      0.0,
      MediaQuery.paddingOf(context).bottom -
          MediaQuery.viewPaddingOf(context).bottom,
    );
    final androidFloatingActionButton = isIOS ||
            floatingActionButton == null ||
            (!_isTabScaffold && pushedPageObstruction == 0)
        ? floatingActionButton
        : Padding(
            padding: EdgeInsets.only(
              bottom: _isTabScaffold
                  ? mainTabBottomContentPadding(context)
                  : pushedPageObstruction,
            ),
            child: floatingActionButton,
          );

    final page = isIOS
        ? CupertinoPageScaffold(
            backgroundColor: bgColor,
            navigationBar: shouldShowTopBar
                ? navigationBar ??
                    CupertinoNavigationBar(
                      backgroundColor: bgColor,
                      middle: _buildTitle(appTextStyles),
                      leading: leading ??
                          (showBackButton ? _defaultBackButton(context) : null),
                      trailing: _buildTrailing(appColors),
                    )
                : null,
            child: DefaultTextStyle(
              style: appTextStyles.body.copyWith(
                decoration: TextDecoration.none,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SafeArea(
                      top: useTopSafeArea,
                      bottom: useBottomSafeArea,
                      child: onRefresh != null
                          ? CustomScrollView(
                              slivers: [
                                CupertinoSliverRefreshControl(
                                  onRefresh: onRefresh!,
                                ),
                                SliverFillRemaining(child: body),
                              ],
                            )
                          : body,
                    ),
                    if (floatingActionButton != null)
                      Positioned(
                        right: 16,
                        // Pushed pages can sit under the main tab bar or the
                        // home indicator, so clear the reported bottom inset
                        // like the Material scaffold does. Tab scaffolds
                        // already pass an inset that clears the bar.
                        bottom: floatingActionButtonBottomInset +
                            (_isTabScaffold
                                ? 0
                                : MediaQuery.paddingOf(context).bottom),
                        child: floatingActionButton!,
                      ),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: bgColor,
            appBar: shouldShowTopBar
                ? AppBar(
                    title: _buildTitle(appTextStyles),
                    backgroundColor: bgColor,
                    foregroundColor: appColors.primary,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: leading ??
                        (showBackButton
                            ? _defaultMaterialBackButton(context)
                            : null),
                    automaticallyImplyLeading: showBackButton,
                    // Text actions have no padding, so keep them off the edge.
                    actions: [
                      ...?trailing,
                      if (trailing?.isNotEmpty ?? false)
                        const SizedBox(width: 16),
                    ],
                  )
                : null,
            body: SafeArea(
              top: useTopSafeArea,
              bottom: useBottomSafeArea,
              child: body,
            ),
            floatingActionButton: androidFloatingActionButton,
          );

    final systemOverlayStyle = this.systemOverlayStyle;
    if (systemOverlayStyle == null) return page;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: page,
    );
  }

  Widget _buildTitle(AppTextStyles appTextStyles) {
    final titleWidget = this.titleWidget;
    if (titleWidget != null) return titleWidget;
    if (!showTitle) return const SizedBox.shrink();

    return title == 'Kopa'
        ? SvgPicture.asset(
            'assets/logos/Logo.svg',
            height: 24,
          )
        : Text(
            title,
            style: appTextStyles.sectionHeader,
          );
  }

  bool get _hasTopBarContent {
    return showTitle ||
        titleWidget != null ||
        leading != null ||
        showBackButton ||
        (trailing?.isNotEmpty ?? false);
  }

  Widget? _buildTrailing(AppColors appColors) {
    final trailing = this.trailing;
    if (trailing == null || trailing.isEmpty) return null;

    return IconTheme.merge(
      data: IconThemeData(color: appColors.primary),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: trailing,
      ),
    );
  }

  Widget _defaultBackButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.of(context).pop(),
      child: const Icon(CupertinoIcons.back),
    );
  }

  Widget _defaultMaterialBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Theme.of(context).extension<AppColors>()?.dirt,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
