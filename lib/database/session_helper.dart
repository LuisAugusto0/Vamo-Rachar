// database_helper.dart
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vamorachar/database/database_helper.dart';
import 'sql_tables.dart';
import 'sql_providers.dart';


class SessionHelper {

  static const dbName = 'session';
  static const sessionTable = 'session';
  LoginProvider loginProvider = LoginProvider(DatabaseHelper());



  static final SessionHelper _instance = SessionHelper._internal();
  Database? _database;

  // Ensures only one instance exists
  factory SessionHelper() {
    return _instance;
  }

  SessionHelper._internal();


  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }


  Future<void> testDatabase(Database db) async {
    try {
      /* I cant find any specific operation to check if its corrupted or not
       * In the offchance that its corrupted, im assuming db.getVersion()
       * will throw an exception
       */
      await db.getVersion();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onDatabaseOpen(Database db) async {
    try {

      testDatabase(db);
    } catch (e) {
      debugPrint('Database is not valid: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '$dbName.db');
    debugPrint("data base path: $path");

    bool created = false;
    Database res;
    try {
      res = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          debugPrint("Preloading database");
          await db.execute('CREATE TABLE IF NOT EXISTS $sessionTable (id INTEGER PRIMARY KEY, login_id INTEGER NOT NULL)');
          created = true;
        },
        onOpen: (db) async {
          debugPrint("Database opened.");
          await _onDatabaseOpen(db);
        },
      );
    } catch (e) {
      debugPrint("Error during database initialization: $e");
      rethrow;
    }


    return res;
  }



  Future<bool> tableExists() async {
    final db = await getDatabase();

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [sessionTable],
    );

    return result.isNotEmpty;
  }

  Future<int?> getId() async {
    final db = await getDatabase();

    final result = await db.query(sessionTable, limit: 1);
    return result.isEmpty ? null : result.first['login_id'] as int;
  }

  Future<bool> isEmpty() async => (await getId()) == null ? true : false;



  Future<void> updateKey(int newLoginTableId) async {
    final db = await getDatabase();

    await db.update(
      sessionTable,
      {'login_id' : newLoginTableId}
    );
  }

  Future<void> insertKey(int newLoginTableId) async {
    final db = await getDatabase();

    await db.insert(
        sessionTable,
        {'login_id' : newLoginTableId}
    );
  }

  Future<void> storeNewKey(int loginTableId) async {
    if (await isEmpty()) {
      insertKey(loginTableId);
    } else {
      updateKey(loginTableId);
    }
  }

  Future<LoginSql?> getLogin() async {
    int? id = await getId();
    return id == null ? null : loginProvider.getById(id);
  }


}