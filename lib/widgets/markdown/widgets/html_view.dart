import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:chatmcp/generated/app_localizations.dart';

class HtmlView extends StatefulWidget {
  final String html;

  const HtmlView({
    super.key,
    required this.html,
  });

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  double _height = 300;
  InAppWebViewController? controller;
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  Key _webViewKey = UniqueKey();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initWebView(InAppWebViewController controller) async {
    this.controller = controller;
    try {
      await controller.loadData(data: widget.html);
    } catch (e) {
      debugPrint('Error loading WebView data: $e');
      _handleError();
    }
  }

  void _handleError() {
    if (_retryCount < maxRetries) {
      _retryCount++;
      _resetWebView();
    } else {
      setState(() => _hasError = true);
    }
  }

  void _resetWebView() {
    controller?.dispose();
    controller = null;
    setState(() => _webViewKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    if (_hasError) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('加载内容失败，请重试')),
      );
    }

    return SizedBox(
      height: _height,
      child: InAppWebView(
        key: _webViewKey,
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
          isInspectable: kDebugMode,
        ),
        onWebViewCreated: (controller) => _initWebView(controller),
        onLoadStop: (controller, url) async {
          try {
            final height = await controller.evaluateJavascript(
              source: 'document.body.scrollHeight',
            );
            if (mounted) setState(() => _height = (height as num).toDouble());
          } catch (e) {
            debugPrint('Error on load stop: $e');
            _handleError();
          }
        },
        onCreateWindow: (controller, request) => Future.value(false),
      ),
    );
  }
}
