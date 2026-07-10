import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
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
  final SystemUiOverlayStyle? systemOverlayStyle;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.backgroundColor,
    this.onRefresh,
    this.navigationBar,
    this.showBackButton = false,
    this.showTopBar = true,
    this.useTopSafeArea = true,
    this.systemOverlayStyle,
  });

  const PageScaffold.tab({
    super.key,
    required this.title,
    required this.body,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.backgroundColor,
    this.onRefresh,
    this.systemOverlayStyle,
    this.useTopSafeArea = true,
  })  : showBackButton = false,
        showTopBar = true,
        navigationBar = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final isIOS = theme.platform == TargetPlatform.iOS;
    final bgColor = backgroundColor ?? appColors.white;

    final page = isIOS
        ? CupertinoPageScaffold(
            backgroundColor: bgColor,
            navigationBar: showTopBar
                ? navigationBar ??
                    CupertinoNavigationBar(
                      backgroundColor: bgColor,
                      middle: _buildTitle(appTextStyles),
                      leading: leading ??
                          (showBackButton ? _defaultBackButton(context) : null),
                      trailing: _buildTrailing(appColors),
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
          )
        : Scaffold(
            backgroundColor: bgColor,
            appBar: showTopBar
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
                    actions: trailing ?? [],
                  )
                : null,
            body: SafeArea(top: useTopSafeArea, child: body),
            floatingActionButton: floatingActionButton,
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
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
