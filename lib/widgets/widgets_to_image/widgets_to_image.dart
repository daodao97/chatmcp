import 'package:flutter/material.dart';
import 'utils.dart';

class WidgetsToImage extends StatelessWidget {
  final Widget? child;
  final WidgetsToImageController controller;
  // Add new property
  final bool captureAll;

  const WidgetsToImage({
    super.key,
    required this.child,
    required this.controller,
    this.captureAll = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    if (!captureAll) {
      return RepaintBoundary(
        key: controller.containerKey,
        child: child,
      );
    }

    // Wrap with SingleChildScrollView to ensure all content is rendered
    return RepaintBoundary(
      key: controller.containerKey,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}
