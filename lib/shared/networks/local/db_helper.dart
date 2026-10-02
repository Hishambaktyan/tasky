import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/task_model.dart';

class DbHelper {
  static Database? _db;

  static Future<Database> get database async => _db ??= await _init();

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'task_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT NOT NULL,
            priority TEXT NOT NULL,
            due_date INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_at INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insert(TaskModel t) async {
    final db = await database;
    return db.insert('tasks', t.toMap()..remove('id'));
  }

  static Future<List<TaskModel>> getAll() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'due_date ASC');
    return rows.map(TaskModel.fromMap).toList();
  }

  static Future<int> update(TaskModel t) async {
    final db = await database;
    return db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}