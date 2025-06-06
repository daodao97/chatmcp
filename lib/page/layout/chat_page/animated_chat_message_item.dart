import 'package:flutter/material.dart';

class AnimatedChatMessageItem extends StatefulWidget {
  final Widget child;

  const AnimatedChatMessageItem({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedChatMessageItem> createState() => _AnimatedChatMessageItemState();
}

class _AnimatedChatMessageItemState extends State<AnimatedChatMessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350), // Slightly longer for a smoother feel
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15), // Start a bit lower
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart, // A slightly more expressive curve
    ));

    // Only play animation if the widget is mounted
    // This helps prevent animations from playing on already visible items during a hot reload or quick scroll.
    // For a true "animate only once on first appearance", more complex logic involving visibility detection
    // or tracking displayed items would be needed, but for chat, this is often a good balance.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
