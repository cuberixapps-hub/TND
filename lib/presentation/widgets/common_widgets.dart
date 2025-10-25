import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_system.dart';

/// Common button with consistent styling and press feedback
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.durationInstant,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.curveEaseInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final foregroundColor = _getForegroundColor();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                child: Container(
                  width: widget.isFullWidth ? double.infinity : null,
                  padding: padding,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
                    boxShadow:
                        widget.type == ButtonType.primary
                            ? DesignSystem.elevationColored(backgroundColor)
                            : DesignSystem.elevation2,
                  ),
                  child: Row(
                    mainAxisSize:
                        widget.isFullWidth
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: DesignSystem.iconSizeSm,
                          height: DesignSystem.iconSizeSm,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              foregroundColor,
                            ),
                          ),
                        )
                      else if (widget.icon != null)
                        widget.icon!,
                      if ((widget.icon != null || widget.isLoading) &&
                          widget.label.isNotEmpty)
                        const SizedBox(width: DesignSystem.space2),
                      if (widget.label.isNotEmpty)
                        Text(
                          widget.label,
                          style: textStyle.copyWith(color: foregroundColor),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return DesignSystem.neutral300;
    }

    switch (widget.type) {
      case ButtonType.primary:
        return DesignSystem.primaryBlue;
      case ButtonType.secondary:
        return DesignSystem.neutral200;
      case ButtonType.success:
        return DesignSystem.colorSuccess;
      case ButtonType.danger:
        return DesignSystem.colorError;
    }
  }

  Color _getForegroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.secondary:
        return DesignSystem.neutral700;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignSystem.space4,
          vertical: DesignSystem.space2,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignSystem.space6,
          vertical: DesignSystem.space4,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignSystem.space8,
          vertical: DesignSystem.space5,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return DesignSystem.labelMedium;
      case ButtonSize.medium:
        return DesignSystem.titleMedium;
      case ButtonSize.large:
        return DesignSystem.titleLarge;
    }
  }
}

enum ButtonType { primary, secondary, success, danger }

enum ButtonSize { small, medium, large }

/// Consistent icon button with press feedback
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final Color? backgroundColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = DesignSystem.iconSizeMd,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.space3),
          decoration: BoxDecoration(
            color: backgroundColor ?? DesignSystem.backgroundSecondary,
            borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
            boxShadow: DesignSystem.elevation2,
          ),
          child: Icon(
            icon,
            color: color ?? DesignSystem.neutral700,
            size: size,
          ),
        ),
      ),
    );
  }
}

/// Consistent card with elevation
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(DesignSystem.space4),
      decoration: BoxDecoration(
        color: backgroundColor ?? DesignSystem.backgroundSecondary,
        borderRadius: BorderRadius.circular(
          borderRadius ?? DesignSystem.radiusLg,
        ),
        boxShadow: DesignSystem.elevation2,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? DesignSystem.radiusLg,
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Consistent text field with design system styling
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.neutral700,
            ),
          ),
          const SizedBox(height: DesignSystem.space2),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          style: DesignSystem.bodyLarge.copyWith(
            color: DesignSystem.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.neutral400,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: DesignSystem.backgroundSecondary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.space4,
              vertical: DesignSystem.space4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.neutral200,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.neutral200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.colorError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.colorError,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              borderSide: const BorderSide(
                color: DesignSystem.neutral100,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading spinner with consistent styling
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? DesignSystem.primaryBlue,
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DesignSystem.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: DesignSystem.iconSizeXl,
                  color: DesignSystem.neutral400,
                ),
              ),
            const SizedBox(height: DesignSystem.space4),
            Text(
              title,
              style: DesignSystem.titleLarge.copyWith(
                color: DesignSystem.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: DesignSystem.space2),
              Text(
                description!,
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DesignSystem.space6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}




