import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:chatmcp/generated/app_localizations.dart';

// todo: fix this error

// [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: PlatformException(recreating_view, trying to create an already created view, view id: '0', null)
// #0      StandardMethodCodec.decodeEnvelope (package:flutter/src/services/message_codecs.dart:646:7)
// #1      MethodChannel._invokeMethod (package:flutter/src/services/platform_channel.dart:334:18)
// <asynchronous suspension>
// #2      PlatformViewsService.initAppKitView (package:flutter/src/services/platform_views.dart:294:5)
// <asynchronous suspension>
// #3      _DarwinViewState._createNewUiKitView (package:flutter/src/widgets/platform_view.dart:921:36)
// <asynchronous suspension>

class MermaidDiagramView extends StatefulWidget {
  final String code;

  const MermaidDiagramView({
    super.key,
    required this.code,
  });

  @override
  State<MermaidDiagramView> createState() => _MermaidDiagramViewState();
}

class _MermaidDiagramViewState extends State<MermaidDiagramView> {
  double _height = 100;
  InAppWebViewController? controller;
  Uint8List? _screenshot;
  double _progress = 0;
  bool _isLoaded = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initWebView(InAppWebViewController controller) async {
    this.controller = controller;
    try {
      await controller.loadData(data: '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
          <script>
            mermaid.initialize({
              startOnLoad: true,
              theme: 'default',
              sequence: {
                diagramMarginX: 50,
                diagramMarginY: 10,
                actorMargin: 50,
                width: 150,
                height: 65,
                boxMargin: 10,
                boxTextMargin: 5,
                noteMargin: 10,
              },
              flowchart: {
                diagramPadding: 8,
                htmlLabels: true,
                curve: 'basis',
              },
              gantt: {
                titleTopMargin: 25,
                barHeight: 20,
                barGap: 4,
                topPadding: 50,
                leftPadding: 75,
                gridLineStartPadding: 35,
                fontSize: 11,
                sectionFontSize: 11,
                numberSectionStyles: 4,
              },
              pie: {
                textPosition: 0.5,
              },
            });
          </script>
          <style>
            html, body {
              margin: 0;
              padding: 0;
              height: auto;
              overflow-y: visible;
              background-color: transparent;
            }
            .mermaid-container {
              display: flex;
              justify-content: center;
              width: 100%;
              padding: 16px;
              box-sizing: border-box;
            }
            .mermaid {
              width: 100%;
              background-color: white;
              padding: 16px;
              box-sizing: border-box;
              border-radius: 8px;
            }
          </style>
        </head>
        <body>
          <div class="mermaid-container">
            <div class="mermaid">
              ${widget.code}
            </div>
          </div>
        </body>
        </html>
      ''');
    } catch (e) {
      debugPrint('Error loading WebView data: $e');
      _handleError();
    }
  }

  void _handleError() {
    if (_retryCount < maxRetries) {
      _retryCount++;
      setState(() {
        _hasError = false;
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    if (_hasError) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Failed to load diagram, please try again'),
        ),
      );
    }

    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
              isInspectable: kDebugMode,
            ),
            onWebViewCreated: _initWebView,
            onLoadStop: (controller, url) async {
              try {
                final height = await controller.evaluateJavascript(
                    source: 'document.body.scrollHeight');
                if (mounted) {
                  setState(() {
                    _height = (height as num).toDouble();
                    _isLoaded = true;
                  });
                  print('takeScreenshot');
                  await takeScreenshot();
                }
              } catch (e) {
                debugPrint('Error on load stop: $e');
                _handleError();
              }
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  _progress = progress / 100;
                });
              }
            },
          ),
          _progress < 1.0
              ? LinearProgressIndicator(value: _progress)
              : Container(),
          if (_screenshot != null) Image.memory(_screenshot!),
        ],
      ),
    );
  }

  Future<Uint8List?> takeScreenshot() async {
    try {
      if (!_isLoaded) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      await Future.delayed(const Duration(milliseconds: 500));
      final result = await controller!.takeScreenshot();

      if (result != null) {
        _screenshot = result;
        if (mounted) {
          setState(() {});
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to take screenshot: $e');
      return null;
    }
  }
}
