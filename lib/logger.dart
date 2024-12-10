import 'package:logging/logging.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// 定义颜色代码
const ansiReset = '\x1B[0m';
const ansiRed = '\x1B[31m';
const ansiGreen = '\x1B[32m';
const ansiYellow = '\x1B[33m';
const ansiBlue = '\x1B[34m';
const ansiMagenta = '\x1B[35m';
const ansiGray = '\x1B[37m';

// 获取日志级别对应的颜色
String getLevelColor(Level level) {
  switch (level.name) {
    case 'SEVERE':
      return ansiRed;
    case 'WARNING':
      return ansiYellow;
    case 'INFO':
      return ansiBlue;
    case 'CONFIG':
      return ansiMagenta;
    case 'FINE':
    case 'FINER':
    case 'FINEST':
      return ansiGreen;
    default:
      return ansiGray;
  }
}

class FileLogger {
  static File? _logFile;
  static IOSink? _logSink;

  static Future<void> initLogFile() async {
    try {
      final appDir =
          await getApplicationSupportDirectory(); // macos is ~/Library/Application Support
      final logDir = Directory(path.join(appDir.path, 'logs'));

      // 确保日志目录存在
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 使用日期作为日志文件名
      final now = DateTime.now();
      final fileName = 'app_${now.year}-${now.month}-${now.day}.log';
      _logFile = File(path.join(logDir.path, fileName));

      // 以追加模式打开文件
      _logSink = _logFile?.openWrite(mode: FileMode.append);
    } catch (e) {
      print('初始化日志文件失败: $e');
    }
  }

  static void closeLogFile() {
    _logSink?.flush();
    _logSink?.close();
  }

  static void writeToFile(String message) {
    _logSink?.writeln('${DateTime.now()} $message');
  }
}

void initializeLogger() async {
  // 初始化文件日志
  await FileLogger.initLogFile();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // 获取调用位置信息
    String? caller;

    // 使用 StackTrace.current 来确保总是有堆栈信息
    final stackTrace = record.stackTrace ?? StackTrace.current;
    final frames = stackTrace.toString().split('\n');

    if (frames.length > 1) {
      // 解析第一个符合条件的堆栈帧
      final callerFrame = frames.firstWhere(
        (frame) =>
            !frame.contains('log.dart') &&
            !frame.contains('logger.dart') &&
            !frame.contains('logger_mixin.dart') &&
            !frame.contains('main.dart') &&
            !frame.contains('dart:async') &&
            !frame.contains('dart:io') &&
            frame.contains('package:ChatMcp/'),
        orElse: () => frames.firstWhere(
          (frame) => frame.contains('package:ChatMcp/'),
          orElse: () => frames[0],
        ),
      );

      // 提取文件名和行号
      final match = RegExp(r'\((.+?):(\d+)(?::\d+)\)').firstMatch(callerFrame);
      if (match != null) {
        final file = match.group(1);
        final line = match.group(2);
        caller = '$file:$line';
      } else {
        final flutterMatch = RegExp(r'#\d+\s+.*\s+\((.+?):(\d+)(?::\d+)?\)')
            .firstMatch(callerFrame);
        if (flutterMatch != null) {
          final file = flutterMatch.group(1);
          final line = flutterMatch.group(2);
          caller = '$file:$line';
        }
      }
    }

    final levelColor = getLevelColor(record.level);
    final logMessage =
        '${record.level.name}: ${caller ?? 'unknown'}: ${record.message}';

    // 在开发模式下打印彩色日志到控制台
    assert(() {
      print('$levelColor$logMessage$ansiReset');
      return true;
    }());

    // 在 release 模式下写入文件
    FileLogger.writeToFile(logMessage);
  });
}
