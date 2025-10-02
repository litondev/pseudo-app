import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;
  final String? text;
  final bool showText;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;

  const Spinner({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2.0,
    this.text,
    this.showText = false,
    this.alignment = MainAxisAlignment.center,
    this.padding,
  });

  const Spinner.small({
    super.key,
    this.color,
    this.strokeWidth = 2.0,
    this.text,
    this.showText = false,
    this.alignment = MainAxisAlignment.center,
    this.padding,
  }) : size = 16.0;

  const Spinner.medium({
    super.key,
    this.color,
    this.strokeWidth = 2.0,
    this.text,
    this.showText = false,
    this.alignment = MainAxisAlignment.center,
    this.padding,
  }) : size = 24.0;

  const Spinner.large({
    super.key,
    this.color,
    this.strokeWidth = 3.0,
    this.text,
    this.showText = false,
    this.alignment = MainAxisAlignment.center,
    this.padding,
  }) : size = 32.0;

  const Spinner.withText({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2.0,
    required this.text,
    this.alignment = MainAxisAlignment.center,
    this.padding,
  }) : showText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;
    final effectiveSize = size ?? 24.0;

    Widget spinner = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (showText && text != null) {
      spinner = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          spinner,
          const SizedBox(height: 12),
          Text(
            text!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: effectiveColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (padding != null) {
      spinner = Padding(
        padding: padding!,
        child: spinner,
      );
    }

    return spinner;
  }
}

class SpinnerOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? overlayColor;
  final Color? spinnerColor;
  final double? spinnerSize;

  const SpinnerOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.overlayColor,
    this.spinnerColor,
    this.spinnerSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Spinner.withText(
                  size: spinnerSize,
                  color: spinnerColor,
                  text: loadingText ?? 'Loading...',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SpinnerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Color? spinnerColor;
  final double spinnerSize;
  final ButtonStyle? style;

  const SpinnerButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.spinnerColor,
    this.spinnerSize = 16.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Spinner.small(
              color: spinnerColor ?? Colors.white,
            )
          : child,
    );
  }
}

class SpinnerIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isLoading;
  final Color? spinnerColor;
  final double spinnerSize;
  final String? tooltip;

  const SpinnerIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.spinnerColor,
    this.spinnerSize = 16.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      icon: isLoading
          ? Spinner.small(
              color: spinnerColor ?? Theme.of(context).primaryColor,
            )
          : icon,
    );
  }
}

class SpinnerCard extends StatelessWidget {
  final bool isLoading;
  final Widget? child;
  final String? loadingText;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? spinnerColor;

  const SpinnerCard({
    super.key,
    required this.isLoading,
    this.child,
    this.loadingText,
    this.padding,
    this.height,
    this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        child: isLoading
            ? Center(
                child: Spinner.withText(
                  text: loadingText ?? 'Loading...',
                  color: spinnerColor,
                ),
              )
            : child,
      ),
    );
  }
}