import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:chatmcp/utils/color.dart';

SpanNodeGeneratorWithTag linkGenerator = SpanNodeGeneratorWithTag(
    tag: _linkTag,
    generator: (e, config, visitor) => MyLinkNode(
        e.attributes, e.textContent, config, visitor.widgetVisitor.context!));

const _linkTag = 'a';

class MyLinkNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;
  final BuildContext context; // Added context

  MyLinkNode(this.attributes, this.textContent, this.config, this.context); // Added context

  @override
  InlineSpan build() {
    final href = attributes['href'] ?? '';
    final content = attributes['content'] ?? href;
    return TextSpan(
      text: content,
      style: TextStyle(
        color: AppColors.getLinkColor(context), // Pass context here
        decoration: TextDecoration.none,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final url = href;
          if (url.startsWith("#")) {
            return;
          }
          launchUrl(Uri.parse(url));
        },
    );
  }
}

class LinkSyntax extends md.InlineSyntax {
  LinkSyntax() : super(r'\[([^\]]*)\]\(([^\)]+)\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final element = md.Element.text('a', match.group(1) ?? '');
    element.attributes['href'] = match.group(2) ?? '';
    element.attributes['content'] = match.group(1) ?? '';
    parser.addNode(element);
    return true;
  }
}
