import 'package:flutter/material.dart';
import 'package:chatmcp/utils/color.dart';

class InkIcon extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  final bool disabled;
  final Color? hoverColor;
  final String? tooltip;
  final Color? color;
  final double? size;
  final String? text;
  const InkIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.disabled = false,
    this.hoverColor,
    this.tooltip,
    this.color,
    this.size = 16,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        hoverColor: hoverColor ?? AppColors.getInkIconHoverColor(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: size, color: color),
              if (text != null) Text(text!),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return iconWidget;
    }

    return Tooltip(
      message: tooltip!,
      child: iconWidget,
    );
  }
}
