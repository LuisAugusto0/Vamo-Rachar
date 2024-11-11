


/* Sql wrapper converted into specific classes used to display purchase data
 * This conversion is important as to revert the directioning of connections,
 * (product points to multiple units intead of units pointing to product)
 * and allow direct reference access
 */


import 'package:flutter/cupertino.dart';
import 'sql_tables.dart';
import 'database_helper.dart';


class ProductPurchaseHistory {
  const ProductPurchaseHistory({
    required this.products,
    required this.participants,
    required this.spendings,
  });

  final List<Product> products;
  final List<Participant> participants;
  final double spendings;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.instances,
    required this.image,
  });

  final int id;
  final String name;
  final double price;
  final String? image;
  final List<ProductInstances> instances;

  static toList(List<ProductSql> wrappers, Map<int, List<ProductInstances>> hashConnection) {
    final List<Product> res = []; // Initialize an empty map

    for (var wrapper in wrappers) {
      final id = wrapper.id;

      List<ProductInstances>? list = hashConnection[id];
      if (list == null) {
        throw ArgumentError("Big error");
      }

      res.add(Product(
          id: wrapper.id!,
          name: wrapper.name,
          price: wrapper.price,
          image: null,
          instances: list
      ));
    }

    return res;
  }
}


class ProductInstances {
  const ProductInstances({
    required this.id,
    required this.contributions,
    required this.partipants,
  });

  final int id;
  final List<Contributions> contributions;
  final List<Participant> partipants;


  static toList(List<ProductUnitSql> wrappers, Map<int, List<Contributions>> hashConnection) {
    final List<ProductInstances> res = []; // Initialize an empty map

    for (var wrapper in wrappers) {
      final id = wrapper.id!;

      List<Contributions>? list = hashConnection[id];
      if (list == null) {
        throw ArgumentError("Big error");
      }

      List<Participant> participants = list.map((element) {
        return element.participant;
      }).toList();


      res.add(ProductInstances(
          id: wrapper.id!,
          contributions: list,
          partipants: participants
      ));
    }

    return res;
  }
}


class Contributions {
  const Contributions({
    required this.participant,
    required this.contribution
  });

  // id not needed as there are no searches for each Contribution
  final Participant participant;
  final double contribution;

  static Contributions fromSql(ContributionSql wrapper, Map<int, Participant> refs) {
    final participant = refs[wrapper.fkeyUser];

    if (participant == null) {
      throw ArgumentError("No Participant found for user ID ${wrapper.fkeyUser}");
    }

    return Contributions(
        participant: participant,
        contribution: wrapper.paid
    );
  }

  static List<Contributions> fromSqlList(List<ContributionSql> wrappers, Map<int, Participant> refs) {
    return wrappers.map((wrapper) {
      final participant = refs[wrapper.fkeyUser];

      if (participant == null) {
        throw ArgumentError("No Participant found for user ID ${wrapper.fkeyUser}");
      }

      return Contributions(
          participant: participant,
          contribution: wrapper.paid
      );
    }).toList();
  }

  static Map<int, Contributions> toMap(List<ContributionSql> wrappers, Map<int, Participant> refs) {
    final contributionsMap = <int, Contributions>{}; // Initialize an empty map

    for (var wrapper in wrappers) {
      final userId = wrapper.fkeyUser;
      final participant = refs[userId];

      if (participant == null) {
        throw ArgumentError("No Participant found for user ID $userId");
      }

      contributionsMap[wrapper.id!] = Contributions(
          participant: participant,
          contribution: wrapper.paid
      );
    }

    return contributionsMap;
  }
}


class Participant {
  const Participant({
    required this.name,
    required this.id,
    this.email,
    this.image,
  });


  final String name;
  final int id;
  final String? email;
  final String? image;




  static Participant fromSql(UserSql wrapper) {
    return Participant(
        name: wrapper.name,
        id: wrapper.id!,
    );
  }

  static List<Participant> fromSqlList(List<UserSql> wrappers) {
    return wrappers.map((wrapper) => Participant(
        name: wrapper.name,
        id: wrapper.id!,
    )).toList();
  }

  static Map<int, Participant> toMap(List<UserSql> wrappers) {
    return {
      for (var wrapper in wrappers)
        wrapper.id!: Participant(
          name: wrapper.name,
          id: wrapper.id!,
        )
    };
  }
}



