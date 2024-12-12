// database_helper.dart
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

/* Some systems may not support multiple sql commands
 * As such each execute can only take in one command at a time
 */

Future<void> createTables(Database db) async {
  await db.execute('''
      CREATE TABLE login (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        imagem TEXT --url
      );
  ''');

  await db.execute('''
      CREATE TABLE usuario (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        login_id INTEGER,
        FOREIGN KEY (login_id) REFERENCES login(id)
      );
    ''');

  await db.execute('''
      CREATE TABLE pedido (
        id INTEGER PRIMARY KEY,
        estabelecimento_nome TEXT,
        date_time INTEGER NOT NULL,  -- Assuming Unix timestamp
        longitude REAL,
        latitude REAL,
        login_responsavel_id INTEGER NOT NULL,
        FOREIGN KEY (login_responsavel_id) REFERENCES login(id)
      );
    ''');

  await db.execute('''
      CREATE TABLE usuario_pedido (
       
        usuario_id INTEGER NOT NULL,
        pedido_id INTEGER NOT NULL,
        PRIMARY KEY (usuario_id, pedido_id),
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (pedido_id) REFERENCES pedido(id)
      );
    ''');


  await db.execute('''
    CREATE TABLE produto (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        preco REAL NOT NULL,
        pedido_id INTEGER NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedido(id)
      );
    ''');

  await db.execute('''
      CREATE TABLE unidade_produto (
        id INTEGER PRIMARY KEY,
        produto_id INTEGER NOT NULL,
        FOREIGN KEY (produto_id) REFERENCES produto(id)
      );
     ''');

  await db.execute('''
      CREATE TABLE contribuicao (
        id INTEGER PRIMARY KEY,
        preco_pago REAL NOT NULL,
        usuario_id INTEGER NOT NULL,
        unidade_produto_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (unidade_produto_id) REFERENCES unidade_produto(id)
      );
    ''');


  await db.execute("CREATE INDEX idx_usuario_id ON usuario_pedido (usuario_id)");
  await db.execute("CREATE INDEX idx_pedido_id ON usuario_pedido (pedido_id)");
}

Future<void> dropTables(Database db) async {
  await db.execute("DROP INDEX IF EXISTS idx_pedido_id");
  await db.execute("DROP TABLE IF EXISTS contribuicao");
  await db.execute("DROP TABLE IF EXISTS unidade_produto");
  await db.execute("DROP TABLE IF EXISTS produto");
  await db.execute("DROP TABLE IF EXISTS usuario_pedido");
  await db.execute("DROP TABLE IF EXISTS pedido");
  await db.execute("DROP TABLE IF EXISTS usuario");
  await db.execute("DROP TABLE IF EXISTS login");
}

Future<void> initLaunchData(Database db) async {

  debugPrint('Initializing new data');

  // LOGIN NOT USED ANYMORE, BUT THIS IS USED TO FULFILL FKEY REQUIREMENTS
  await db.execute('''
        INSERT INTO login (nome, email, senha) 
        VALUES ('Admin', 'admin@email.com', '123456#'); -- linked to login
    ''');
}


// Example data
Future<void> initTestData(Database db) async {

  debugPrint('Initializing new data');

  try {
    // Insert into login table
    await db.execute('''
        INSERT INTO login (nome, email, senha) 
        VALUES ('João Silva', 'joao.silva@email.com', '123456#'); -- linked to login
    ''');



    // Insert into usuario table
    await db.execute('''
        INSERT INTO usuario (nome, login_id) 
        VALUES ('João Silva', '1'); -- linked to login
      ''');


    await db.execute('''
          INSERT INTO usuario (nome) -- bot linked to login
          VALUES ('Maria Oliveira'); 
        ''');


    // Insert into pedido table
    await db.execute('''
          INSERT INTO pedido (estabelecimento_nome, date_time, longitude, latitude, login_responsavel_id) 
          VALUES ('Restaurante B', 1704048320, -46.6335, -23.5500, 1);
        ''');

    await db.execute('''
        INSERT INTO pedido (estabelecimento_nome, date_time, longitude, latitude, login_responsavel_id) 
        VALUES ('Restaurante A', 1704045020, -46.6333, -23.5505, 1);
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
        VALUES (15.00, 1, 2);
      ''');

    await db.execute('''
        INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
        VALUES (15.00, 2, 2);
      ''');



    await db.execute('''
        INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
        VALUES (10.00, 1, 3);
      ''');


    await db.execute('''
        INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
        VALUES (17.50, 2, 4);
      ''');

    await db.execute('''
        INSERT INTO contribuicao (preco_pago, usuario_id, unidade_produto_id) 
        VALUES (7.50, 1, 4);
      ''');





  }catch(e) {
    debugPrint("Tables where not created, or cant access tables: $e");
    rethrow;
  }


}