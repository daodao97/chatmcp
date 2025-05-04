import 'package:flutter/material.dart';

class InkIcon extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  final bool disabled;
  final Color? hoverColor;
  final String? tooltip;
  final Color? color;
  final double? size;
  const InkIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.disabled = false,
    this.hoverColor,
    this.tooltip,
    this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = InkWell(
      onTap: disabled ? null : onTap,
      hoverColor: hoverColor ?? Colors.grey.shade200,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Icon(icon, size: size, color: color),
      ),
    );

    if (tooltip != null) {
      iconWidget = Tooltip(
        message: tooltip!,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
