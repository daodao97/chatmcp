import 'dart:io';

Future<bool> isCommandAvailable(String command) async {
  try {
    // 在 Windows 上使用 where 命令，在 Unix-like 系统上使用 which 命令
    final String whichCommand = Platform.isWindows ? 'where' : 'which';

    final result = await Process.run(whichCommand, [command]);

    // 如果命令存在，返回状态码为 0
    return result.exitCode == 0;
  } catch (e) {
    // 如果发生错误，说明命令不存在
    return false;
  }
}

// 使用示例：
Future<bool> checkCommand(String command) async {
  final exists = await isCommandAvailable(command);
  return exists;
}
