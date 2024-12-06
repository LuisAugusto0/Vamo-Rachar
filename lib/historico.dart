import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vamorachar/database/database_helper.dart';
import 'package:vamorachar/database/sql_providers.dart';
import 'package:vamorachar/database/sql_tables.dart';
import 'package:vamorachar/historico_detalhes.dart';
import 'package:vamorachar/widgets/navigation_helper.dart';

class HistoryData {
  const HistoryData({
    required this.location,
    required this.dateTime,
    required this.users,
    required this.id,
    this.establishment,
    this.image,
  });

  final String? establishment;
  final String? image;
  final String location;
  final DateTime dateTime;
  final List<UserSql> users;
  final int id;

  static Future<HistoryData> buildFromSql (DatabaseHelper dbHelper, PurchaseSql purchase) async {
    // Need a new structure where id is never null... this is getting too unsafe
    int? purchaseId = purchase.id;
    if (purchaseId == null) throw Exception("Expected not null");

    ProductProvider productProvider = ProductProvider(dbHelper);
    List<ProductSql>? products = await productProvider.getByKey(purchaseId, ProductSql.fkeyPurchaseString);
    if (products == null) throw Exception("Product not expected to be empty");
    List<int> productIds = products.map((product) => product.id!).toList();

    ProductUnitProvider productUnitProvider = ProductUnitProvider(dbHelper);
    List<ProductUnitSql> productUnits = await productUnitProvider.getByKeyList(
        ProductUnitSql.fkeyProductString, productIds
    );
    if (productUnits.isEmpty) throw Exception("Products not found");
    List<int> productUnitsIds = productUnits.map((productUnit) => productUnit.id!).toList();

    ContributionProvider contributionProvider = ContributionProvider(dbHelper);
    List<ContributionSql> contributions = await contributionProvider.getByKeyList(
        ContributionSql.fkeyProductUnitString, productUnitsIds
    );
    if (contributions.isEmpty) throw Exception("Contributions not found");

    // Get only unique instances
    Set<int> userIdsSet = {};
    for (var contribution in contributions) {
      userIdsSet.add(contribution.fkeyUser);
    }
    List<int> userIds = userIdsSet.toList();
    
    UserProvider userProvider = UserProvider(dbHelper);
    List<UserSql>? users = await userProvider.getByAutoIncrementIdList(userIds);
    if (users == null) throw Exception("Users not found");

    String? locationName = "LOCATION NOT IMPLEMENTED";

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(purchase.dateTimeInUnix);
    print(purchase.dateTimeInUnix);
    return HistoryData(
      id: purchaseId,
      location: locationName,
      dateTime: dateTime,
      users: users,
      establishment: purchase.establishmentName,
      //image: NOT IMPLEMENTED
    );
  }

  static const int displayCount = 10;
  static Future<List<HistoryData>> getAllOnRange(DatabaseHelper dbHelper, int offset) async {
    PurchaseProvider purchaseProvider = PurchaseProvider(dbHelper);

    // id is autoincrement, so you want to get descending order for history
    String orderby = SqlProvider.getSimpleOrderBy(PurchaseSql.dateTimeInUnixString, false);
    List<PurchaseSql> purchases = await purchaseProvider.getFirstResults(PurchaseSql.idString, displayCount, orderBy: orderby, offset: offset);

    List<HistoryData> list = [];
    for(int i = 0; i < purchases.length; i++) {
      list.add(await buildFromSql(dbHelper, purchases[i]));
    }
    return list;
  }
}

