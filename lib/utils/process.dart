import 'dart:io';

Future<String> getDefaultPath([String? additionalPath]) async {
  final List<String> defaultPaths = [];

  if (Platform.isWindows) {
    defaultPaths.addAll([
      'C:\\Windows\\System32',
      'C:\\Windows',
      'C:\\Windows\\System32\\Wbem',
      'C:\\Windows\\System32\\WindowsPowerShell\\v1.0',
    ]);
  } else if (Platform.isMacOS) {
    defaultPaths.addAll([
      '/opt/homebrew/bin',
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ]);
  } else {
    defaultPaths.addAll([
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ]);
  }

  final String pathSeparator = Platform.isWindows ? ';' : ':';
  final String systemPath = Platform.environment['PATH'] ?? '';

  // 合并默认路径、系统PATH和额外路径
  final List<String> allPaths = [
    ...defaultPaths,
    ...systemPath.split(pathSeparator),
  ];

  // 如果提供了额外的路径，添加到列表中
  if (additionalPath != null && additionalPath.isNotEmpty) {
    allPaths.addAll(additionalPath.split(pathSeparator));
  }

  // 移除空路径并去重
  return allPaths.where((path) => path.isNotEmpty).toSet().join(pathSeparator);
}

Future<bool> isCommandAvailable(String command) async {
  try {
    final String whichCommand = Platform.isWindows ? 'where' : 'which';
    final Map<String, String> env = Map.of(Platform.environment);
    env['PATH'] = await getDefaultPath();

    final result = await Process.run(
      whichCommand,
      [command],
      environment: env,
      includeParentEnvironment: true,
    );

    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Future<Process> startProcess(
  String command,
  List<String> args,
  Map<String, String> environment,
) async {
  final Map<String, String> env = Map.of(environment);
  env['PATH'] = await getDefaultPath();

  return Process.start(
    command,
    args,
    environment: env,
    includeParentEnvironment: true,
  );
}
