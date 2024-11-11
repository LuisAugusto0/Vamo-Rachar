// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'sql_tables.dart';
import 'database_helper.dart';





abstract class SqlProvider<T extends SqlTable> {
  final DatabaseHelper helper;
  const SqlProvider(this.helper);

  String get table;
  List<String> get columns;
  String get idColumnName;
  T Function(Map<String, Object?>) get fromMap;
  List<T> Function(List<Map<String, Object?>>) get fromMapList;

  /// Auxiliar methods
  Future<bool> exists(String column, Object value) async {
    Database db = await helper.getDatabase();

    final result = await db.query(
        table,
        columns: columns,
        where: '$column = ?',
        whereArgs: [value],
        limit: 1
    );
    return result.isNotEmpty;
  }

  Future<int> countRecords() async {
    Database db = await helper.getDatabase();

    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }


  /// Insert
  Future<void> insert(T wrapper) async {
    Database db = await helper.getDatabase();

    int? id = wrapper.getId();
    if (id != null) throw Exception('Table on insert must not contain id value');

    db.insert(this.table, wrapper.toMap());
  }


  /// Update
  Future<void> update(T wrapper) async {
    Database db = await helper.getDatabase();

    int? id = wrapper.getId();
    if (id == null) throw Exception('Table on insert needs id to know which row to update');

    final retorno = await db.update(
      table,
      wrapper.toMap(),
      where: '$idColumnName = ?',
      whereArgs: [wrapper.getId()],
    );
  }


  /// Remove
  Future<void> _removeByUID(Object id, String column) async {
    Database db = await helper.getDatabase();

    await db.delete(
        table,
        where: '$column = ?',
        whereArgs: [id]
    );
  }

  Future<void> removeById(int id) async => _removeByUID(id, idColumnName);



  /// Query Methods
  Future<T?> _getByUID(Object id, String column) async {
    Database db = await helper.getDatabase();

    final result = await db.query(
        table,
        columns: columns,
        where: '$column = ?',
        whereArgs: [id],
        limit: 2
    );

    if (result.length > 1) throw Exception("not UID");
    return result.isNotEmpty ? fromMap(result.first) : null;
  }

  Future<T?> getById(int id) async => _getByUID(id, idColumnName);


  Future<List<T>?> _getByIdList(
      String column,
      List<Object> ids,
      int? limit,
      String? orderBy
      ) async {

    Database db = await helper.getDatabase();

    final whereClause = '$column IN (${List.filled(ids.length, '?').join(', ')})';
    final result = await db.query(
      table,
      columns: columns,
      where: whereClause,
      whereArgs: ids,

      limit: limit,
      orderBy: orderBy,
    );

    return result.isEmpty ? null : fromMapList(result);
  }

  Future<List<T>?> getByIdList(List<int> ids, {int? limit, String? orderBy}) async
  => _getByIdList(idColumnName, ids, limit, orderBy);
}







class LoginProvider extends SqlProvider<LoginSql> {
  const LoginProvider(super.db);


  @override
  String get table => LoginSql.table;

  @override
  List<String> get columns => LoginSql.columns;

  @override
  String get idColumnName => LoginSql.idString;

  @override
  LoginSql Function(Map<String, Object?> p1) get fromMap => LoginSql.fromMap;

  @override
  List<LoginSql> Function(List<Map<String, Object?>> p1) get fromMapList => LoginSql.fromMapList;


  Future<LoginSql?> getByEmail(String id) async => _getByUID(id, LoginSql.emailString);
}




class UserProvider extends SqlProvider<UserSql> {
  const UserProvider(super.db);


  @override
  String get table => UserSql.table;

  @override
  List<String> get columns => UserSql.columns;

  @override
  String get idColumnName => UserSql.idString;

  @override
  UserSql Function(Map<String, Object?> p1) get fromMap => UserSql.fromMap;

  @override
  List<UserSql> Function(List<Map<String, Object?>> p1) get fromMapList => UserSql.fromMapList;
}





class PurchaseProvider extends SqlProvider<PurchaseSql> {
  const PurchaseProvider(super.db);


  @override
  String get table => PurchaseSql.table;

  @override
  List<String> get columns => PurchaseSql.columns;

  @override
  String get idColumnName => PurchaseSql.idString;

  @override
  PurchaseSql Function(Map<String, Object?> p1) get fromMap => PurchaseSql.fromMap;

  @override
  List<PurchaseSql> Function(List<Map<String, Object?>> p1) get fromMapList => PurchaseSql.fromMapList;
}





class ProductProvider extends SqlProvider<ProductSql> {
  const ProductProvider(super.db);


  @override
  String get table => ProductSql.table;

  @override
  List<String> get columns => ProductSql.columns;

  @override
  String get idColumnName => ProductSql.idString;

  @override
  ProductSql Function(Map<String, Object?> p1) get fromMap => ProductSql.fromMap;

  @override
  List<ProductSql> Function(List<Map<String, Object?>> p1) get fromMapList => ProductSql.fromMapList;
}





class ProductUnitProvider extends SqlProvider<ProductUnitSql> {
  const ProductUnitProvider(super.db);


  @override
  String get table => ProductUnitSql.table;

  @override
  List<String> get columns => ProductUnitSql.columns;

  @override
  String get idColumnName => ProductUnitSql.idString;

  @override
  ProductUnitSql Function(Map<String, Object?> p1) get fromMap => ProductUnitSql.fromMap;

  @override
  List<ProductUnitSql> Function(List<Map<String, Object?>> p1) get fromMapList => ProductUnitSql.fromMapList;
}






class ContributionProvider extends SqlProvider<ContributionSql> {
  const ContributionProvider(super.db);


  @override
  String get table => ContributionSql.table;

  @override
  List<String> get columns => ContributionSql.columns;

  @override
  String get idColumnName => ContributionSql.idString;

  @override
  ContributionSql Function(Map<String, Object?> p1) get fromMap => ContributionSql.fromMap;

  @override
  List<ContributionSql> Function(List<Map<String, Object?>> p1) get fromMapList => ContributionSql.fromMapList;
}
