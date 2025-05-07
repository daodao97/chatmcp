import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

// Attribute matching regular expression
final attributeRegex =
    RegExp(r'''([\w-]+)\s*=\s*(?:["']([^"'>]+)["']|([^\s>"']+))''');

class TagInlineSyntax extends md.InlineSyntax {
  final String tag;

  TagInlineSyntax({required this.tag, bool caseSensitive = false})
      : super(_getPattern(tag), caseSensitive: caseSensitive);

  static String _getPattern(String tag) =>
      r'<' + tag + r'\s*([^>]*)>\s*([^<]*)(?:</' + tag + r'\s*([^>]*)>\s*)?';

  Map<String, String> _parseAttributes(String attributeString) {
    final attributes = <String, String>{};
    final matches = attributeRegex.allMatches(attributeString);

    for (final match in matches) {
      if (match.groupCount >= 1) {
        final key = match.group(1) ?? '';
        // The value may be in the quote group or the non-quote group
        final value = match.group(2) ?? match.group(3) ?? '';
        if (key.isNotEmpty) {
          attributes[key] = value;
        }
      }
    }
    return attributes;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final openingAttributes = _parseAttributes(match[1] ?? '');
    final content = match[2]!.trim();
    final closingAttributes =
        match[3] != null ? _parseAttributes(match[3]!) : <String, String>{};

    final element = md.Element(tag, [md.Text(content)]);

    // Merge the attributes of the start and end tags
    element.attributes.addAll(openingAttributes);
    element.attributes.addAll(closingAttributes);

    element.attributes['content'] = content;
    element.attributes['isInline'] = 'true';
    element.attributes['closed'] = match[3] != null ? 'true' : 'false';

    parser.addNode(element);
    return true;
  }
}

class TagBlockSyntax extends md.BlockSyntax {
  final String tag;

  TagBlockSyntax({required this.tag});

  @protected
  RegExp get startPattern => RegExp(r'^<' + tag + r'\s*([^>]*)>\s*$');

  @protected
  RegExp get endPattern => RegExp(r'^</' + tag + r'\s*([^>]*)>\s*$');

  @override
  RegExp get pattern => startPattern;

  Map<String, String> _parseAttributes(String attributeString) {
    final attributes = <String, String>{};
    final matches = attributeRegex.allMatches(attributeString);

    for (final match in matches) {
      if (match.groupCount >= 1) {
        final key = match.group(1) ?? '';
        // The value may be in the quote group or the non-quote group
        final value = match.group(2) ?? match.group(3) ?? '';
        if (key.isNotEmpty) {
          attributes[key] = value;
        }
      }
    }
    return attributes;
  }

  @override
  bool canParse(md.BlockParser parser) {
    final match = startPattern.firstMatch(parser.current.content);
    return match != null;
  }

  @override
  md.Node parse(md.BlockParser parser) {
    final startMatch = startPattern.firstMatch(parser.current.content);
    final openingAttributes = startMatch != null
        ? _parseAttributes(startMatch[1] ?? '')
        : <String, String>{};

    final lines = <String>[];
    parser.advance(); // Skip the opening tag

    bool isClosed = false;
    Map<String, String> closingAttributes = {};

    while (!parser.isDone) {
      final line = parser.current.content;
      final endMatch = endPattern.firstMatch(line);
      if (endMatch != null) {
        isClosed = true;
        closingAttributes = _parseAttributes(endMatch[1] ?? '');
        parser.advance();
        break;
      }
      lines.add(line);
      parser.advance();
    }

    final content = lines.join('\n');
    md.Element el = md.Element.text(tag, content);

    // Merge the attributes of the start and end tags
    el.attributes.addAll(openingAttributes);
    el.attributes.addAll(closingAttributes);

    el.attributes['content'] = content;
    el.attributes['isInline'] = 'false';
    el.attributes['closed'] = isClosed ? 'true' : 'false';
    return el;
  }
}
