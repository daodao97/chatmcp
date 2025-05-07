import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class LlmIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double size;

  const LlmIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : Colors.black;

    if (icon.isNotEmpty) {
      return ColorAwareSvg(
        assetName: 'assets/logo/$icon.svg',
        size: size,
        color: color ?? defaultColor,
      );
    }

    return ColorAwareSvg(
      assetName: 'assets/logo/ai-chip.svg',
      size: size,
      color: color ?? defaultColor,
    );
  }
}

class ColorAwareSvg extends StatelessWidget {
  final String assetName;
  final double size;
  final Color color;

  // Save the detection result static cache to avoid repeated detection
  static final Map<String, bool> _colorCache = {};

  const ColorAwareSvg({
    super.key,
    required this.assetName,
    required this.size,
    required this.color,
  });

  // Detect if the SVG contains non-black and white colors
  Future<bool> _detectSvgHasColors(BuildContext context) async {
    // If the result is cached, return directly
    if (_colorCache.containsKey(assetName)) {
      return _colorCache[assetName]!;
    }

    try {
      // Load the SVG file content
      final String svgString = await rootBundle.loadString(assetName);

      // Check if it contains color-related properties (simplified version)
      bool hasColor = false;

      // Check if it contains colors other than black and white
      if (svgString.contains('fill="#') || svgString.contains('stroke="#')) {
        // Exclude pure black (#000000) and pure white (#FFFFFF)
        hasColor = !svgString.contains('fill="#000000"') &&
            !svgString.contains('fill="#ffffff"') &&
            !svgString.contains('stroke="#000000"') &&
            !svgString.contains('stroke="#ffffff"');
      }

      // Check if it contains rgb/rgba/hsl colors
      if (!hasColor) {
        hasColor = svgString.contains('fill="rgb') ||
            svgString.contains('stroke="rgb') ||
            svgString.contains('fill="hsl') ||
            svgString.contains('stroke="hsl');
      }

      _colorCache[assetName] = hasColor;
      return hasColor;
    } catch (e) {
      // When an error occurs, assume there is no color
      _colorCache[assetName] = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Detect if the SVG has custom colors
      future: _detectSvgHasColors(context),
      builder: (context, snapshot) {
        // Show placeholder when loading
        if (!snapshot.hasData) {
          return SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        // Determine whether to apply color filter based on detection results
        final hasOwnColors = snapshot.data ?? false;
        return SvgPicture.asset(
          assetName,
          width: size,
          height: size,
          placeholderBuilder: (context) => Icon(
            CupertinoIcons.cloud,
            size: size,
          ),
          // If the SVG has its own colors, do not apply colorFilter
          colorFilter:
              hasOwnColors ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      },
    );
  }
}
