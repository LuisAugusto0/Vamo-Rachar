// database_helper.dart
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.bd');

    // Excluir o banco de dados, forçando a recriação
    final dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print("Banco de dados existente excluído para recriação.");
    }

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) {
        db.execute('CREATE TABLE usuario (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, email VARCHAR, senha VARCHAR)');
        db.execute('CREATE TABLE usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
      },
    );
  }

  Future<void> createCurrentUser(String email) async {
    final db = await _getDatabase();
    // Verifica se a tabela existe e cria se necessário
    await db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    final dadosUsuario = findUser(email);
    final id = await db.insert('usuarioAtual', (await dadosUsuario)!);
    print('Salvo: $id');
    listarUmUsuario(id);
  }

  Future<void> deleteCurrentUser() async {
    final db = await _getDatabase();
    // Verifica se a tabela existe e cria se necessário
    await db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    final retorno = await db.delete('usuarioAtual');
    print('Itens excluídos: $retorno');
  }

  Future<Map<String, Object?>?> getCurrentUser() async {
    final db = await _getDatabase();
    // Verifica se a tabela existe e cria se necessário
    await db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    const sql = 'SELECT * FROM usuarioAtual';
    final usuario = await db.rawQuery(sql);
    return usuario.isEmpty ? null : usuario.first;
  }

  Future<void> updateCurrentUser(String email) async{
    if (getCurrentUser() == null){
      deleteDatabase(email);
    }
    createCurrentUser(email);
  }



  Future<void> createUser(String nome, String email, String senha) async {
    final db = await _getDatabase();
    final dadosUsuario = {'nome': nome, 'email': email, 'senha': senha};
    final id = await db.insert('usuario', dadosUsuario);
    print('Salvo: $id');
    listarUmUsuario(id);
  }


  Future<Map<String, Object?>?> findUser(String email) async {
    final db = await _getDatabase();
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

  Future<void> listarUmUsuario(int id) async {
    final db = await _getDatabase();
    final usuario = await db.query(
      'usuario',
      columns: ['id', 'nome', 'email', 'senha'],
      where: 'id = ?',
      whereArgs: [id],
    );
    for (var usuario in usuario) {
      print('id: ${usuario['id']}, nome: ${usuario['nome']}, email: ${usuario['email']}, senha: ${usuario['senha']}');
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

  Future<void> updateUser(int id, String nome, String email, String senha) async {
    final db = await _getDatabase();
    final dadosUsuario = {'nome': nome, 'email': email, 'senha': senha};
    final retorno = await db.update(
      'usuario',
      dadosUsuario,
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Itens atualizados: $retorno');
  }
}