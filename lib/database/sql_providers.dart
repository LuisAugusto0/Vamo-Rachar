// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'sql_tables.dart';
import 'database_helper.dart';





abstract class SqlProvider<T extends SqlTable> {
  final DatabaseHelper helper;
  const SqlProvider(this.helper);

  String get table;
  List<String> get columns;
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
  Future<int> insert(T wrapper) async {
    Database db = await helper.getDatabase();

    // final map = wrapper.toMap();
    // for (String column in wrapper.getColumns()) {
    //   if (map.containsKey(column)) throw Exception("Contraint Violation: Insert is not allowed to have primary keys");
    // }

    int id = await db.insert(this.table, wrapper.toMap());
    return id;
  }


  /// Update
  Future<int> updateByKey(T wrapper, String primaryKeyColumn, Object key) async {
    Database db = await helper.getDatabase();

    final map = wrapper.toMap();
    // for (String column in wrapper.getColumns()) {
    //   if (map.containsKey(column)) throw Exception("Contraint Violation: Update is not allowed to have primary keys");
    // }

    int count = await db.update(
      table,
      map,
      where: '$primaryKeyColumn = ?',
      whereArgs: [key],
    );

    return count;
  }




  /// Remove
  Future<void> remove(Object id, String column) async {
    Database db = await helper.getDatabase();

    await db.delete(
        table,
        where: '$column = ?',
        whereArgs: [id]
    );
  }



  /// Query Definitions

  // Helper methods for one column search
  Future<List<Map<String, Object?>>> queryAll(String column, int limit,
      {String? orderBy}) async {

    Database db = await helper.getDatabase();

    final result = db.query(
        table,
        columns: columns,
        orderBy: orderBy,
        limit: limit
    );

    return result;
  }





  // Applications
  Future<T?> getByPrimaryKey(Object id, String column) async {
    Database db = await helper.getDatabase();

    final result = await db.query(
        table,
        columns: columns,
        where: '$column = ?',
        whereArgs: [id]
    );


    if (result.length > 1) throw Exception("not UID");
    return result.isNotEmpty ? fromMap(result.first) : null;
  }


  Future<List<T>?> getByKey(Object id, String column) async {
    Database db = await helper.getDatabase();

    final result = await db.query(
        table,
        columns: columns,
        where: '$column = ?',
        whereArgs: [id]
    );

    return result.isNotEmpty ? fromMapList(result) : null;
  }


  Future<List<T>> getByKeyList(
    String column,
    List<Object> ids,
    {
      int? limit,
      String? orderBy,
      int? offset
    }
  ) async {

    Database db = await helper.getDatabase();

    //WHERE $column IN (1, 2, 3);
    final whereClause = '$column IN (${List.filled(ids.length, '?').join(', ')})';

    final result = await db.query(
        table,
        columns: columns,
        where: whereClause,
        whereArgs: ids,

        limit: limit,
        orderBy: orderBy,
        offset: offset
    );

    return fromMapList(result);
  }



  static String getSimpleOrderBy(String column, bool ascending) {
    if (ascending) return column;
    return "$column DESC";
  }

  Future<List<T>> getFirstResults(
    String column,
    int limit,
    {
      String? orderBy,
      int? offset
    }
  ) async {
    Database db = await helper.getDatabase();

    final result = await db.query(
        table,
        columns: columns,
        limit: limit,
        orderBy: orderBy,
        offset: offset
    );

    return fromMapList(result);

  }




}

class UserPurchaseProvider extends SqlProvider<UserPurchaseSql> {
  const UserPurchaseProvider(super.db);

  @override
  String get table => UserPurchaseSql.table;

  @override
  List<String> get columns => UserPurchaseSql.columns;

  @override
  UserPurchaseSql Function(Map<String, Object?> p1) get fromMap => UserPurchaseSql.fromQueryMap;

  @override
  List<UserPurchaseSql> Function(List<Map<String, Object?>> p1) get fromMapList => UserPurchaseSql.fromQueryMapList;


  Future<List<int>?> getFromUserKey(int id) async {
    final users = await getByKey(id, UserPurchaseSql.fkeyUserString);

    if (users == null) return null;
    return users.map((user) => user.fkeyUser).toList();
  }

  Future<List<int>?> getFromPurchaseKey(int id) async {
    final users = await getByKey(id, UserPurchaseSql.fkeyPurchaseString);

    if (users == null) return null;
    return users.map((user) => user.fkeyPurchase).toList();
  }
}






