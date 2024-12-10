import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // 初始化 FFI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      // 使用 FFI 数据库
      databaseFactory = databaseFactoryFfi;
    }

    // 获取应用文档目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, 'chatmcp.db');

    Logger.root.info('db path: $dbPath');

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(sql);
  }
}

Future<void> initDb() async {
  await DatabaseHelper.instance.database;
}

const sql = '''
CREATE TABLE chat(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    createdAt datetime,
    updatedAt datetime
);

CREATE TABLE chat_message(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chatId INTEGER,
    body TEXT,
    createdAt datetime,
    updatedAt datetime,
    FOREIGN KEY (chatId) REFERENCES chat(id)
);
''';
