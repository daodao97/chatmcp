import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:chatmcp/widgets/markdown/markit_widget.dart';
import 'package:chatmcp/components/widgets/base.dart';

const _detailsTag = 'details';

class DetailConfig extends WidgetConfig {
  @override
  String get tag => _detailsTag;

  final TextStyle? summaryStyle;
  final TextStyle? contentStyle;

  DetailConfig({
    required BuildContext context,
    TextStyle? summaryStyle,
    TextStyle? contentStyle,
  }) : summaryStyle = summaryStyle ?? FontUtils.getPlatformTextStyle(
          context: context,
          size: 14,
          fontWeight: FontWeight.bold,
        ),
        contentStyle = contentStyle ?? FontUtils.getPlatformTextStyle(
          context: context,
          size: 14,
        );
}

class DetailsWidget extends StatefulWidget {
  final String textContent;
  final Map<String, String> attributes;

  const DetailsWidget(this.textContent, this.attributes, {super.key});

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final summary = widget.attributes['summary'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Icon(
                _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 20,
              ),
              Expanded(child: Text(summary)),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Markit(data: widget.textContent),
          ),
      ],
    );
  }
}

class DetailsNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  DetailsNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: DetailsWidget(textContent, attributes),
    );
  }
}

SpanNodeGeneratorWithTag detailsGenerator = SpanNodeGeneratorWithTag(
  tag: _detailsTag,
  generator: (e, config, visitor) =>
      DetailsNode(e.attributes, e.textContent, config),
);

class DetailsSyntax extends md.InlineSyntax {
  DetailsSyntax()
      : super(
            r'<details\s*([^>]*)>([^<]*)<summary>(.*?)</summary>(.*?)</details>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final summary = match[3]!.trim();
    final content = match[4]!.trim();

    final element = md.Element(_detailsTag, [md.Text(content)]);
    element.attributes['summary'] = summary;
    element.attributes['content'] = content;

    parser.addNode(element);
    return true;
  }
}

class DetailsBlockSyntax extends md.BlockSyntax {
  static final _startPattern = RegExp(r'^<details\s*([^>]*)>$');
  static final _summaryPattern = RegExp(r'^<summary>(.*?)</summary>$');
  static final _endPattern = RegExp(r'^</details>$');

  @override
  RegExp get pattern => _startPattern;

  @override
  bool canParse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    return match != null;
  }

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();

    String? summary;
    if (!parser.isDone) {
      final summaryMatch = _summaryPattern.firstMatch(parser.current.content);
      if (summaryMatch != null) {
        summary = summaryMatch[1]?.trim();
        parser.advance();
      }
    }

    final lines = <String>[];
    while (!parser.isDone) {
      final line = parser.current.content;
      if (_endPattern.hasMatch(line)) {
        parser.advance();
        break;
      }
      lines.add(line);
      parser.advance();
    }

    final content = lines.join('\n');
    final element = md.Element(_detailsTag, [md.Text(content)]);
    if (summary != null) {
      element.attributes['summary'] = summary;
    }
    element.attributes['content'] = content;

    return element;
  }
}
