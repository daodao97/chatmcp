import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  final Widget title;
  final Widget content;
  final EdgeInsetsGeometry? padding;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    this.padding,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 16,
                color: Colors.grey[600],
              ),
              Expanded(child: widget.title),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding:
                widget.padding ?? const EdgeInsets.only(top: 4.0, left: 8.0),
            child: widget.content,
          ),
      ],
    );
  }
}
