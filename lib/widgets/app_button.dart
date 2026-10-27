import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, danger, outlined }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case AppButtonType.secondary:
        backgroundColor = theme.colorScheme.secondaryContainer;
        foregroundColor = theme.colorScheme.onSecondaryContainer;
        break;
      case AppButtonType.danger:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = theme.colorScheme.onError;
        break;
      case AppButtonType.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        borderSide = BorderSide(color: theme.colorScheme.primary);
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: type == AppButtonType.outlined ? 0 : 2,
      side: borderSide,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    );

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          );

    final button = ElevatedButton(
      style: buttonStyle,
      onPressed: isLoading ? null : onPressed,
      child: content,
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
