import 'package:sqflite/sqflite.dart';
import 'package:vamorachar/constants/pair.dart';

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




typedef TableFromMapFunction = StringFunctionPair<SqlTable Function(Map<String, dynamic>)>;
typedef TableFromMapListFunction = StringFunctionPair<List<SqlTable> Function(List<Map<String, dynamic>>)>;



// Contains a unique identifier
abstract class SqlTable {
  Map<String, Object?> toMap();
  String getTableName();
  List<String> getColumns();
  List<String> getPrimaryKeys();
}

abstract class EntityTable extends SqlTable {
  int? getId();
}

class LoginSql implements EntityTable {
  static const String table = 'login';

  static const List<String> columns = [idString, nameString, emailString, passwordString, imageUrlString];
  static const List<String> primaryKeys = [idString, emailString];

  static const String idString = 'id';
  static const String nameString = 'nome';
  static const String emailString = 'email';
  static const String passwordString = 'senha';
  static const String imageUrlString = 'imagem';



  final int? id;
  final String name;
  final String email;
  final String password;
  final String? imageUrl;

  const LoginSql({
    this.id, //not required when inserting

    required this.name,
    required this.email,
    required this.password,
    this.imageUrl,

  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;

  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map =  {
      nameString : name,
      emailString : email,
      passwordString : password,
      imageUrlString : imageUrl
    };

    if (id != null) map[idString] = id!;
    return map;
  }

  static void assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(nameString) && data[nameString] is String,
    'Map is missing the correct $nameString field');

    assert (data.containsKey(emailString) && data[emailString] is String,
    'Map is missing the correct $emailString field');

    assert (data.containsKey(passwordString) && data[passwordString] is String,
    'Map is missing the correct $passwordString field');

    assert (data.containsKey(imageUrlString) && data[imageUrlString] is String?,
    'Map is missing the correct $imageUrlString field');
  }

  // From sql queries. Therefore id must non nullable
  static LoginSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return LoginSql(
      id: data[idString] as int,
      name: data[nameString] as String,
      email: data[emailString] as String,
      password: data[passwordString] as String,
      imageUrl: data[imageUrlString] as String?,
    );
  }

  static List<LoginSql> fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }



  @override
  String toString() {
    return '''LoginSqlResponse(
      $idString: $id, 
      $nameString: $name, 
      $emailString: $email, 
      $passwordString: $password,  
      $imageUrlString: $imageUrl
    )''';
  }
}




class UserSql implements EntityTable {
  static const String table = 'usuario';

  static const List<String> columns = [idString, nameString, fkeyLoginString];
  static const List<String> primaryKeys = [idString];

  static const String idString = 'id';
  static const String nameString = 'nome';
  static const String fkeyLoginString = 'login_id';

  final int? id;
  final String name;
  final int? fkeyLogin;

  const UserSql({
    this.id,
    required this.name,
    this.fkeyLogin,
  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;


  // id can be nullable here
  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      nameString : name,
      fkeyLoginString : fkeyLogin
    };

    if (id != null) {
      map[idString] = id!;
    }
    return map;
  }

  static void assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(nameString) && data[nameString] is String,
    'Map is missing the correct $nameString field');

    // assert (!data.containsKey(fkeyLoginString) || data[fkeyLoginString] is int,
    // 'Map is missing the correct $fkeyLoginString field');

  }


  // From sql UserSqlResponse. Therefore id must non nullable
  static UserSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return UserSql(
      id: data[idString] as int,
      name: data[nameString] as String,
      fkeyLogin: data.containsKey(fkeyLoginString) ? data[fkeyLoginString] as int? : null,
    );
  }

  static List<UserSql> fromMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }



  @override
  String toString() {
    return '''UserSqlResponse(
      $idString: $id, 
      $nameString: $name, 
      $fkeyLoginString: $fkeyLogin,
    )''';
  }
}






class UserPurchaseSql implements SqlTable {
  static const String table = 'usuario_pedido';

  static const List<String> columns = [fkeyUserString, fkeyPurchaseString];
  static const List<String> primaryKeys = [];

  static const String fkeyUserString = 'usuario_id';
  static const String fkeyPurchaseString = 'pedido_id';

  final int fkeyUser;
  final int fkeyPurchase;

