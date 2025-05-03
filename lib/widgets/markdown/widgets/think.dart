import 'package:flutter/material.dart';
import 'package:chatmcp/generated/app_localizations.dart';

import 'package:markdown_widget/markdown_widget.dart';
import 'package:chatmcp/utils/color.dart';
import '../markit_widget.dart';
import 'tag.dart';
import 'package:chatmcp/widgets/expandable_widget.dart';

class ThinkInlineSyntax extends TagInlineSyntax {
  ThinkInlineSyntax() : super(tag: "think");
}

class ThinkBlockSyntax extends TagBlockSyntax {
  ThinkBlockSyntax() : super(tag: "think");
}

SpanNodeGeneratorWithTag thinkGenerator = SpanNodeGeneratorWithTag(
    tag: _thinkTag,
    generator: (e, config, visitor) =>
        ThinkNode(e.attributes, e.textContent, config));

const _thinkTag = 'think';

class ThinkNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  ThinkNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    bool isClosed = attributes['closed'] == 'true';
    return WidgetSpan(child: ThinkWidget(textContent, isClosed, attributes));
  }
}

class ThinkWidget extends StatefulWidget {
  final String textContent;
  final bool isClosed;
  final Map<String, String> attributes;

  const ThinkWidget(this.textContent, this.isClosed, this.attributes,
      {super.key});

  @override
  State<ThinkWidget> createState() => _ThinkWidgetState();
}

class _ThinkWidgetState extends State<ThinkWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    String startTime = widget.attributes['start-time'] ?? '';
    String endTime = widget.attributes['end-time'] ?? '';

    String prefix = t.thinkingProcess;
    String durationTips = '';
    if (startTime.isNotEmpty) {
      if (endTime.isEmpty) {
        endTime = DateTime.now().toIso8601String();
        prefix = t.thinkingProcessWithDuration;
      } else {
        prefix = t.thinkingEndWithDuration;
      }
      Duration duration =
          DateTime.parse(endTime).difference(DateTime.parse(startTime));
      durationTips = " ${t.seconds(duration.inSeconds)}";
    }

    if (widget.isClosed) {
      prefix = t.thinkingEndComplete;
      if (durationTips.isNotEmpty) {
        prefix += ', ';
      }
    }

    return ExpandableWidget(
      backgroundColor: AppColors.getFunctionBackgroundColor(context),
      initiallyExpanded: true,
      onExpandChanged: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      header: ExpandableRow(
        isExpanded: _isExpanded,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 14,
            color: AppColors.getThinkIconColor(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "$prefix$durationTips",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.getThinkTextColor(context)),
            ),
          ),
          if (!widget.isClosed)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: AppColors.getProgressIndicatorColor(context),
                strokeWidth: 1.5,
              ),
            ),
        ],
      ),
      expandedContent: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.getThinkIconColor(context).withAlpha(128),
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: Markit(data: widget.textContent),
      ),
      contentPadding: const EdgeInsets.only(left: 5),
    );
  }
}
