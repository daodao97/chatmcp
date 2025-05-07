import 'package:chatmcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:chatmcp/utils/color.dart';
import 'package:flutter/services.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import 'mermaid_diagram_view.dart' show MermaidDiagramView;
import 'html_view.dart';

SpanNodeGeneratorWithTag codeBlockGenerator = SpanNodeGeneratorWithTag(
    tag: "pre",
    generator: (e, config, visitor) => CodeBlockNode(e, config.pre, visitor));

class CodeBlockNode extends ElementNode {
  CodeBlockNode(this.element, this.preConfig, this.visitor);

  String get content => element.textContent;
  final PreConfig preConfig;
  final m.Element element;
  final WidgetVisitor visitor;

  @override
  InlineSpan build() {
    // m.ExtensionSet
    String? language = preConfig.language;
    try {
      final firstChild = element.children?.firstOrNull;
      if (firstChild is m.Element) {
        language = firstChild.attributes['class']?.split('-').lastOrNull;
      }
    } catch (e) {
      language = null;
      debugPrint('get language error:$e');
    }
    final splitContents = content
        .trim()
        .split(visitor.splitRegExp ?? WidgetVisitor.defaultSplitRegExp);
    if (splitContents.last.isEmpty) splitContents.removeLast();

    final codeBuilder = preConfig.builder;
    if (codeBuilder != null) {
      return WidgetSpan(child: codeBuilder.call(content, language ?? ''));
    }

    bool isClosed = element.attributes['isClosed'] == 'true';

    final widget = Container(
      width: double.infinity,
      child: _CodeBlock(
          code: content,
          language: language ?? '',
          isClosed: isClosed,
          preConfig: preConfig,
          splitContents: splitContents,
          visitor: visitor),
    );
    return WidgetSpan(
        child:
            preConfig.wrapper?.call(widget, content, language ?? '') ?? widget);
  }

  @override
  TextStyle get style => preConfig.textStyle.merge(parentStyle);
}

