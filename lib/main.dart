import 'package:chatmcp/dao/init_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart' as wm;
import './logger.dart';
import './page/layout/layout.dart';
import './provider/provider_manager.dart';
import 'package:logging/logging.dart';
import 'utils/platform.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
      titleBarStyle: wm.TitleBarStyle.hidden,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 获取当前平台的默认字体
  String getPlatformFontFamily() {
    if (Platform.isWindows) {
      return 'Microsoft YaHei'; // 微软雅黑
    }
    return ''; // 其它平台使用 Flutter 默认字体
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          title: 'ChatMcp',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: getPlatformFontFamily(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: getPlatformFontFamily(),
          ),
          themeMode: _getThemeMode(settings.generalSetting.theme),
          home: LayoutPage(),
          locale: Locale(settings.generalSetting.locale),
          builder: BotToastInit(), //1.调用BotToastInit
          navigatorObservers: [BotToastNavigatorObserver()], //2.注册路由观察者
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
