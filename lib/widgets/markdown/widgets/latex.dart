import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as m;

SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(
    tag: _latexTag,
    generator: (e, config, visitor) =>
        LatexNode(e.attributes, e.textContent, config));

const _latexTag = 'latex';

class LatexSyntax extends m.InlineSyntax {
  LatexSyntax()
      : super(
            r'(\$\$[\s\S]*?[\s\S]+?[\s\S]*?\$\$)|(\$.+?\$)|(\\\([\s\S]+?\\\))|(\\\[[\s\S]+?\\\])|(\[[\s\S]+?\])');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;
    const blockSyntax = '\$\$';
    const inlineSyntax = '\$';

    if (matchValue.startsWith(blockSyntax) &&
        matchValue.endsWith(blockSyntax) &&
        (matchValue != blockSyntax) &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2).trim();
      isInline = false;
    } else if (matchValue.startsWith(inlineSyntax) &&
        matchValue.endsWith(inlineSyntax) &&
        matchValue != inlineSyntax &&
        matchValue.length > 2) {
      content = matchValue.substring(1, matchValue.length - 1);
    } else if (matchValue.startsWith(r'\[') &&
        matchValue.endsWith(r'\]') &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    } else if (matchValue.startsWith(r'\(') &&
        matchValue.endsWith(r'\)') &&
        matchValue.length > 4) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = true;
    } else if (matchValue.startsWith('[') &&
        matchValue.endsWith(']') &&
        matchValue.length > 2) {
      content = matchValue.substring(1, matchValue.length - 1);
      isInline = false;
    }

    m.Element el = m.Element.text(_latexTag, matchValue);
    el.attributes['content'] = content;
    el.attributes['isInline'] = '$isInline';
    parser.addNode(el);
    return true;
  }
}

class LatexBlockSyntax extends m.BlockSyntax {
  @override
  RegExp get pattern => RegExp(
        r'^(?:(\${1,2})(?:\n|$))|(?:(?:\\\[(.+)\\\])(?:\n|$))',
        multiLine: true,
      );

  LatexBlockSyntax() : super();

  @override
  List<m.Line> parseChildLines(m.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match?[2] != null) {
      parser.advance();
      return [m.Line(match?[2] ?? '')];
    }

    final childLines = <m.Line>[];
    parser.advance();

    while (!parser.isDone) {
      final match = pattern.hasMatch(parser.current.content);
      if (!match) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  m.Node parse(m.BlockParser parser) {
    final lines = parseChildLines(parser);
    final content = lines.map((e) => e.content).join('\n').trim();
    final el = m.Element.text('latex', content);
    el.attributes['MathStyle'] = 'display';
    el.attributes['content'] = content;

    return m.Element('p', [el]);
  }
}

class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;

    if (content.isEmpty) return TextSpan(style: style, text: textContent);

    return WidgetSpan(
      alignment: isInline
          ? PlaceholderAlignment.middle
          : PlaceholderAlignment.aboveBaseline,
      baseline: TextBaseline.alphabetic,
      child: Math.tex(
        content,
        mathStyle: isInline ? MathStyle.text : MathStyle.display,
        textStyle: style.copyWith(
            fontSize: style.fontSize != null
                ? (isInline ? style.fontSize : style.fontSize! * 1.2)
                : (isInline ? 14.0 : 16.8)),
        onErrorFallback: (error) => Text('LaTeX Error: $error',
            style: style.copyWith(color: Colors.red)),
      ),
    );
  }
}
