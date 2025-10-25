import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/navigation/app_navigation.dart';
import 'common_widgets.dart';

/// Consistent app header/navigation bar
class AppHeader extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;

  const AppHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.centerTitle = false,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.space6,
        vertical: DesignSystem.space4,
      ),
      decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            if (showBackButton)
              Hero(
                    tag: 'back_button',
                    child: Material(
                      color: Colors.transparent,
                      child: AppIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: DesignSystem.iconSizeSm,
                        onPressed: () {
                          if (onBackPressed != null) {
                            onBackPressed!();
                          } else {
                            AppNavigation.pop(context);
                          }
                        },
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: DesignSystem.durationFast)
                  .slideX(
                    begin: -0.2,
                    end: 0,
                    duration: DesignSystem.durationFast,
                    curve: DesignSystem.curveEaseOut,
                  ),

            if (showBackButton) const SizedBox(width: DesignSystem.space4),

            // Title
            if (centerTitle) const Spacer(),

            titleWidget ??
                Text(
                  title!,
                  style: DesignSystem.headlineMedium.copyWith(
                    color: DesignSystem.neutral900,
                  ),
                ),

            if (centerTitle && actions == null) const Spacer(),

            if (!centerTitle) const Spacer(),

            // Actions
            if (actions != null) ...[
              if (centerTitle) const Spacer(),
              ...actions!.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(left: DesignSystem.space3),
                  child: action,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simplified page scaffold with consistent design
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsets? padding;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.centerTitle = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? DesignSystem.backgroundPrimary,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          if (title != null || titleWidget != null)
            AppHeader(
              title: title,
              titleWidget: titleWidget,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
              actions: actions,
              centerTitle: centerTitle,
            ),
          Expanded(
            child:
                padding != null
                    ? Padding(padding: padding!, child: body)
                    : body,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