// Sql Provider for SqlTables that contains a numeric autoincrement primary key
abstract class EntityProvider<T extends EntityTable> extends SqlProvider<T> {
  const EntityProvider(super.db);

  String get idColumnName;


  Future<void> removeByAutoIncrementId(int id) async => remove(id, idColumnName);

  Future<void> updateByAutoIncrementId(T wrapper, Object id) => updateByKey(wrapper, idColumnName, id);

  Future<T?> getByAutoIncrementId(int id) async => getByPrimaryKey(id, idColumnName);

  Future<List<T>?> getByAutoIncrementIdList(List<int> ids, {int? limit, String? orderBy}) async
    => getByKeyList(idColumnName, ids, limit: limit, orderBy: orderBy);

  Future<T?> getLastAddedAutoIncrementId() async {
    final res = await queryAll(idColumnName, 1, orderBy: '$idColumnName DESC');

    return res.isNotEmpty ? fromMap(res.first) : null;
  }
}



class LoginProvider extends EntityProvider<LoginSql> {
  const LoginProvider(super.db);


  @override
  String get table => LoginSql.table;

  @override
  List<String> get columns => LoginSql.columns;

  @override
  String get idColumnName => LoginSql.idString;

  @override
  LoginSql Function(Map<String, Object?> p1) get fromMap => LoginSql.fromQueryMap;

  @override
  List<LoginSql> Function(List<Map<String, Object?>> p1) get fromMapList => LoginSql.fromQueryMapList;


  Future<LoginSql?> getByEmail(String id) async => getByPrimaryKey(id, LoginSql.emailString);

}




class UserProvider extends EntityProvider<UserSql> {
  const UserProvider(super.db);


  @override
  String get table => UserSql.table;

  @override
  List<String> get columns => UserSql.columns;

  @override
  String get idColumnName => UserSql.idString;

  @override
  UserSql Function(Map<String, Object?> p1) get fromMap => UserSql.fromQueryMap;

  @override
  List<UserSql> Function(List<Map<String, Object?>> p1) get fromMapList => UserSql.fromMapList;
}





class PurchaseProvider extends EntityProvider<PurchaseSql> {
  const PurchaseProvider(super.db);


  @override
  String get table => PurchaseSql.table;

  @override
  List<String> get columns => PurchaseSql.columns;

  @override
  String get idColumnName => PurchaseSql.idString;

  @override
  PurchaseSql Function(Map<String, Object?> p1) get fromMap => PurchaseSql.fromQueryMap;

  @override
  List<PurchaseSql> Function(List<Map<String, Object?>> p1) get fromMapList => PurchaseSql.fromQueryMapList;
}





class ProductProvider extends EntityProvider<ProductSql> {
  const ProductProvider(super.db);


  @override
  String get table => ProductSql.table;

  @override
  List<String> get columns => ProductSql.columns;

  @override
  String get idColumnName => ProductSql.idString;

  @override
  ProductSql Function(Map<String, Object?> p1) get fromMap => ProductSql.fromQueryMap;

  @override
  List<ProductSql> Function(List<Map<String, Object?>> p1) get fromMapList => ProductSql.fromQueryMapList;
}





class ProductUnitProvider extends EntityProvider<ProductUnitSql> {
  const ProductUnitProvider(super.db);


  @override
  String get table => ProductUnitSql.table;

  @override
  List<String> get columns => ProductUnitSql.columns;

  @override
  String get idColumnName => ProductUnitSql.idString;

  @override
  ProductUnitSql Function(Map<String, Object?> p1) get fromMap => ProductUnitSql.fromQueryMap;

  @override
  List<ProductUnitSql> Function(List<Map<String, Object?>> p1) get fromMapList => ProductUnitSql.fromQueryMapList;
}






class ContributionProvider extends EntityProvider<ContributionSql> {
  const ContributionProvider(super.db);


  @override
  String get table => ContributionSql.table;

  @override
  List<String> get columns => ContributionSql.columns;

  @override
  String get idColumnName => ContributionSql.idString;

  @override
  ContributionSql Function(Map<String, Object?> p1) get fromMap => ContributionSql.fromQueryMap;

  @override
  List<ContributionSql> Function(List<Map<String, Object?>> p1) get fromMapList => ContributionSql.fromQueryMapList;
}
