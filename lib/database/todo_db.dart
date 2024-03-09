import 'package:sqflite/sqflite.dart';
import 'package:sqlitedb_demo/database/database_services.dart';
import 'package:sqlitedb_demo/model/todoModel.dart';

class TodoDB {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS todos(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "created_at" INTEGER NOT NULL DEFAULT (strftime('%s','now')),
    "updated_at" INTEGER
  );""");
  }

  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    var operation = await database.rawInsert(
        '''INSERT INTO $tableName (title,created_at) VALUES (?,?)''',
        [title, DateTime.now().millisecondsSinceEpoch]);
    return operation;
  }

  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
        '''SELECT * from $tableName ORDER BY COALESCE (updated_at, created_at)''');

    var list = todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();

    return list;
  }

  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * from $tableName WHERE id=?''', [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

  Future<int> update({required int id, String? title}) async {
    final database = await DatabaseService().database;
    return await database.update(
        tableName,
        {
          if (title != null) 'title': title,
          'updated_at': DateTime.now().millisecondsSinceEpoch
        },
        where: 'id=?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id =?''', [id]);
  }
}
