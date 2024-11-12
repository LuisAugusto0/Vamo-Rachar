// database_helper.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vamorachar/login.dart';
import 'database_definitions.dart';
import 'sql_tables.dart';



class DatabaseHelper {

  static const dbName = 'base';

  static const loginTable = LoginSql.table;
  static const userTable = UserSql.table;
  static const userPurchaseTable = UserPurchaseSql.table;
  static const purchaseTable = PurchaseSql.table;
  static const productTable = ProductSql.table;
  static const productUnitTable = ProductUnitSql.table;
  static const contributionTable = ContributionSql.table;


  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  // Ensures only one instance exists
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();


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
      // Allow foreign key constraints
      await db.execute("PRAGMA foreign_keys = ON;");

      testDatabase(db);

    } catch(e) {
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
          await createTables(db);
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


    if (created) {
      await initTestData(res);
    }
    assertAllTableWrappers(res);

    return res;
  }



  // Assert table existance
  Future<bool> tableExists(String tableName) async {
    final db = await getDatabase();


    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    return result.isNotEmpty;
  }

  Future<void> assertAllTablesExists() async {
    List<String> tables = [userTable, purchaseTable, userPurchaseTable,
      productTable, productUnitTable, contributionTable];

    for (final table in tables) {
      assert(await tableExists(table));
    }
  }


  // Assert if table classes are properly set
  Future<Map<String, dynamic>?> getFirstTableResult(Database db, String tableName) async {
    final List<Map<String, dynamic>> result = await db.query(
        tableName,
        limit: 1
    );

    return result.isEmpty ? null : result.first;
  }

  Future<void> assertTableWrapper(Database db, String tableName, Function(Map<String, dynamic>) fromMap) async {
    final res = await getFirstTableResult(db, tableName);
    if (res == null) {
      debugPrint("Could not assert $tableName as it is empty");
    } else {
      fromMap(res); // Executes the provided function to process the result
    }
  }

  Future<void> assertAllTableWrappers(Database db) async {
    await assertTableWrapper(db, loginTable, LoginSql.fromQueryMap);
    await assertTableWrapper(db, userTable, UserSql.fromQueryMap);
    await assertTableWrapper(db, userPurchaseTable, UserPurchaseSql.fromQueryMap);
    await assertTableWrapper(db, purchaseTable, PurchaseSql.fromQueryMap);
    await assertTableWrapper(db, productTable, ProductSql.fromQueryMap);
    await assertTableWrapper(db, productUnitTable, ProductUnitSql.fromQueryMap);
    await assertTableWrapper(db, contributionTable, ContributionSql.fromQueryMap);
  }





  // Queries
  @Deprecated('old version that does not support providers as type safety')
  Future<void> createCurrentUser(String email) async {
    final db = await getDatabase();
    // Verifica se a tabela existe e cria se necessário
    await db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    final dadosUsuario = findUser(email);
    final id = await db.insert('usuarioAtual', (await dadosUsuario)!);
    debugPrint('Salvo: $id');
    listarUmUsuario(id);
  }

  @Deprecated('old version that does not support providers as type safety')
  Future<void> deleteCurrentUser() async {
    final db = await getDatabase();
    // Verifica se a tabela existe e cria se necessário
    await db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    final retorno = await db.delete('usuarioAtual');
    debugPrint('Itens excluídos: $retorno');
  }

  @Deprecated('old version that does not support providers as type safety')
  Future<Map<String, Object?>?> getCurrentUser() async {
    final db = await getDatabase();
    // Verifica se a tabela existe e cria se necessário
    db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    const sql = 'SELECT * FROM usuarioAtual';
    final usuario = await db.rawQuery(sql);
    return usuario.isEmpty ? null : usuario.first;
  }


  @Deprecated('old version that does not support providers as type safety')
  Future<void> updateCurrentUser(String email) async{
    if (await getCurrentUser() != null){
      deleteCurrentUser();
    }
    createCurrentUser(email);
  }


  @Deprecated('old version that does not support providers as type safety')
  Future<void> createUser(String nome, String email, String senha) async {
    debugPrint('here');
    final db = await getDatabase();
    debugPrint('here2');
    final dadosUsuario = {'nome': nome, 'email': email, 'senha': senha};
    final id = await db.insert('usuario', dadosUsuario);
    debugPrint('Salvo: $id');
    listarUmUsuario(id);
  }


  @Deprecated('old version that does not support providers as type safety')
  Future<Map<String, Object?>?> findUser(String email) async {
    final db = await getDatabase();

    final usuario = await db.query(
      'usuario',
      columns: ['id', 'nome', 'email', 'senha'],
      where: 'email = ?',
      whereArgs: [email],
    );

    return usuario.isEmpty ? null : usuario.first;
  }

  // Future<void> listarUsuarios() async {
  //   final db = await _getDatabase();
  //   const sql = 'SELECT * FROM usuario';
  //   final usuario = await db.rawQuery(sql);
  //
  //   for (var usuario in usuario) {
  //     print('id: ${usuario['id']}, nome: ${usuario['nome']}, email: ${usuario['email']}, senha: ${usuario['senha']}');
  //   }
  // }

  @Deprecated('old version that does not support providers as type safety')
  Future<void> listarUmUsuario(int id) async {
    final db = await getDatabase();
    final usuario = await db.query(
      'usuario',
      columns: ['id', 'nome', 'email', 'senha'],
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var usuario in usuario) {
      debugPrint('id: ${usuario['id']}, nome: ${usuario['nome']}, email: ${usuario['email']}, senha: ${usuario['senha']}');
    }
  }

  // Future<void> removeUser(String nome, String email) async {
  //   final db = await _getDatabase();
  //   final retorno = await db.delete(
  //     'usuario',
  //     where: 'nome = ? AND email = ?',
  //     whereArgs: [nome, email],
  //   );
  //   print('Itens excluidos: $retorno');
  // }

  @Deprecated('old version that does not support providers as type safety')
  Future<void> updateUser(int id, String nome, String email, String senha) async {
    final db = await getDatabase();
    final dadosUsuario = {'nome': nome, 'email': email, 'senha': senha};
    final retorno = await db.update(
      'usuario',
      dadosUsuario,
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('Itens atualizados: $retorno');
  }





}








