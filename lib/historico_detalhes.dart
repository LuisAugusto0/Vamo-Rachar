import 'package:flutter/material.dart';

class Purchase {
  const Purchase({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.amount
  });

  final int productId;
  final String productName;
  final double productPrice;
  final int amount;
}

class Participant {
  const Participant({
    required this.name,
    required this.purchases,
    required this.id,
    this.email,
    this.image,
  });


  final String name;
  final int id;
  final List<Purchase> purchases;
  final String? email;
  final String? image;
}

class HistoryData {
  const HistoryData({
    required this.participants,
    required this.totalSpends,
    required this.participantSpends,
    required this.currency
  });

  final List<Participant> participants;
  final double totalSpends;
  final Map<int, double> participantSpends;
  final String currency;
  // Add additional fields like currecy, etc
}

const List<Participant> fallbackParticipantsList = [
  Participant(
    name: 'Alice Smith',
    email: 'alice.smith@example.com',
    id: 0,
    image: null,
    purchases: [
      Purchase(
        productId: 1,
        productName: 'Pizza',
        productPrice: 15.99, // Adjusted to a realistic pizza price
        amount: 1,
      ),
      Purchase(
        productId: 2,
        productName: 'Queijo', // Cheese
        productPrice: 5.50, // Adjusted to a realistic cheese price
        amount: 2,
      ),
    ],
  ),
  Participant(
    name: 'Bob Johnson',
    email: 'bob.johnson@example.com',
    image: null,
    id: 1,
    purchases: [
      Purchase(
        productId: 3,
        productName: 'Omelet',
        productPrice: 9.99, // Adjusted to a realistic omelet price
        amount: 1,
      ),
    ],
  ),
  Participant(
    name: 'Charlie Brown',
    email: 'charlie.brown@example.com',
    image: null,
    id: 2,
    purchases: [
      Purchase(
        productId: 4,
        productName: 'Caviar',
        productPrice: 49.99, // Adjusted to a realistic caviar price
        amount: 1,
      ),
      Purchase(
        productId: 5,
        productName: 'Pao de Queijo', // Brazilian cheese bread
        productPrice: 4.99, // Adjusted to a realistic price
        amount: 1,
      ),
    ],
  ),
];


class HistoryDataExtractor {
  static Map<int, double> _getIndividualPrices(List<Participant> participants) {
    Map<int, double> participantCosts = {};
    for (var participant in fallbackParticipantsList) {
      double individualCost = 0.0;

      for (var purchase in participant.purchases) {
        individualCost += purchase.productPrice * purchase.amount;
      }

      participantCosts[participant.id] = individualCost;
    }

    return participantCosts;
  }

  static double _getTotalPrice(Map<int,double> individualPrices) {
    return individualPrices.values.reduce((sum, cost) => sum + cost);
  }


  // fallback function for now
  static HistoryData fetchHistoryFullData() {
    List<Participant> list = fallbackParticipantsList;
    Map<int,double> individualPrices = _getIndividualPrices(list);
    double totalCost = _getTotalPrice(individualPrices);

    // Fallback implementation
    return HistoryData(
        participants: list,
        participantSpends: individualPrices,
        totalSpends: totalCost,
        currency: 'real'
    );
  }
}




class HistoricoDetails extends StatelessWidget {
  const HistoricoDetails({required this.id, super.key});
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(),
      body: Body(data: HistoryDataExtractor.fetchHistoryFullData()),
    );
  }
}


class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 80,


      leading: IconButton(

        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.close,
          size: 35,
        )
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({required this.data, super.key});
  final HistoryData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              color: Colors.transparent,
              height: 30,
              child: Text(
                "R\$ ${data.totalSpends.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24.0, // Adjust this value to make the text size larger
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ),
          ),
        ),
        Expanded(child: ParticipantList(data: data))
      ],
    );
  }

}

class ParticipantList extends StatelessWidget {
  const ParticipantList({required this.data, super.key});
  final HistoryData data;

  @override
  Widget build(BuildContext context) {
    List<Participant> list = data.participants;
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final participant = list[index];

          if (!data.participantSpends.containsKey(participant.id)) {
            throw Exception('Total spends not found for participant with id: ${participant.id}');
          }
          final double totalSpends = data.participantSpends[participant.id]!;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 4.0),

            child: ParticipantDisplay(
                participant: participant,
                totalSpends: totalSpends
            ),
          );
        }
    );
  }
}


class ParticipantDisplay extends StatelessWidget {
  const ParticipantDisplay({
    required this.participant,
    required this.totalSpends,
    super.key
  });

  final Participant participant;
  final double totalSpends;


  Widget defaultImage() {
    return const Icon (
        Icons.account_circle_outlined,
        size: 100
    );
  }

  Widget getImage(String? image) {
    if (image == null || image == "") {
      return defaultImage();
    }

    if (image.startsWith("http")) {

      return Image.network(
        image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return defaultImage();
        },
      );
    } else {
      return Image.asset(
        image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return defaultImage();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SizedBox(
        height: 120.0, // Increase height to fit the image
        child: ListTile(
          leading: getImage(participant.image),
          title: Text(
            participant.name,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "Gasto total: R\$ ${totalSpends.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            print("Participant ${participant.name} tapped");
          },
        ),
      ),
    );
  }





}


