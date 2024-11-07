/* History viewed from products:
 *  - Each product connect to multiple instances
 *  - Each instance connect to multiple contribution
 *  - Each contribution details how much a user paid for a instance
 *
 * A list of the participants inside the products is also available for
 * easier tracking
 */
import 'dart:collection';

import 'package:vamorachar_telacadastro/widgets/database_helper.dart';

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

  static toList(List<ProductSqlWrapper> wrappers, Map<int, List<ProductInstances>> hashConnection) {
    final List<Product> res = []; // Initialize an empty map

    for (var wrapper in wrappers) {
      final id = wrapper.getId();

      List<ProductInstances>? list = hashConnection[id];
      if (list == null) {
        throw ArgumentError("Big error");
      }

      res.add(Product(
          id: wrapper.getId(),
          name: wrapper.getNome(),
          price: wrapper.getPreco(),
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


  static toList(List<ProductUnitSqlWrapper> wrappers, Map<int, List<Contributions>> hashConnection) {
    final List<ProductInstances> res = []; // Initialize an empty map

    for (var wrapper in wrappers) {
      final id = wrapper.getId();

      List<Contributions>? list = hashConnection[id];
      if (list == null) {
        throw ArgumentError("Big error");
      }

      List<Participant> participants = list.map((element) {
        return element.participant;
      }).toList();


      res.add(ProductInstances(
          id: wrapper.getId(),
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

  static Contributions fromSql(ContributionsSqlWrapper wrapper, Map<int, Participant> refs) {
    final participant = refs[wrapper.getFkeyUser()];

    if (participant == null) {
      throw ArgumentError("No Participant found for user ID ${wrapper.getFkeyUser()}");
    }

    return Contributions(
        participant: participant,
        contribution: wrapper.getPrice()
    );
  }

  static List<Contributions> fromSqlList(List<ContributionsSqlWrapper> wrappers, Map<int, Participant> refs) {
    return wrappers.map((wrapper) {
      final participant = refs[wrapper.getFkeyUser()];

      if (participant == null) {
        throw ArgumentError("No Participant found for user ID ${wrapper.getFkeyUser()}");
      }

      return Contributions(
          participant: participant,
          contribution: wrapper.getPrice()
      );
    }).toList();
  }

  static Map<int, Contributions> toMap(List<ContributionsSqlWrapper> wrappers, Map<int, Participant> refs) {
    final contributionsMap = <int, Contributions>{}; // Initialize an empty map

    for (var wrapper in wrappers) {
      final userId = wrapper.getFkeyUser();
      final participant = refs[userId];

      if (participant == null) {
        throw ArgumentError("No Participant found for user ID $userId");
      }

      contributionsMap[wrapper.getId()] = Contributions(
          participant: participant,
          contribution: wrapper.getPrice()
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




  static Participant fromSql(UserSqlWrapper wrapper) {
    return Participant(
        name: wrapper.getName(),
        id: wrapper.getId(),
        email: wrapper.getEmail(),
        image: wrapper.getImageUrl()
    );
  }

  static List<Participant> fromSqlList(List<UserSqlWrapper> wrappers) {
    return wrappers.map((wrapper) => Participant(
        name: wrapper.getName(),
        id: wrapper.getId(),
        email: wrapper.getEmail(),
        image: wrapper.getImageUrl()
    )).toList();
  }

  static Map<int, Participant> toMap(List<UserSqlWrapper> wrappers) {
    return {
      for (var wrapper in wrappers)
        wrapper.getId(): Participant(
          name: wrapper.getName(),
          id: wrapper.getId(),
          email: wrapper.getEmail(),
          image: wrapper.getImageUrl(),
        )
    };
  }
}




class ProductPurchaseHistoryExtractor {
  final dbHelper = DatabaseHelper();

  Future<ProductPurchaseHistory> extract(int productId) async {
    // Get list of products
    List<ProductSqlWrapper>? productWrappers = await dbHelper.productListFromPurchase(productId);

    if (productWrappers == null) return Future.error("sql request for list of products returned empty");
    List<int> productIds = productWrappers.map((product) => product.getId()).toList();

    // Get list of product units through product ids
    List<ProductUnitSqlWrapper>? productUnitWrappers = await dbHelper.productUnitListFromProductList(productIds);

    if (productUnitWrappers == null) return Future.error("sql request for list of pruchases returned empty");
    List<int> productUnitIds = productWrappers.map((product) => product.getId()).toList();


    // Get list of contributions through all product units ids
    List<ContributionsSqlWrapper>? contributionWrappers = await dbHelper.contributionListFromProductUnitList(productUnitIds);

    if (contributionWrappers == null) return Future.error("sql request for list of contributions returned empty");
    Set<int> userIdsHash = {};

    for (var contribution in contributionWrappers) {
      userIdsHash.add(contribution.getFkeyUser());
    }

    List<int> userIdList = userIdsHash.toList();


    // Get list of users from all contributions
    List<UserSqlWrapper>? users = await dbHelper.userListFromUserId(userIdList);
    if (users == null) return Future.error("sql request for list of contributions returned empty");
    Map<int, Participant> participant = Participant.toMap(users);
    List<Contributions> contributions = Contributions.fromSqlList(contributionWrappers, participant);

    Map<int, List<Contributions>> unitConnectionToContribution = {};

    for (var contribution in contributionWrappers) {
      final productUnitId = contribution.getFkeyProductUnit();

      // If the id doesn't exist in the map, initialize an empty list
      if (!unitConnectionToContribution.containsKey(productUnitId)) {
        unitConnectionToContribution[productUnitId] = [];
      }

      // Add the contribution to the list for this id
      var instance = contributions[contribution.getId()];
      unitConnectionToContribution[productUnitId]!.add(instance);
    }

    List<ProductInstances> units = ProductInstances.toList(productUnitWrappers, unitConnectionToContribution);



    Map<int, List<ProductInstances>> contributionsAssociatedToUnits = { };

    for (var unit in productUnitWrappers) {
      final productId = unit.getFkeyProduct();

      // If the id doesn't exist in the map, initialize an empty list
      if (!contributionsAssociatedToUnits.containsKey(productId)) {
        contributionsAssociatedToUnits[productId] = [];
      }

      // Add the contribution to the list for this id
      var instance = units[unit.getId()];
      contributionsAssociatedToUnits[productId]!.add(instance);
    }

    List<Product> products = Product.toList(productWrappers, contributionsAssociatedToUnits);

    double totalPrice = 0;
    for (var product in products) {
      totalPrice += product.price * product.instances.length;
    }

    return ProductPurchaseHistory(products: products, participants: Participant.fromSqlList(users), spendings: totalPrice);
  }

}









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


