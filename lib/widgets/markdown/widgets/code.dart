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
  bool _isPreviewVisible = false;
  bool _isSupportPreview = false;
  Widget? previewWidget;
  @override
  bool get wantKeepAlive => true;

  final List<String> _supportedLanguages = ['mermaid', 'html', 'svg'];

  final List<String> _htmlLanguages = ['html', 'svg'];

  @override
  void initState() {
    super.initState();
    bool supportPreview = false;
    if (_supportedLanguages.contains(widget.language)) {
      supportPreview = true;
      // 在初始化时创建预览组件
      previewWidget = _buildPreviewWidget();
    }

    setState(() {
      _isSupportPreview = supportPreview;
      if (supportPreview && widget.isClosed) {
        _isPreviewVisible = true;
        print('widget.isClosed: ${widget.isClosed}');
      }
    });
  }

  Widget? _buildPreviewWidget() {
    if (widget.language == 'mermaid') {
      return MermaidDiagramView(
        key: ValueKey(widget.code), // 使用基于内容的Key
        code: widget.code,
      );
    } else if (_htmlLanguages.contains(widget.language)) {
      return HtmlView(
        key: ValueKey(widget.code), // 使用基于内容的Key
        html: widget.code,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    super.build(context);
    return Container(
      width: double.infinity,
      decoration: widget.preConfig.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildToolBar(t),
          // if (_isSupportPreview)
          //   Offstage(
          //     offstage: !_isPreviewVisible,
          //     child: previewWidget!,
          //   ),
          if (_isSupportPreview && _isPreviewVisible) previewWidget!,
          // if (!_isPreviewVisible) ...buildCodeBlockList(),
          if (!_isPreviewVisible)
            HighlightView(
              widget.code,
              language: widget.language,
              theme: widget.preConfig.theme,
              padding: const EdgeInsets.all(5),
            ),
        ],
      ),
    );
  }

  Widget buildToolBar(AppLocalizations t) {
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
          Text(
            widget.language.isEmpty ? 'text' : widget.language,
            style: TextStyle(
              color: AppColors.getCodeBlockLanguageTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: const Icon(Icons.copy, size: 14),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.codeCopiedToClipboard),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (_isSupportPreview) ...[
                Gap(size: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(20, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor:
                        AppColors.getCodePreviewButtonBackgroundColor(context),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPreviewVisible = !_isPreviewVisible;
                    });
                  },
                  child: Text(
                    _isPreviewVisible ? 'Code' : 'Preview',
                    style: const TextStyle(fontSize: 9, height: 1),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

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
    // 获取开始标记和语言
    final match = pattern.firstMatch(parser.current.content)!;
    final openingFence = match.group(1)!;
    final infoString = match.group(2)!.trim();

    bool isClosed = false;
    final lines = <String>[];

    // 前进到内容行
    parser.advance();

    // 收集内容直到找到结束标记
    while (!parser.isDone) {
      final currentLine = parser.current.content;
      final closingMatch = pattern.firstMatch(currentLine);

      // 检查是否是结束标记
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

    // 如果最后一行是空行且未找到结束标记，移除它
    if (!isClosed && lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }

    // 创建代码元素
    final code = m.Element.text('code', lines.join('\n') + '\n');

    // 如果有语言标记，添加 class
    if (infoString.isNotEmpty) {
      code.attributes['class'] = 'language-$infoString';
    }

    // 添加是否闭合的标记
    code.attributes['isClosed'] = isClosed.toString();

    // 创建 pre 元素
    final pre = m.Element('pre', [code]);
    pre.attributes['isClosed'] = isClosed.toString();

    return pre;
  }
}
