


/* Sql wrapper converted into specific classes used to display purchase data
 * This conversion is important as to revert the directioning of connections,
 * (product points to multiple units intead of units pointing to product)
 * and allow direct reference access
 */


import 'package:vamorachar/database/sql_providers.dart';
import 'sql_tables.dart';
import 'database_helper.dart';




class PurchaseHistory {
  const PurchaseHistory({
    required this.products,
    required this.participants,
    required this.spendings,
    required this.dateTime,
    required this.location,
    this.establishmentName
  });

  final List<Product> products;
  final List<UserSql> participants;
  final double spendings;
  final DateTime dateTime;
  final String location;
  final String? establishmentName;

  // Creates new structure for Contribution that contains reference to user
  // The reason a map is needed is because the whole set can be obtained in one query, which is better than doing a
  // query for each specific contribution on its users
  //
  // This pattern is repeated on all gets
  static List<Contributions> _getContributions(List<ContributionSql> contributions, List<UserSql> userList) {
    // Type unsafe code!! sql table needs to be changed
    Map<int, UserSql> userSetMap = { for (var user in userList) user.id! : user };

    List<Contributions> list = [];
    for (var sql in contributions) {
      UserSql? associatedUser = userSetMap[sql.fkeyUser];
      if (associatedUser == null) throw Exception("Contribution association is broken! (key: ${sql.fkeyUser} of contribution: ${sql.id}");

      list.add(Contributions(id: sql.id!, productInstanceFkey: sql.fkeyProductUnit, participant: associatedUser, paid: sql.paid));
    }
    return list;
  }


  // The connection for this one uses foreign key children to parent. Therefore the children (contribution) is used
  // to update a list of connections from the parent (productUnit)
  static List<ProductInstances> _getProductInstances(List<Contributions> contributionList, List<ProductUnitSql> productUnits) {

    // List with not connections
    List<ProductInstances> list = productUnits.map((unit) => ProductInstances(id: unit.id!, productForeignKey: unit.fkeyProduct)).toList();
    Map<int, ProductInstances> productInstanceSetMap = { for (var instance in list) instance.id : instance };


    int i = 0;
    for (var contribution in contributionList) {
      i++;
      ProductInstances? associatedProductInstance = productInstanceSetMap[contribution.productInstanceFkey];
      if (associatedProductInstance == null) throw Exception("Product Instance association is broken! (key: ${contribution.productInstanceFkey}), $i");

      associatedProductInstance.contributions.add(contribution);
    }
    return list;
  }


  static List<Product> _getProduct(List<ProductInstances> productInstanceList, List<ProductSql> products) {

    // List with not connections
    List<Product> list = products.map(
            (sql) => Product(id: sql.id!, name: sql.name, price: sql.price)
    ).toList();

    Map<int, Product> productSetMap = { for (var instance in list) instance.id : instance };


    for (var productInstance in productInstanceList) {
      Product? associatedProductInstance = productSetMap[productInstance.productForeignKey];
      if (associatedProductInstance == null) throw Exception("Product association is broken!");

      associatedProductInstance.instances.add(productInstance);
    }
    return list;
  }




