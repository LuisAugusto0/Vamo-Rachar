/* History viewed from products:
 *  - Each product connect to multiple instances
 *  - Each instance connect to multiple contribution
 *  - Each contribution details how much a user paid for a instance
 *
 * A list of the participants inside the products is also available for
 * easier tracking
 */
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
}


class Contributions {
  const Contributions({
    required this.participant,
    required this.contribution
  });

  // id not needed as there are no searches for each Contribution
  final Participant participant;
  final double contribution;
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
}

class ProductPurchaseHistoryExtractor {
  // static ProductPurchaseHistory extract(int purchaseId) {
  //   // Use purchaseId to obtain values
  // }
}







// Example User

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