class _CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final bool isClosed;
  final PreConfig preConfig;
  final WidgetVisitor visitor;
  final List<String> splitContents;

  const _CodeBlock({
    required this.code,
    required this.language,
    required this.isClosed,
    required this.preConfig,
    required this.splitContents,
    required this.visitor,
  });

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock>
    with AutomaticKeepAliveClientMixin {
  // Whether to display preview
  bool _isPreviewVisible = false;
  // Whether to support preview
  bool _isSupportPreview = false;
  // Preview component
  Widget? _previewWidget;

  // Supported preview languages list
  static const List<String> _supportedLanguages = ['mermaid', 'html', 'svg'];
  // HTML related languages
  static const List<String> _htmlLanguages = ['html', 'svg'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePreviewState();
  }

  /// Initialize preview state
  void _initializePreviewState() {
    final bool supportPreview = _supportedLanguages.contains(widget.language);

    if (supportPreview) {
      _previewWidget = _buildPreviewWidget();
    }

    print('widget.isClosed: ${widget.isClosed}');

    setState(() {
      _isSupportPreview = supportPreview;
      // If support preview and code block is closed, default to display preview
      _isPreviewVisible = supportPreview && widget.isClosed;
    });
  }

  /// Build preview component
  Widget? _buildPreviewWidget() {
    if (widget.language == 'mermaid') {
      return MermaidDiagramView(
        key: ValueKey(widget.code),
        code: widget.code,
      );
    } else if (_htmlLanguages.contains(widget.language)) {
      return HtmlView(
        key: ValueKey(widget.code),
        html: widget.code,
      );
    }
    return null;
  }

  /// Toggle preview/code view
  void _togglePreviewVisibility() {
    setState(() {
      _isPreviewVisible = !_isPreviewVisible;
    });
  }

  /// Copy code to clipboard
  void _copyCodeToClipboard(BuildContext context, AppLocalizations t) {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.codeCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    super.build(context);

    return Container(
      width: double.infinity,
      decoration: widget.preConfig.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolBar(t),
          _buildContentSection(),
        ],
      ),
    );
  }

  /// Build content area (code or preview)
  Widget _buildContentSection() {
    if (_isSupportPreview && _isPreviewVisible && _previewWidget != null) {
      return _previewWidget!;
    } else {
      return HighlightView(
        widget.code,
        language: widget.language,
        theme: widget.preConfig.theme,
        padding: const EdgeInsets.all(5),
      );
    }
  }

  /// Build toolbar
  Widget _buildToolBar(AppLocalizations t) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.getCodeBlockToolbarBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLanguageLabel(),
          const Spacer(),
          _buildToolbarActions(t),
        ],
      ),
    );
  }

  /// Build language label
  Widget _buildLanguageLabel() {
    return Text(
      widget.language.isEmpty ? 'text' : widget.language,
      style: TextStyle(
        color: AppColors.getCodeBlockLanguageTextColor(context),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Build toolbar actions
  Widget _buildToolbarActions(AppLocalizations t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          child: const Icon(Icons.copy, size: 14),
          onTap: () => _copyCodeToClipboard(context, t),
        ),
        if (_isSupportPreview) ...[
          Gap(size: 8),
          _buildPreviewToggleButton(),
        ]
      ],
    );
  }

  /// Build preview toggle button
  Widget _buildPreviewToggleButton() {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(20, 20),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: AppColors.getCodePreviewButtonBackgroundColor(context),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
      onPressed: _togglePreviewVisibility,
      child: Text(
        _isPreviewVisible ? 'Code' : 'Preview',
        style: const TextStyle(fontSize: 9, height: 1),
      ),
    );
  }

  /// Build code block list
  List<Widget> buildCodeBlockList() {
    return List.generate(widget.splitContents.length, (index) {
      final currentContent = widget.splitContents[index];
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProxyRichText(
            TextSpan(
              children: highLightSpans(
                currentContent,
                language: widget.preConfig.language,
                theme: widget.preConfig.theme,
                textStyle: widget.preConfig.textStyle,
                styleNotMatched: widget.preConfig.styleNotMatched,
              ),
            ),
            richTextBuilder: widget.visitor.richTextBuilder,
          ));
    });
  }
}

class FencedCodeBlockSyntax extends m.BlockSyntax {
  static final _pattern = RegExp(r'^[ ]{0,3}(~{3,}|`{3,})(.*)$');

  @override
  RegExp get pattern => _pattern;

  const FencedCodeBlockSyntax();

  @override
  m.Node parse(m.BlockParser parser) {
    // Get start mark and language
    final match = pattern.firstMatch(parser.current.content)!;
    final openingFence = match.group(1)!;
    final infoString = match.group(2)!.trim();

    bool isClosed = false;
    final lines = <String>[];

    // Advance to content line
    parser.advance();

    // Collect content until finding the end mark
    while (!parser.isDone) {
      final currentLine = parser.current.content;
      final closingMatch = pattern.firstMatch(currentLine);

      // Check if it is the end mark
      if (closingMatch != null &&
          closingMatch.group(1)!.startsWith(openingFence) &&
          closingMatch.group(2)!.trim().isEmpty) {
        isClosed = true;
        parser.advance();
        break;
      }

      lines.add(currentLine);
      parser.advance();
    }

    // If the last line is an empty line and the end mark is not found, remove it
    if (!isClosed && lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }

    // Create code element
    final code = m.Element.text('code', lines.join('\n') + '\n');

    // If there is a language mark, add class
    if (infoString.isNotEmpty) {
      code.attributes['class'] = 'language-$infoString';
    }

    // Add the closed mark
    code.attributes['isClosed'] = isClosed.toString();

    // Create pre element
    final pre = m.Element('pre', [code]);
    pre.attributes['isClosed'] = isClosed.toString();

    return pre;
  }
}