  UserPurchaseSql({
    required this.fkeyUser,
    required this.fkeyPurchase
  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;



  @override
  Map<String, Object?> toMap() {
    return {
      fkeyUserString : fkeyUser,
      fkeyPurchaseString : fkeyPurchase
    };

  }


  static void assertIsValidQueryMap(Map<String, Object?> data) {

    assert (data.containsKey(fkeyUserString) && data[fkeyUserString] is int,
    'Map is missing the correct $fkeyUserString field for: ');

    assert (data.containsKey(fkeyPurchaseString) && data[fkeyPurchaseString] is int,
    'Map is missing the correct $fkeyPurchaseString field');
  }

  // From sql UserSqlResponse. Therefore id must non nullable
  static UserPurchaseSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return UserPurchaseSql(
      fkeyUser: data[fkeyUserString] as int,
      fkeyPurchase: data[fkeyPurchaseString] as int,
    );
  }

  static List<UserPurchaseSql> fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }


  @override
  String toString() {
    return '''UserSqlResponse(
      $fkeyUserString: $fkeyUser, 
      $fkeyPurchaseString: $fkeyPurchase,
    )''';
  }
}





class PurchaseSql implements EntityTable {
  static const String table = 'pedido';

  static const List<String> columns = [
    idString, establishmentNameString, dateTimeInUnixString,
    longitudeString, latitudeString, fkeyLoginString
  ];
  static const List<String> primaryKeys = [idString];

  static const String idString = 'id';
  static const String establishmentNameString = 'estabelecimento_nome';
  static const String dateTimeInUnixString = 'date_time';
  static const String longitudeString = 'longitude';
  static const String latitudeString = 'latitude';
  static const String fkeyLoginString = 'login_responsavel_id';

  final int? id;
  final String? establishmentName;
  final int dateTimeInUnix;
  final double? longitude;
  final double? latitude;
  final int fkeyLogin;

  const PurchaseSql({
    this.id,
    this.establishmentName,
    required this.dateTimeInUnix,
    this.longitude,
    this.latitude,
    required this.fkeyLogin
  });


  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;

  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map =  {
      establishmentNameString : establishmentName,
      dateTimeInUnixString : dateTimeInUnix,
      longitudeString : longitude,
      latitudeString : latitude,
      fkeyLoginString : fkeyLogin
    };

    if (id != null) map[idString] = id!;
    return map;
  }


  static void assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(establishmentNameString) && data[establishmentNameString] is String?,
    'Map is missing the correct $establishmentNameString field');

    assert (data.containsKey(dateTimeInUnixString) && data[dateTimeInUnixString] is int,
    'Map is missing the correct $dateTimeInUnixString field');

    assert (data.containsKey(longitudeString) && data[longitudeString] is double?,
    'Map is missing the correct $longitudeString field');

    assert (data.containsKey(latitudeString) && data[latitudeString] is double?,
    'Map is missing the correct $latitudeString field');

    assert (data.containsKey(fkeyLoginString) && data[fkeyLoginString] is int,
    'Map is missing the correct $fkeyLoginString field');
  }


  // From sql UserSqlResponse. Therefore id must non nullable
  static PurchaseSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return PurchaseSql(
      id: data[idString] as int,
      establishmentName: data[establishmentNameString] as String?,
      dateTimeInUnix: data[dateTimeInUnixString] as int,
      longitude: data[longitudeString] as double?,
      latitude: data[latitudeString] as double?,
      fkeyLogin: data[fkeyLoginString] as int
    );
  }

  static List<PurchaseSql> fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }


  @override
  String toString() {
    return '''UserSqlResponse(
      $idString: $id, 
      $establishmentNameString: $establishmentName, 
      $dateTimeInUnixString: $dateTimeInUnix,
      $longitudeString: $longitude,
      $latitudeString: $latitude,
      $fkeyLoginString: $fkeyLogin,
    )''';
  }
}





class ProductSql implements EntityTable {
  static const String table = 'produto';

  static const List<String> columns = [idString, nameString, priceString, fkeyPurchaseString];
  static const List<String> primaryKeys = [idString];

  static const String idString = 'id';
  static const String nameString = 'nome';
  static const String priceString = 'preco';
  static const String fkeyPurchaseString = 'pedido_id';

  final int? id;
  final String name;
  final double price;
  final int fkeyPurchase;


  const ProductSql({
    this.id,
    required this.name,
    required this.price,
    required this.fkeyPurchase,
  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;

  // id can be nullable here
  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map =  {
      nameString : name,
      priceString : price,
      fkeyPurchaseString : fkeyPurchase,
    };

    if (id != null) map[idString] = id!;
    return map;
  }


  static assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(nameString) && data[nameString] is String,
    'Map is missing the correct $nameString field');