//
// class ProductPurchaseHistoryExtractor {
//
//
//   static Future<ProductPurchaseHistory> extract(int purchaseId) async {
//     final dbHelper = DatabaseHelper();
//
//     // Get list of products
//     List<ProductSql>? productWrappers =
//       await dbHelper.getProductFromKey(purchaseId, ProductSql.idString);
//
//     if (productWrappers == null) throw ArgumentError("sql request for list of products returned empty");
//     List<int> productIds = productWrappers.map((product) => product.id!).toList();
//
//     // Get list of product units through product ids
//     List<ProductUnitSql>? productUnitWrappers =
//       await dbHelper.getProductUnitFromKeyList(productIds, ProductUnitSql.idString);
//
//     if (productUnitWrappers == null)  throw ArgumentError("sql request for list of pruchases returned empty");
//     List<int> productUnitIds = productWrappers.map((product) => product.id!).toList();
//
//
//     // Get list of contributions through all product units ids
//     List<ContributionSql>? contributionWrappers =
//       await dbHelper.getContributionFromKeyList(productUnitIds, ContributionSql.idString);
//
//     if (contributionWrappers == null)  throw ArgumentError("sql request for list of contribution returned empty");
//     Set<int> userIdsHash = {};
//
//     for (var contribution in contributionWrappers) {
//       userIdsHash.add(contribution.fkeyUser);
//     }
//
//     List<int> userIdList = userIdsHash.toList();
//
//
//     // Get list of users from all contributions
//     List<UserSql>? users = await dbHelper.getUserFromKeyList(userIdList, UserSql.idString);
//     if (users == null)   throw ArgumentError("sql request for list of pruchases returned empty");
//     Map<int, Participant> participant = Participant.toMap(users);
//     List<Contributions> contributions = Contributions.fromSqlList(contributionWrappers, participant);
//
//     Map<int, List<Contributions>> unitConnectionToContribution = {};
//
//     for (var contribution in contributionWrappers) {
//       final productUnitId = contribution.fkeyUser;
//
//       // If the id doesn't exist in the map, initialize an empty list
//       if (!unitConnectionToContribution.containsKey(productUnitId)) {
//         unitConnectionToContribution[productUnitId] = [];
//       }
//
//       // Add the contribution to the list for this id
//       var instance = contributions[contribution.id!];
//       unitConnectionToContribution[productUnitId]!.add(instance);
//     }
//
//     List<ProductInstances> units = ProductInstances.toList(productUnitWrappers, unitConnectionToContribution);
//
//
//
//     Map<int, List<ProductInstances>> contributionsAssociatedToUnits = { };
//
//     for (var unit in productUnitWrappers) {
//       final productId = unit.fkeyProduct;
//
//       // If the id doesn't exist in the map, initialize an empty list
//       if (!contributionsAssociatedToUnits.containsKey(productId)) {
//         contributionsAssociatedToUnits[productId] = [];
//       }
//
//       // Add the contribution to the list for this id
//       var instance = units[unit.id!];
//       contributionsAssociatedToUnits[productId]!.add(instance);
//     }
//
//     List<Product> products = Product.toList(productWrappers, contributionsAssociatedToUnits);
//
//     double totalPrice = 0;
//     for (var product in products) {
//       totalPrice += product.price * product.instances.length;
//     }
//
//     final res = ProductPurchaseHistory(
//         products: products,
//         participants: Participant.fromSqlList(users),
//         spendings: totalPrice
//     );
//
//     debugPrint(res.spendings.toString());
//     for (var participant in res.participants) {
//       debugPrint(participant.name);
//     }
//
//     return res;
//   }
//
// }
//








// ---- Example User ----

const alice = Participant(
  name: "Alice",
  id: 1,
  email: "alice@example.com",
  image: "alice.jpg",
);

const bob = Participant(
  name: "Bob",
  id: 2,
  email: "bob@example.com",
  image: "bob.jpg",
);

const charlie = Participant(
  name: "Charlie",
  id: 3,
  email: "charlie@example.com",
  image: "charlie.jpg",
);

const david = Participant(
  name: "David",
  id: 4,
  email: "david@example.com",
  image: "david.jpg",
);

// Now create the ProductPurchaseHistory using references to the existing participants
const defaultProductPurchaseHistory = ProductPurchaseHistory(
  products: [
    Product(
      id: 1,
      name: "SuperWidget",
      price: 49.99,
      image: null,
      instances: [
        ProductInstances(
          id: 101,
          partipants: [alice, bob],
          contributions: [
            Contributions(
              participant: alice,
              contribution: 25.00,
            ),
            Contributions(
              participant: bob,
              contribution: 24.99,
            ),
          ],
        ),
        ProductInstances(
          id: 102,
          partipants: [charlie],
          contributions: [
            Contributions(
              participant: charlie,
              contribution: 49.99,
            ),
          ],
        ),
      ],
    ),
    Product(
      id: 2,
      name: "MegaGadget",
      price: 79.99,
      image: null,
      instances: [
        ProductInstances(
          id: 201,
          partipants: [alice, david],
          contributions: [
            Contributions(
              participant: alice,
              contribution: 40.00,
            ),
            Contributions(
              participant: david,
              contribution: 39.99,
            ),
          ],
        ),
      ],
    ),
  ],
  participants: [alice, bob, charlie, david],
  spendings: 179.97
);


