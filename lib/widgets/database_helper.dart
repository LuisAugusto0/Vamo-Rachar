// database_helper.dart
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



/*  Wrapper classes for each Table attributes
 *
 *  Ensures strong typed programming to remove the need to use strings when
 *  acessing each array
 *
 *  If any attribute contains a diferent name or does not exist, the method will
 *  throw an exception.
 *
 *  <----!---->
 *  The exceptions are not meant to be treated as they cannot be allowed to happen.
 *  All names must be correct and correspond to a attribute of correct type
 *
 *  Type conversions defined on sqflite:
 *    INTEGER -> int
 *    TEXT -> String
 *    REAL -> double
 *    NUMERIC -> either int or double. A cast into double should be done in this case
 */

class UserSqlWrapper {
  static const String table = 'usuario';

  static const String id = 'id';
  static const String name = 'nome';
  static const String email = 'email';
  static const String password = 'senha';
  static const String imageUrl = 'imagem';

  final Map<String, dynamic> _data;
  UserSqlWrapper(this._data);

  int getId() => _data[id] as int;
  String getName() => _data[email] as String;
  String getEmail() => _data[email] as String;
  String getPassword() => _data[password] as String;
  String getImageUrl() => _data[imageUrl] as String;

  static List<UserSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => UserSqlWrapper(map)).toList();
  }
}



class UserPurchaseSqlWrapper {
  static const String table = 'usuario_pedido';

  static const String fkeyUser = 'usuario_id';
  static const String fkeyPurchase = 'pedido_id';

  final Map<String, dynamic> _data;
  UserPurchaseSqlWrapper(this._data);

  int getFkeyUser() => _data[fkeyUser] as int;
  int getFkeyPurchase() => _data[fkeyPurchase] as int;

  static List<UserPurchaseSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => UserPurchaseSqlWrapper(map)).toList();
  }
}




class PurchaseSqlWrapper {
  static const String table = 'pedido';

  static const String id = 'id';
  static const String establishmentName = 'estabelecimento_nome';
  static const String dateTime = 'date_time';
  static const String longitude = 'longitude';
  static const String latitude = 'latitude';

  final Map<String, dynamic> _data;
  PurchaseSqlWrapper(this._data);

  int getId() => _data[id] as int;
  String getEstablishmentName() => _data[establishmentName] as String;
  int getDateTimeAsUnix() => _data[dateTime] as int;
  double getLongitude() => _data[dateTime] as double;
  double getLatitude() => _data[dateTime] as double;

  static List<PurchaseSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => PurchaseSqlWrapper(map)).toList();
  }
}



class ProductSqlWrapper {
  static const String table = 'produto';

  static const String id = 'id';
  static const String name = 'nome';
  static const String price = 'preco';
  static const String fkeyPurchase = 'pedido_id';

  final Map<String, dynamic> _data;
  ProductSqlWrapper(this._data);


  int getId() => _data[id] as int;
  String getNome() => _data[name] as String;
  double getPreco() => _data[price] as double;
  int getFkeyPurchase() => _data[fkeyPurchase] as int;

  static List<ProductSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => ProductSqlWrapper(map)).toList();
  }
}


class ProductUnitSqlWrapper {
  static const String table = 'unidade_produto';

  static const String id = 'id';
  static const String fkeyProduct = 'id';

  final Map<String, dynamic> _data;
  ProductUnitSqlWrapper(this._data);

  int getId() => _data[id] as int;
  int getFkeyProduct() => _data[fkeyProduct] as int;

  static List<ProductUnitSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => ProductUnitSqlWrapper(map)).toList();
  }
}

class ContributionsSqlWrapper {
  static const String table = 'contribuicao';

  static const String id = 'id';
  static const String price = 'preco_pago';
  static const String fkeyProductUnit = 'unidade_produto_id';
  static const String fkeyUser = 'usuario_id';

  final Map<String, dynamic> data;
  const ContributionsSqlWrapper({required this.data});

  int getId() => data[id] as int;
  double getPrice() => data[price] as double;
  int getFkeyProductUnit() => data[fkeyProductUnit] as int;
  int getFkeyUser() => data[fkeyUser] as int;

  static List<ContributionsSqlWrapper> fromList(List<Map<String, dynamic>> data) {
    return data.map((map) => ContributionsSqlWrapper(data: map)).toList();
  }
}





