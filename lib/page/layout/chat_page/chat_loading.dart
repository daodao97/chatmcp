import 'package:flutter/material.dart';
import 'package:chatmcp/utils/color.dart';

class ChatLoading extends StatefulWidget {
  const ChatLoading({super.key});

  @override
  State<ChatLoading> createState() => _ChatLoadingState();
}

class _ChatLoadingState extends State<ChatLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: _animation.value,
                height: _animation.value,
                decoration: BoxDecoration(
                  color: AppColors.getChatLoadingColor(context),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
