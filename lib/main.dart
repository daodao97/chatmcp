import 'package:chatmcp/dao/init_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart' as wm;
import './logger.dart';
import './page/layout/layout.dart';
import './provider/provider_manager.dart';
import 'package:logging/logging.dart';
import 'page/layout/sidebar.dart';
import 'utils/platform.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'utils/color.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeLogger();

  if (!kIsWeb) {
    // Not supported on mobile
    // if (!kIsDesktop) {
    //   await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    // }

    // Get an available port
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();

    if (!kIsDesktop) {
      final InAppLocalhostServer localhostServer =
          InAppLocalhostServer(documentRoot: 'assets/sandbox', port: port);

      ProviderManager.settingsProvider.updateSandboxServerPort(port: port);

      // start the localhost server
      await localhostServer.start();

      Logger.root.info('Sandbox server started @ http://localhost:$port');
    }
  }

  // if (kIsMobile) {
  //   await FlutterStatusbarcolor.setStatusBarColor(Colors.green[400]!);
  //   if (useWhiteForeground(Colors.green[400]!)) {
  //     FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  //   } else {
  //     FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  //   }
  // }

  if (kIsDesktop) {
    await wm.windowManager.ensureInitialized();

    final wm.WindowOptions windowOptions = wm.WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(400, 600),
      center: true,
      // backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: (kIsLinux || kIsWindows)
          ? wm.TitleBarStyle.normal
          : wm.TitleBarStyle.hidden,
    );

    await wm.windowManager.waitUntilReadyToShow(windowOptions, () async {
      await wm.windowManager.show();
      await wm.windowManager.focus();
    });
  }

  try {
    await Future.wait([
      ProviderManager.init(),
      initDb(),
    ]);

    var app = MyApp();

    runApp(
      MultiProvider(
        providers: [
          ...ProviderManager.providers,
        ],
        child: app,
      ),
    );
  } catch (e, stackTrace) {
    Logger.root.severe('Main error: $e\nStack trace:\n$stackTrace');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    Logger.root.info('初始化深层链接处理...');

    // 获取应用启动时的链接
    try {
      final appLinkUri = await _appLinks.getInitialLink();
      if (appLinkUri != null) {
        Logger.root.info('初始应用链接: $appLinkUri');
        _handleAppLink(appLinkUri);
      }
    } catch (e) {
      Logger.root.severe('获取初始应用链接错误: $e');
    }

    // 监听应用链接
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      Logger.root.info('接收到应用链接: $uri');
      _handleAppLink(uri);
    }, onError: (e) {
      Logger.root.severe('应用链接流错误: $e');
    });
  }

  void _handleAppLink(Uri uri) {
    // 在这里处理链接，例如导航到特定页面
    // 示例: 如果 URI 包含 "/chat/123"，则导航到具有 ID 123 的聊天页面
    String path = uri.path;
    if (path.startsWith('/chat/')) {
      String chatId = path.substring('/chat/'.length);
      // 这里可以根据实际情况进行路由导航
      Logger.root.info('打开聊天 ID: $chatId');

      // 显示一个 SnackBar 作为可视化确认
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('通过链接打开聊天: $chatId')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          navigatorKey: _navigatorKey,
          title: 'ChatMcp',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: _getThemeMode(settings.generalSetting.theme),
          home: LayoutPage(),
          locale: Locale(settings.generalSetting.locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
        );
      },
    );
  }

  ThemeMode _getThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