  static Future<PurchaseHistory> buildFromSql (DatabaseHelper dbHelper, PurchaseSql purchase) async {
    // Need a new structure where id is never null... this is getting too unsafe
    int? purchaseId = purchase.id;
    if (purchaseId == null) throw Exception("Expected not null");


    // Get products
    ProductProvider productProvider = ProductProvider(dbHelper);
    List<ProductSql>? products = await productProvider.getByKey(purchaseId, ProductSql.fkeyPurchaseString);
    if (products == null) throw Exception("Product not expected to be empty");
    List<int> productIds = products.map((product) => product.id!).toList();


    // Get product units
    ProductUnitProvider productUnitProvider = ProductUnitProvider(dbHelper);
    List<ProductUnitSql> productUnits = await productUnitProvider.getByKeyList(
        ProductUnitSql.fkeyProductString, productIds
    );
    if (productUnits.isEmpty) throw Exception("Products not found");
    List<int> productUnitsIds = productUnits.map((productUnit) => productUnit.id!).toList();


    // Get contribution for product units
    ContributionProvider contributionProvider = ContributionProvider(dbHelper);
    List<ContributionSql> contributions = await contributionProvider.getByKeyList(
        ContributionSql.fkeyProductUnitString, productUnitsIds
    );
    if (contributions.isEmpty) throw Exception("Contributions not found");

    // Get user ids
    Set<int> userIdsSet = {};
    for (var contribution in contributions) {
      userIdsSet.add(contribution.fkeyUser);
    }
    List<int> userIds = userIdsSet.toList();

    // Get Users
    UserProvider userProvider = UserProvider(dbHelper);
    List<UserSql>? users = await userProvider.getByAutoIncrementIdList(userIds);
    if (users == null) throw Exception("Users not found");


    // Get linked structures
    List<Contributions> linkedContributions = _getContributions(contributions, users);
    List<ProductInstances> linkedProductUnits = _getProductInstances(linkedContributions, productUnits);

    // In the end, linkedProduct is expected to link all other structures together by itself, on a tree-like structure
    List<Product> linkedProduct = _getProduct(linkedProductUnits, products);

    // Get spendings through product prices
    double spendings = 0;
    for (final product in linkedProduct) {
      spendings += product.price * product.instances.length;
    }

    // Get location
    String? locationName = "LOCATION NOT IMPLEMENTED";

    // Get time
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(purchase.dateTimeInUnix);

    return PurchaseHistory(
      products: linkedProduct,
      participants: users,

      spendings: spendings,
      location: locationName,
      dateTime: dateTime,

      establishmentName: purchase.establishmentName,
      //image: NOT IMPLEMENTED
    );
  }
}


class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
  });

  final int id;
  final String name;
  final double price;
  final String? image = null; //dropped

  // filled on iterations
  final List<ProductInstances> instances = [];

  static Product createWithInstances({
    required int id,
    required String name,
    required double price,
    required List<ProductInstances> instances
  }) {
    var instance = Product(id: id, name: name, price: price);

    // inefficient as heck, only use for debugging
    instance.instances.addAll(instances);

    return instance;
  }
}


class ProductInstances {
  ProductInstances({
    required this.id,
    required this.productForeignKey
  });

  final int id;
  final int productForeignKey;

  //Expandable on iterations
  final List<Contributions> contributions = [];

  static ProductInstances createWithContributions({
    required int id,
    required int productForeignKey,
    required List<Contributions> contributions

  }) {
    var instance = ProductInstances(id: id, productForeignKey: productForeignKey);

    // inefficient as heck, only use for debugging
    instance.contributions.addAll(contributions);

    return instance;
  }
}



class Contributions {
  const Contributions({
    required this.id,
    required this.participant,
    required this.paid,
    required this.productInstanceFkey
  });

  final int id;
  final UserSql participant;
  final double paid;
  final int productInstanceFkey;
}



// ---- Example User ----

const alice = UserSql(
  name: "Alice",
  id: 1,
);

const bob = UserSql(
  name: "Bob",
  id: 2,
);

const charlie = UserSql(
  name: "Charlie",
  id: 3,
);

const david = UserSql(
  name: "David",
  id: 4,
);



// Now create the ProductPurchaseHistory using references to the existing participants
var defaultProductPurchaseHistory = PurchaseHistory(
    products: [
      Product.createWithInstances(
        id: 1,
        name: "SuperWidget",
        price: 49.99,
        instances: [
          ProductInstances.createWithContributions(
            productForeignKey: 1,
            id: 101,
            contributions: [
              Contributions(
                id: alice.id!,
                participant: alice,
                paid: 25.00,
                productInstanceFkey: 101
              ),
              Contributions(
                id: bob.id!,
                participant: bob,
                paid: 24.99,
                productInstanceFkey: 101
              ),
            ],
          ),
          ProductInstances.createWithContributions(
            id: 102,
            productForeignKey: 1,
            contributions: [
              Contributions(
                id: charlie.id!,
                participant: charlie,
                paid: 49.99,
                productInstanceFkey: 102
              ),
            ],
          ),
        ],
      ),
      Product.createWithInstances(
        id: 2,
        name: "MegaGadget",
        price: 79.99,
        instances: [
          ProductInstances.createWithContributions(
            id: 201,
            productForeignKey: 2,
            contributions: [
              Contributions(
                id: alice.id!,
                participant: alice,
                paid: 40.00,
                productInstanceFkey: 201
              ),
              Contributions(
                id: david.id!,
                participant: david,
                paid: 39.99,
                productInstanceFkey: 201
              ),
            ],
          ),
        ],
      ),
    ],
    participants: [alice, bob, charlie, david],
    spendings: 179.97, dateTime: DateTime.now(), location: 'LOCATION'
);


