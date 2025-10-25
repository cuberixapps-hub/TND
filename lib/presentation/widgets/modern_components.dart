import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/modern_design_system.dart';

/// Modern button with microinteractions
class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final ButtonSize size;
  final bool isOutlined;
  final double? width;

  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernDesignSystem.durationQuick,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final backgroundColor =
        widget.backgroundColor ?? ModernDesignSystem.primaryColor;
    final textColor =
        widget.textColor ??
        (widget.isOutlined ? backgroundColor : Colors.white);

    final padding = _getPadding();
    final height = _getHeight();
    final textStyle = _getTextStyle();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.03),
            child: AnimatedContainer(
              duration: ModernDesignSystem.durationQuick,
              width: widget.width,
              height: height,
              decoration: BoxDecoration(
                color:
                    widget.isOutlined
                        ? Colors.transparent
                        : (isDisabled
                            ? ModernDesignSystem.neutral300
                            : backgroundColor),
                borderRadius: BorderRadius.circular(height / 2),
                border:
                    widget.isOutlined
                        ? Border.all(
                          color:
                              isDisabled
                                  ? ModernDesignSystem.neutral300
                                  : backgroundColor,
                          width: 2,
                        )
                        : null,
                boxShadow:
                    widget.isOutlined || isDisabled
                        ? null
                        : _isPressed
                        ? ModernDesignSystem.elevationLight
                        : ModernDesignSystem.elevationMedium,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(height / 2),
                  splashColor: textColor.withOpacity(0.1),
                  highlightColor: textColor.withOpacity(0.05),
                  child: Padding(
                    padding: padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: textStyle.fontSize! + 2,
                            height: textStyle.fontSize! + 2,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDisabled
                                    ? ModernDesignSystem.neutral500
                                    : textColor,
                              ),
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(
                            widget.icon,
                            size: textStyle.fontSize! + 4,
                            color:
                                isDisabled
                                    ? ModernDesignSystem.neutral500
                                    : textColor,
                          ),
                        if ((widget.icon != null || widget.isLoading) &&
                            widget.label.isNotEmpty)
                          const SizedBox(width: ModernDesignSystem.space2),
                        if (widget.label.isNotEmpty)
                          Text(
                            widget.label,
                            style: textStyle.copyWith(
                              color:
                                  isDisabled
                                      ? ModernDesignSystem.neutral500
                                      : textColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: ModernDesignSystem.space4,
          vertical: ModernDesignSystem.space2,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: ModernDesignSystem.space6,
          vertical: ModernDesignSystem.space3,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: ModernDesignSystem.space8,
          vertical: ModernDesignSystem.space4,
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return ModernDesignSystem.labelMedium;
      case ButtonSize.medium:
        return ModernDesignSystem.titleMedium;
      case ButtonSize.large:
        return ModernDesignSystem.titleLarge;
    }
  }
}

enum ButtonSize { small, medium, large }

/// Modern card with subtle animations
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;
  final bool showShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? ModernDesignSystem.surfaceColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? ModernDesignSystem.radiusLg,
        ),
        boxShadow: showShadow ? ModernDesignSystem.elevationLight : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? ModernDesignSystem.radiusLg,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: ModernDesignSystem.primaryColor.withOpacity(0.05),
            highlightColor: ModernDesignSystem.primaryColor.withOpacity(0.03),
            child: Padding(
              padding:
                  padding ?? const EdgeInsets.all(ModernDesignSystem.space5),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return content
          .animate()
          .scale(
            duration: ModernDesignSystem.durationQuick,
            begin: const Offset(1, 1),
            end: const Offset(0.98, 0.98),
            curve: ModernDesignSystem.curveGentle,
          )
          .then()
          .scale(
            duration: ModernDesignSystem.durationQuick,
            begin: const Offset(0.98, 0.98),
            end: const Offset(1, 1),
            curve: ModernDesignSystem.curveGentle,
          );
    }

    return content;
  }
}

/// Modern text field with floating label
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;

  const ModernTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late FocusNode _focusNode;
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationNormal,
      vsync: this,
    );
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _focusNode = _internalFocusNode!;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: ModernDesignSystem.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            style: ModernDesignSystem.bodyLarge.copyWith(
              color: ModernDesignSystem.neutral900,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: ModernDesignSystem.bodyMedium.copyWith(
                color:
                    _isFocused
                        ? ModernDesignSystem.primaryColor
                        : ModernDesignSystem.neutral500,
              ),
              hintStyle: ModernDesignSystem.bodyMedium.copyWith(
                color: ModernDesignSystem.neutral400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: ModernDesignSystem.surfaceColor,
              contentPadding: const EdgeInsets.all(ModernDesignSystem.space5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                borderSide: BorderSide(
                  color: ModernDesignSystem.neutral200,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                borderSide: BorderSide(
                  color: ModernDesignSystem.neutral200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                borderSide: BorderSide(
                  color: ModernDesignSystem.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                borderSide: BorderSide(
                  color: ModernDesignSystem.colorError,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                borderSide: BorderSide(
                  color: ModernDesignSystem.colorError,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Modern toggle switch
class ModernToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const ModernToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? ModernDesignSystem.primaryColor;
    final inactive = inactiveColor ?? ModernDesignSystem.neutral300;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: ModernDesignSystem.durationNormal,
        curve: ModernDesignSystem.curveSmooth,
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusFull),
          color: value ? active : inactive,
          boxShadow: [
            BoxShadow(
              color: (value ? active : Colors.black).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: ModernDesignSystem.durationNormal,
              curve: ModernDesignSystem.curveSmooth,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusFull,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
