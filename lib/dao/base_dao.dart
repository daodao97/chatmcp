import 'package:sqflite/sqflite.dart';
import './init_db.dart';

abstract class BaseDao<T> {
  final String tableName;

  const BaseDao(this.tableName);

  Future<Database> get database => DatabaseHelper.instance.database;

  // 需要子类实现的方法，用于转换数据
  Map<String, dynamic> toJson(T entity);
  T fromJson(Map<String, dynamic> json);

  // 通用CRUD操作
  Future<int> insert(T entity) async {
    final db = await database;
    return db.insert(
      tableName,
      toJson(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<T>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map((item) => fromJson(item)).toList();
  }

  Future<T?> queryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return fromJson(maps.first);
  }

  Future<int> update(T entity, String id) async {
    final db = await database;
    return db.update(
      tableName,
      toJson(entity),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String id) async {
    final db = await database;
    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
