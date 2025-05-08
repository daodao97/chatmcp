import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'think.dart';
import 'package:chatmcp/utils/event_bus.dart';

import 'tag.dart';

SpanNodeGeneratorWithTag artifactAntThinkingGenerator =
    SpanNodeGeneratorWithTag(
        tag: _artifactAntThinkingTag,
        generator: (e, config, visitor) =>
            ArtifactAntThinkingNode(e.attributes, e.textContent, config));

const _artifactAntThinkingTag = 'antThinking';

class ArtifactAntThinkingInlineSyntax extends TagInlineSyntax {
  static const tagName = _artifactAntThinkingTag;
  ArtifactAntThinkingInlineSyntax() : super(tag: tagName, caseSensitive: false);
}

class ArtifactAntThinkingBlockSyntax extends TagBlockSyntax {
  static const tagName = _artifactAntThinkingTag;
  ArtifactAntThinkingBlockSyntax() : super(tag: tagName);
}

class ArtifactAntThinkingNode extends ThinkNode {
  ArtifactAntThinkingNode(super.attributes, super.textContent, super.config);
  @override
  InlineSpan build() {
    return WidgetSpan(
        child: ArtifactAntThinkingWidget(textContent, attributes));
  }
}

class ArtifactAntThinkingWidget extends StatelessWidget {
  final String textContent;
  final Map<String, String> attributes;

  const ArtifactAntThinkingWidget(this.textContent, this.attributes,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableText(textContent);
  }
}

SpanNodeGeneratorWithTag artifactAntArtifactGenerator =
    SpanNodeGeneratorWithTag(
        tag: _artifactAntArtifactTag,
        generator: (e, config, visitor) =>
            ArtifactAntArtifactNode(e.attributes, e.textContent, config));

const _artifactAntArtifactTag = 'antArtifact';

class ArtifactAntArtifactInlineSyntax extends TagInlineSyntax {
  static const tagName = _artifactAntArtifactTag;
  ArtifactAntArtifactInlineSyntax() : super(tag: tagName, caseSensitive: false);
}

class ArtifactAntArtifactBlockSyntax extends TagBlockSyntax {
  static const tagName = _artifactAntArtifactTag;
  ArtifactAntArtifactBlockSyntax() : super(tag: tagName);
}

class ArtifactAntArtifactNode extends ThinkNode {
  ArtifactAntArtifactNode(super.attributes, super.textContent, super.config);
  @override
  InlineSpan build() {
    return WidgetSpan(
        child: ArtifactAntArtifactWidget(textContent, attributes));
  }
}

class ArtifactAntArtifactWidget extends StatefulWidget {
  final String textContent;
  final Map<String, String> attributes;

  const ArtifactAntArtifactWidget(this.textContent, this.attributes,
      {super.key});

  @override
  State<ArtifactAntArtifactWidget> createState() =>
      _ArtifactAntArtifactWidgetState();
}

class _ArtifactAntArtifactWidgetState extends State<ArtifactAntArtifactWidget> {
  @override
  Widget build(BuildContext context) {
    String title = widget.attributes['title'] ?? '';
    bool isClosed = widget.attributes['closed'] == 'true';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ProviderManager.chatProvider.setArtifactEvent(
          CodePreviewEvent(widget.textContent, widget.attributes),
        );
      }
    });

    return InkWell(
      onTap: () {
        ProviderManager.chatProvider.setShowCodePreview(true);
      },
      child: Container(
        width: 300,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.getArtifactBackgroundColor(context),
          border: Border.all(
            color: AppColors.getArtifactBorderColor(context),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            if (isClosed)
              Icon(Icons.check_circle, color: Colors.green)
            else
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  color: AppColors.getProgressIndicatorColor(context),
                  strokeWidth: 1.5,
                ),
              )
          ],
        ),
      ),
    );
  }
}