    assert (data.containsKey(priceString) && data[priceString] is double,
    'Map is missing the correct $priceString field');

    assert (data.containsKey(fkeyPurchaseString) && data[fkeyPurchaseString] is int,
    'Map is missing the correct $fkeyPurchaseString field');
  }


  // From sql UserSqlResponse. Therefore id must non nullable
  static ProductSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return ProductSql(
        id: data[idString] as int,
        name: data[nameString] as String,
        price: data[priceString] as double,
        fkeyPurchase: data[fkeyPurchaseString] as int,
    );
  }

  static List<ProductSql > fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }


  @override
  String toString() {
    return '''UserSqlResponse(
      $idString: $id, 
      $nameString: $name, 
      $priceString: $price,
      $fkeyPurchaseString: $fkeyPurchase,
    )''';
  }


}





class ProductUnitSql implements EntityTable {
  static const String table = 'unidade_produto';

  static const List<String> columns = [idString, fkeyProductString];
  static const List<String> primaryKeys = [idString];

  static const String idString = 'id';
  static const String fkeyProductString = 'produto_id';

  final int? id;
  final int fkeyProduct;

  const ProductUnitSql({
    this.id,
    required this.fkeyProduct,
  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;

  // id can be nullable here
  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map =  {
      fkeyProductString : fkeyProduct,
    };

    if (id != null) map[idString] = id!;
    return map;
  }



  static void assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(fkeyProductString) && data[fkeyProductString] is int,
    'Map is missing the correct $fkeyProductString field');
  }

  // From sql UserSqlResponse. Therefore id must non nullable
  static ProductUnitSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return ProductUnitSql(
      id: data[idString] as int,
      fkeyProduct: data[fkeyProductString] as int,
    );
  }

  static List<ProductUnitSql> fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }


  @override
  String toString() {
    return '''UserSqlResponse(
      $idString: $idString, 
      $fkeyProductString: $fkeyProduct, 
    )''';
  }

}





class ContributionSql implements EntityTable {
  static const String table = 'contribuicao';

  static const List<String> columns = [idString, paidString, fkeyProductUnitString, fkeyUserString];
  static const List<String> primaryKeys = [idString];

  static const String idString = 'id';
  static const String paidString = 'preco_pago';
  static const String fkeyProductUnitString = 'unidade_produto_id';
  static const String fkeyUserString = 'usuario_id';

  final int? id;
  final double paid;
  final int fkeyProductUnit;
  final int fkeyUser;


  const ContributionSql({
    this.id,
    required this.paid,
    required this.fkeyProductUnit,
    required this.fkeyUser
  });

  @override
  String getTableName() => table;

  @override
  List<String> getColumns() => columns;

  @override
  List<String> getPrimaryKeys() => primaryKeys;

  @override
  int? getId() => id;

  @override
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      paidString : paid,
      fkeyProductUnitString : fkeyProductUnit,
      fkeyUserString : fkeyUser,
    };

    if (id != null) map[idString] = id;
    return map;
  }


  static assertIsValidQueryMap(Map<String, Object?> data) {
    assert (data.containsKey(idString) && data[idString] is int,
    'Map is missing the correct $idString field');

    assert (data.containsKey(paidString) && data[paidString] is double,
    'Map is missing the correct $paidString field');

    assert (data.containsKey(fkeyProductUnitString) && data[fkeyProductUnitString] is int,
    'Map is missing the correct $fkeyProductUnitString field');

    assert (data.containsKey(fkeyUserString) && data[fkeyUserString] is int,
    'Map is missing the correct $fkeyUserString field');
  }

  // From sql UserSqlResponse. Therefore id must non nullable
  static ContributionSql fromQueryMap(Map<String, Object?> data) {
    assertIsValidQueryMap(data);

    return ContributionSql(
      id: data[idString] as int,
      paid: data[paidString] as double,
      fkeyProductUnit: data[fkeyProductUnitString] as int,
      fkeyUser: data[fkeyUserString] as int,
    );
  }

  static List<ContributionSql> fromQueryMapList(List<Map<String, dynamic>> data) {
    return data.map((map) => fromQueryMap(map)).toList();
  }


  @override
  String toString() {
    return '''UserSqlResponse(
      $idString: $id, 
      $paidString: $paid, 
      $fkeyProductUnitString: $fkeyProductUnit, 
      $fkeyUserString: $fkeyUser, 
    )''';
  }
}
