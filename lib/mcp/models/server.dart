class ServerConfig {
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final String author;

  const ServerConfig({
    required this.command,
    required this.args,
    this.env = const {},
    this.author = '',
  });

  // 从 JSON Map 创建 ServerConfig
  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      command: json['command'] as String,
      args: (json['args'] as List<dynamic>).cast<String>(),
      env: (json['env'] as Map<String, dynamic>?)?.cast<String, String>() ??
          const {},
    );
  }
}