class DatabaseHelper {

  static const dbName = 'users';
  static const userTable = UserSqlWrapper.table;
  static const userPurchaseTable = UserPurchaseSqlWrapper.table;
  static const purchaseTable = PurchaseSqlWrapper.table;
  static const productTable = ProductSqlWrapper.table;
  static const contributionTable = ContributionsSqlWrapper.table;


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
    final path = join(dbPath, '$dbName.db');

    // // Excluir o banco de dados, forçando a recriação
    // final dbFile = File(path);
    // if (await dbFile.exists()) {
    //   await dbFile.delete();
    //   print("Banco de dados existente excluído para recriação.");
    // }

    print("BUILDING");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuario (
              id INTEGER PRIMARY KEY,
              nome TEXT NOT NULL,
              email TEXT NOT NULL,
              senha TEXT NOT NULL,
              imagem TEXT
          );
          
          CREATE TABLE pedido (
              id INTEGER PRIMARY KEY,
              estabelecimento_nome TEXT,
              date_time INTEGER,  -- Assuming Unix timestamp
              longitude REAL,
              latitude REAL
          );
          
          CREATE TABLE usuario_pedido (
              usuario_id INTEGER,
              pedido_id INTEGER,
              PRIMARY KEY (usuario_id, pedido_id),
              FOREIGN KEY (usuario_id) REFERENCES usuario(id),
              FOREIGN KEY (pedido_id) REFERENCES pedido(id)
          );
          
          CREATE TABLE produto (
              id INTEGER PRIMARY KEY,
              nome TEXT,
              preco REAL,
              pedido_id INTEGER,
              FOREIGN KEY (pedido_id) REFERENCES pedido(id)
          );
          
          
          CREATE TABLE unidade_produto (
              id INTEGER PRIMARY KEY,
              produto_id INTEGER,
              FOREIGN KEY (produto_id) REFERENCES produto(id)
          );
          
          CREATE TABLE contribuicao (
              id INTEGER PRIMARY KEY,
              preco_pago REAL,
              usuario_id INTEGER,
              unidade_produto_id INTEGER,
              FOREIGN KEY (usuario_id) REFERENCES usuario(id),
              FOREIGN KEY (unidade_produto_id) REFERENCES unidade_produto(id)
          );
          
          
          
          -- Optional: Add indexes on foreign key columns for better performance
          CREATE INDEX idx_usuario_id ON usuario_pedido (usuario_id);
          CREATE INDEX idx_pedido_id ON usuario_pedido (pedido_id);

