import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

final bool kIsDebug = (() {
  bool isDebug = false;
  assert(() {
    isDebug = true;
    return true;
  }());
  return isDebug;
}());

final bool kIsLinux = Platform.isLinux;

final bool kIsWindows = Platform.isWindows;

final bool kIsDesktop =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

final bool kIsMobile = Platform.isAndroid || Platform.isIOS;

final bool kIsAndroid = Platform.isAndroid;

Future<Directory> getAppDir(String appName) async {
  if (kIsDesktop) {
    final Directory appDir;
    if (Platform.isMacOS) {
      // macOS: ~/Library/Application Support/com.yourapp.name/
      appDir = Directory(join(Platform.environment['HOME']!, 'Library',
          'Application Support', appName));
    } else if (Platform.isWindows) {
      // Windows: %APPDATA%\ChatMcp
      appDir = Directory(join(Platform.environment['APPDATA']!, appName));
    } else {
      // Linux: ~/.local/share/chatmcp/
      appDir = Directory(
          join(Platform.environment['HOME']!, '.local', 'share', appName));
    }
    // Ensure the directory exists
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }
    return appDir;
  } else {
    // Use getApplicationDocumentsDirectory for mobile platforms
    return await getApplicationDocumentsDirectory();
  }
}
