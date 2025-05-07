import 'package:flutter/material.dart';

/// Single-line display component
class ExpandableRow extends StatelessWidget {
  final List<Widget> children;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;

  const ExpandableRow({
    super.key,
    required this.children,
    required this.isExpanded,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...children,
        Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Theme.of(context).iconTheme.color?.withAlpha(128),
        ),
      ],
    );
  }
}

/// Expandable component
class ExpandableWidget extends StatefulWidget {
  final Widget header;
  final Widget expandedContent;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final bool initiallyExpanded;
  final VoidCallback? onExpandChanged;
  final EdgeInsetsGeometry contentPadding;

  const ExpandableWidget({
    super.key,
    required this.header,
    required this.expandedContent,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
    this.initiallyExpanded = false,
    this.onExpandChanged,
    this.contentPadding = const EdgeInsets.all(8.0),
  });

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpandChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              hoverColor: Theme.of(context).hoverColor,
              splashColor: Theme.of(context).splashColor,
              mouseCursor: SystemMouseCursors.click,
              child: widget.header,
            ),
          ),
          if (_isExpanded)
            DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(179),
                  ),
              child: Padding(
                padding: widget.contentPadding,
                child: widget.expandedContent,
              ),
            ),
        ],
      ),
    );
  }
}
