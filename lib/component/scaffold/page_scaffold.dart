import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? trailing;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Future<void> Function()? onRefresh;
  final bool showBackButton;
  final bool showTopBar;
  final bool useTopSafeArea;
  final ObstructingPreferredSizeWidget? navigationBar;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.backgroundColor,
    this.onRefresh,
    this.navigationBar,
    this.showBackButton = false,
    this.showTopBar = true,
    this.useTopSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final isIOS = theme.platform == TargetPlatform.iOS;
    final bgColor = backgroundColor ?? appColors.background;

    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: bgColor,
        navigationBar: showTopBar
            ? navigationBar ??
                CupertinoNavigationBar(
                  backgroundColor: bgColor.withValues(alpha: 0.8),
                  middle: title == 'Kopa'
                      ? SvgPicture.asset(
                          'assets/logos/Logo.svg',
                          height: 24,
                        )
                      : Text(
                          title,
                          style: appTextStyles.sectionHeader,
                        ),
                  leading: leading ??
                      (showBackButton ? _defaultBackButton(context) : null),
                  trailing: trailing != null
                      ? Row(mainAxisSize: MainAxisSize.min, children: trailing!)
                      : null,
                )
            : null,
        child: SafeArea(
          top: useTopSafeArea,
          child: onRefresh != null
              ? CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: onRefresh!),
                    SliverFillRemaining(child: body),
                  ],
                )
              : body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: showTopBar
          ? AppBar(
              title: title == 'Kopa'
                  ? SvgPicture.asset(
                      'assets/logos/Logo.svg',
                      height: 24,
                    )
                  : Text(
                      title,
                      style: appTextStyles.sectionHeader,
                    ),
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: leading ??
                  (showBackButton ? _defaultMaterialBackButton(context) : null),
              automaticallyImplyLeading: showBackButton,
              actions: trailing ?? [],
            )
          : null,
      body: SafeArea(top: useTopSafeArea, child: body),
      floatingActionButton: floatingActionButton,
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
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
