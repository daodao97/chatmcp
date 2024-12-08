import 'package:flutter/material.dart';

class InputArea extends StatelessWidget {
  final TextEditingController textController;
  final bool isComposing;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onSubmitted;

  const InputArea({
    super.key,
    required this.textController,
    required this.isComposing,
    required this.onTextChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  onChanged: onTextChanged,
                  onSubmitted: onSubmitted,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed:
                    isComposing ? () => onSubmitted(textController.text) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