        ''');
        db.execute('CREATE TABLE usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
        print(dbPath);
        await _initTestData(db);
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
    db.execute('CREATE TABLE IF NOT EXISTS usuarioAtual (id INTEGER PRIMARY KEY, nome VARCHAR, email VARCHAR, senha VARCHAR)');
    const sql = 'SELECT * FROM usuarioAtual';
    final usuario = await db.rawQuery(sql);
    return usuario.isEmpty ? null : usuario.first;
  }

  Future<void> updateCurrentUser(String email) async{
    if (await getCurrentUser() != null){
      deleteCurrentUser();
    }
    createCurrentUser(email);
  }



  Future<void> createUser(String nome, String email, String senha) async {
    print('here');
    final db = await _getDatabase();
    print('here2');
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






  Future<List<ProductSqlWrapper>?> productListFromPurchase(int purchaseId) async {
    final db = await _getDatabase();

    final result = await db.query(
      purchaseTable,
      columns: [ProductSqlWrapper.id],
      where: '${ProductSqlWrapper.id} = ?',
      whereArgs: [purchaseId],
    );

    return result.isEmpty ? null : ProductSqlWrapper.fromList(result);
  }


  Future<List<ProductUnitSqlWrapper>?> productUnitListFromProductList(List<int> productIds) async {
    final db = await _getDatabase();

    final result = await db.query(
      purchaseTable,
      columns: [ProductUnitSqlWrapper.id],
      where: '${ProductUnitSqlWrapper.id} = ?',
      whereArgs: productIds,
    );

    return result.isEmpty ? null : ProductUnitSqlWrapper.fromList(result);
  }


  Future<List<ContributionsSqlWrapper>?> contributionListFromProductUnitList(List<int> contributionIds) async {
    final db = await _getDatabase();

    final result = await db.query(
      contributionTable,
      columns: [ContributionsSqlWrapper.id],
      where: '${ContributionsSqlWrapper.id} = ?',
      whereArgs: contributionIds,
    );

    return result.isEmpty ? null : ContributionsSqlWrapper.fromList(result);
  }


  Future<List<UserSqlWrapper>?> userListFromUserId(List<int> userIds) async {
    final db = await _getDatabase();
    final whereClause = '${UserSqlWrapper.id} IN (${List.filled(userIds.length, '?').join(', ')})';

    final result = await db.query(
      contributionTable,
      columns: [UserSqlWrapper.id],
      where: whereClause,
      whereArgs: userIds,
    );

    return result.isEmpty ? null : UserSqlWrapper.fromList(result);
  }



  Future<void> _initTestData(Database db) async {

    print('here');


    // Insert into usuario table
    await db.execute('''
    INSERT INTO usuario (nome, email, senha, imagem) 
    VALUES ('João Silva', 'joao.silva@email.com', 'senha123', 'imagem1.jpg');
  ''');

    await db.execute('''
    INSERT INTO usuario (nome, email, senha, imagem) 
    VALUES ('Maria Oliveira', 'maria.oliveira@email.com', 'senha456', 'imagem2.jpg');
  ''');

    // Insert into pedido table
    await db.execute('''
    INSERT INTO pedido (estabelecimento_nome, date_time, longitude, latitude) 
    VALUES ('Restaurante A', 1704045020, -46.6333, -23.5505);
  ''');

    await db.execute('''
    INSERT INTO pedido (estabelecimento_nome, date_time, longitude, latitude) 
    VALUES ('Restaurante B', 1704048320, -46.6335, -23.5500);
  ''');

    // Insert into usuario_pedido table
    await db.execute('''
    INSERT INTO usuario_pedido (usuario_id, pedido_id) 
    VALUES (1, 1);
  ''');

    await db.execute('''
    INSERT INTO usuario_pedido (usuario_id, pedido_id) 
    VALUES (1, 2);
  ''');

    await db.execute('''
    INSERT INTO usuario_pedido (usuario_id, pedido_id) 
    VALUES (2, 2);
  ''');

    // Insert into produto table
    await db.execute('''
    INSERT INTO produto (nome, preco, pedido_id) 
    VALUES ('Pizza Margherita', 30.00, 1);
  ''');

    await db.execute('''
    INSERT INTO produto (nome, preco, pedido_id) 
    VALUES ('Coca-Cola', 10.00, 2);
  ''');

    await db.execute('''
    INSERT INTO produto (nome, preco, pedido_id) 
    VALUES ('Hamburguer', 25.00, 2);
  ''');

    // Insert into unidade_produto table
    await db.execute('''
    INSERT INTO unidade_produto (produto_id) 
    VALUES (1);
  ''');

    await db.execute('''
    INSERT INTO unidade_produto (produto_id) 
    VALUES (2);
  ''');

    await db.execute('''
    INSERT INTO unidade_produto (produto_id) 
    VALUES (3);
  ''');

    // Insert into contribuicao table
    await db.execute('''
    INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
    VALUES (30.00, 1, 1);
  ''');

    await db.execute('''
    INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
    VALUES (10.00, 1, 2);
  ''');

    await db.execute('''
    INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
    VALUES (25.00, 2, 3);
  ''');

    print('Initial data inserted.');
    await _displayTestData(db);




    // Call _displayTestData with the database parameter after insertion completes
    await _displayTestData(db);
  }

  Future<void> _displayTestData(Database db) async {

    print('here2');
    final result = await db.rawQuery('''
    SELECT 
      u.nome AS usuario_nome, 
      p.estabelecimento_nome, 
      pr.nome AS produto_nome, 
      c.preco_pago
    FROM 
        contribuicao c
    JOIN usuario u ON c.usuario_id = u.id
    JOIN unidade_produto up ON c.unidade_produto_id = up.id
    JOIN produto pr ON up.produto_id = pr.id
    JOIN pedido p ON pr.pedido_id = p.id;
  ''');

    // Print the result in the console (for testing purposes)
    result.forEach((row) {
      print('Usuario: ${row['usuario_nome']}, Estabelecimento: ${row['estabelecimento_nome']}, Produto: ${row['produto_nome']}, Preço Pago: ${row['preco_pago']}');
    });
  }

}




