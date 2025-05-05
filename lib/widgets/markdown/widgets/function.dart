import 'package:chatmcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:markdown_widget/markdown_widget.dart';
import 'package:chatmcp/utils/color.dart';
import 'tag.dart';
import 'package:chatmcp/utils/event_bus.dart';
import 'package:chatmcp/widgets/expandable_widget.dart';

const _functionTag = 'function';

class FunctionInlineSyntax extends TagInlineSyntax {
  FunctionInlineSyntax() : super(tag: _functionTag);
}

class FunctionBlockSyntax extends TagBlockSyntax {
  FunctionBlockSyntax() : super(tag: _functionTag);
}

SpanNodeGeneratorWithTag functionGenerator = SpanNodeGeneratorWithTag(
    tag: _functionTag,
    generator: (e, config, visitor) =>
        FunctionNode(e.attributes, e.textContent, config));

class FunctionNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  FunctionNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    bool isClosed = attributes['closed'] == 'true';
    return WidgetSpan(child: FunctionWidget(textContent, isClosed, attributes));
  }
}

class FunctionWidget extends StatefulWidget {
  final String textContent;
  final bool isClosed;
  final Map<String, String> attributes;

  const FunctionWidget(this.textContent, this.isClosed, this.attributes,
      {super.key});

  @override
  State<FunctionWidget> createState() => _FunctionWidgetState();
}

class _FunctionWidgetState extends State<FunctionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      backgroundColor: AppColors.getFunctionBackgroundColor(context),
      onExpandChanged: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      header: ExpandableRow(
        isExpanded: _isExpanded,
        children: [
          Icon(Icons.build_outlined,
              size: 14, color: AppColors.getFunctionIconColor(context)),
          Gap(size: 4),
          Expanded(
            child: Text("${widget.attributes['name']}: ${widget.textContent}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: AppColors.getFunctionTextColor(context))),
          ),
          if (!widget.isClosed)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: AppColors.getProgressIndicatorColor(context),
                strokeWidth: 1.5,
              ),
            )
          else if (widget.attributes['done'] != 'true')
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.play_arrow,
                color: AppColors.getPlayButtonColor(context),
              ),
              onPressed: () {
                final content = widget.attributes['content'] ?? '';
                final arguments = content.isEmpty
                    ? <String, dynamic>{}
                    : (jsonDecode(content) as Map).cast<String, dynamic>();
                emit(RunFunctionEvent(
                    widget.attributes['name'] ?? '', arguments));
              },
            ),
        ],
      ),
      expandedContent: Text(widget.textContent),
    );
  }
}