//
//
// final List<HistoryData> fallbackList = [
//   HistoryData(
//     location: "Central Park, NYC",
//     dateTime: DateTime(2024, 10, 2, 15, 30),
//     participants: [
//       const Participants(
//           name: "Alice Smith",
//           id: 0,
//       ),
//       const Participants(
//           name: "Bob Johnson",
//           id: 1,
//       )
//     ],
//     establishment: "Park Cafe",
//     image: "",
//   ),
//   HistoryData(
//     location: "The Louvre, Paris",
//     dateTime: DateTime(2023, 6, 15, 10, 0),
//     participants: [
//       const Participants(
//           name: "Chloe Brown",
//           id: 2,
//       ),
//       const Participants(
//           name: "David Wilson",
//           id: 3,
//       ),
//     ],
//     establishment: "Cafe Marly",
//     image: "https://picsum.photos/200",
//   ),
//   HistoryData(
//     location: "Tokyo Tower, Tokyo",
//     dateTime: DateTime(2023, 7, 5, 18, 45),
//     participants: [
//       const Participants(
//           name: "Emily Davis",
//           id: 4,
//       ),
//       const Participants(
//           name: "Frank Martinez",
//           id: 5,
//       ),
//     ],
//     establishment: null,
//     image: "https://picsum.photos/200",
//   ),
//   HistoryData(
//     location: "Eiffel Tower, Paris",
//     dateTime: DateTime(2023, 8, 10, 12, 0),
//     participants: [
//       const Participants(
//           name: "Grace Lee",
//           id: 6,
//       ),
//       const Participants(
//           name: "Henry Taylor",
//           id: 7,
//       ),
//     ],
//     establishment: "Le Café de l'Homme",
//     image: "https://picsum.photos/200",
//   ),
//   HistoryData(
//     location: "Sydney Opera House, Sydney",
//     dateTime: DateTime(2023, 9, 20, 14, 30),
//     participants: [
//       const Participants(
//           name: "Isabella Martinez",
//           id: 8,
//       ),
//       const Participants(
//           name: "Jack White",
//           id: 9,
//        ),
//     ],
//     establishment: "Opera Bar",
//     image: "https://picsum.photos/200",
//   ),
//   HistoryData(
//     location: "Colosseum, Rome",
//     dateTime: DateTime(2023, 10, 5, 16, 15),
//     participants: [
//       const Participants(
//           name: "Liam Wilson",
//           id: 10,
//      ),
//       const Participants(
//           name: "Mia Brown",
//           id: 11,
//        ),
//     ],
//     establishment: "Ristorante Aroma",
//     image: "https://picsum.photos/200",
//   ),
// ];

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  late Future<List<HistoryData>> _futureList; // Holds the async result

  @override
  void initState() {
    super.initState();
    _futureList = HistoryData.getAllOnRange(DatabaseHelper(), 0); // Adjust offset and limit as needed
  }

  void onSearchBarChanged(String input) {
    // You can't directly modify a Future-based list; this would apply filtering
    // only after the list has been loaded
    setState(() {
      _futureList = _futureList.then((currentList) {
        if (input.isEmpty) {
          return currentList;
        } else {
          return currentList
              .where((item) => item.location.toLowerCase().contains(input.toLowerCase()))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HistoricoAppbar(onChanged: onSearchBarChanged),
      body: FutureBuilder<List<HistoryData>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading spinner
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error message
          } else if (snapshot.hasData) {
            final list = snapshot.data!;
            return HistoricoBody(list: list); // Render your list
          } else {
            return const Center(child: Text('No data available')); // Empty state
          }
        },
      ),
    );
  }

  // List<HistoryData> currentList = fallbackList; // Initial list
  // List<HistoryData> filteredList = []; // List to hold filtered results
  //
  // @override
  // void initState() {
  //   super.initState();
  //   filteredList = currentList;
  // }
  //
  // // Update here to back-end conversion function to get top n matches
  // void onSearchBarChanged(String input) {
  //   setState(() {
  //     if (input.isEmpty) {
  //       filteredList = currentList;
  //     } else {
  //       filteredList = currentList.where((item) {
  //         return item.location.toLowerCase().contains(input.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: HistoricoAppbar(onChanged: onSearchBarChanged),
  //     body: HistoricoBody(list: filteredList),
  //   );
  // }
}

class HistoricoAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HistoricoAppbar({required this.onChanged, super.key});

  final Function(String) onChanged;

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
          Icons.arrow_back_outlined,
          size: 40,
        ),
      ),

      // leading: Transform.translate(
      //   offset: const Offset(6, 0),  // Desloca o botão 10 pixels à direita
      //   child: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(
      //       Icons.arrow_back_outlined,
      //       size: 40,
      //     ),
      //   ),
      // ),

      title: Expanded(
        child: Row (
          children: [
            Expanded(
              child: SearchBar(
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: const Icon(Icons.search),
                onChanged: onChanged,
              )
            ),
          ]
        )
      ),

    );
  }
}


class HistoricoBody extends StatelessWidget {
  const HistoricoBody({required this.list, super.key});
  final List<HistoryData> list;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
          ),
          textTheme: const TextTheme(
              displayLarge:
              TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              displayMedium:
              TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: HistoryList(list: list),
        ));
  }
}


class HistoryList extends StatelessWidget {
  const HistoryList({required this.list, super.key});

  final List<HistoryData> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final historyItem = list[index]; // Get the current item from the list
          return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0),

              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    titleMedium: const TextStyle(
                      color: Colors.black, // Set your desired color here
                      fontWeight: FontWeight.bold,
                    ),
                    bodyMedium: const TextStyle(
                      color: Colors.black, // Set body text color here
                    ),
                    bodySmall: const TextStyle(
                      color: Colors.grey, // Set caption text color here
                    ),
                  ),
                ),
                child: HistoryWidget(data: historyItem),
              )
          );
        }
      );
  }
}


class HistoryWidget extends StatelessWidget {
  const HistoryWidget({required this.data, super.key});
  final HistoryData data;

  Widget buildWidgetLayout(BuildContext context) {
    return ClipRRect (
      borderRadius: BorderRadius.circular(15.0),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => {
            NavigationHelper.pushNavigatorNoTransition(
              context, HistoricoDetails(id: data.id)
            )
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HistoryItemImage(
                image: data.image, // Add default image
              ),
              Expanded(
                  child: HistoryItemText(historyData: data)
              )
            ],
          )
        )
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return buildWidgetLayout(context);
  }
}


class HistoryItemImage extends StatelessWidget {
  const HistoryItemImage({required this.image, super.key});

  final String? image;


  Widget getDefault() {
    return const Icon(
        Icons.monetization_on,
        size: 50
    );
  }
  Widget? getImage() {
    if (image == "" || image == null) return getDefault();

    String validImage = image!;
    if (validImage.startsWith("http")) {
     
      return Image.network(
        validImage,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return getDefault();
        },
      );
    } else {
      return Image.asset(
        validImage,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return getDefault();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox (
      width: 150,
      height: 150,
      child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: SizedBox(
              height: 100,
                width: 100,
                child: getImage()
            )
          )
      ),

    );
  }
}

class HistoryItemText extends StatelessWidget {
  const HistoryItemText({required this.historyData, super.key});

  final HistoryData historyData;
  static DateTime currentTime = DateTime.now(); //when to recall it?

  String getTimeDifference() {

    final Duration difference = currentTime.difference(historyData.dateTime);


    if (difference.inDays == 0) {
      // Less than 1 day, show in hours, minutes, or seconds
      if (difference.inHours > 0) {
        return '${difference.inHours} horas atrás';

      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutos atrás';
      } else {
        return '${difference.inSeconds} segundos atrás';
      }
    } else if (difference.inDays <= 7) {
      // Less than or equal to 7 days, show in days
      return '${difference.inDays} dias atrás';
    } else {
      // More than 7 days, show the date
      return DateFormat('dd-MM-yyyy').format(historyData.dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (historyData.establishment != null)
            Text(
              historyData.establishment!,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          Text(
            historyData.location,
            style: textTheme.bodyMedium, // Use default body style from TextTheme
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              getTimeDifference(),
              style: textTheme.bodySmall, // Use caption style from TextTheme
            ),
          ),
        ],
      ),
    );
  }
}









