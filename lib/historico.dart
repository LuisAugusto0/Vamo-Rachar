import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vamorachar_telacadastro/historico_detalhes.dart';
import 'package:vamorachar_telacadastro/widgets/navigation_helper.dart';

class Participants {
  const Participants({
    required this.name,
    required this.email,
  });

  final String name;
  final String email; //Usado para buscar mais dados depois
}

class HistoryData {
  const HistoryData({
    required this.location,
    required this.dateTime,
    required this.participants,
    this.establishment,
    this.image,
  });

  final String? establishment;
  final String? image;
  final String location;
  final DateTime dateTime;
  final List<Participants> participants;
  final int id = 0;
}

final List<HistoryData> fallbackList = [
  HistoryData(
    location: "Central Park, NYC",
    dateTime: DateTime(2024, 10, 2, 15, 30),
    participants: [
      const Participants(
          name: "Alice Smith",
          email: "alice@example.com",
      ),
      const Participants(
          name: "Bob Johnson",
          email: "bob@example.com",
      )
    ],
    establishment: "Park Cafe",
    image: "",
  ),
  HistoryData(
    location: "The Louvre, Paris",
    dateTime: DateTime(2023, 6, 15, 10, 0),
    participants: [
      const Participants(
          name: "Chloe Brown",
          email: "chloe@example.com",
      ),
      const Participants(
          name: "David Wilson",
          email: "david@example.com",
      ),
    ],
    establishment: "Cafe Marly",
    image: "https://picsum.photos/200",
  ),
  HistoryData(
    location: "Tokyo Tower, Tokyo",
    dateTime: DateTime(2023, 7, 5, 18, 45),
    participants: [
      const Participants(
          name: "Emily Davis",
          email: "emily@example.com",
      ),
      const Participants(
          name: "Frank Martinez",
          email: "frank@example.com",
      ),
    ],
    establishment: null,
    image: "https://picsum.photos/200",
  ),
  HistoryData(
    location: "Eiffel Tower, Paris",
    dateTime: DateTime(2023, 8, 10, 12, 0),
    participants: [
      const Participants(
          name: "Grace Lee",
          email: "grace@example.com",
      ),
      const Participants(
          name: "Henry Taylor",
          email: "henry@example.com",
      ),
    ],
    establishment: "Le Café de l'Homme",
    image: "https://picsum.photos/200",
  ),
  HistoryData(
    location: "Sydney Opera House, Sydney",
    dateTime: DateTime(2023, 9, 20, 14, 30),
    participants: [
      const Participants(
          name: "Isabella Martinez",
          email: "isabella@example.com",
      ),
      const Participants(
          name: "Jack White",
          email: "jack@example.com",
       ),
    ],
    establishment: "Opera Bar",
    image: "https://picsum.photos/200",
  ),
  HistoryData(
    location: "Colosseum, Rome",
    dateTime: DateTime(2023, 10, 5, 16, 15),
    participants: [
      const Participants(
          name: "Liam Wilson",
          email: "liam@example.com",
     ),
      const Participants(
          name: "Mia Brown",
          email: "mia@example.com",
       ),
    ],
    establishment: "Ristorante Aroma",
    image: "https://picsum.photos/200",
  ),
];

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  List<HistoryData> currentList = fallbackList; // Initial list
  List<HistoryData> filteredList = []; // List to hold filtered results

  @override
  void initState() {
    super.initState();
    filteredList = currentList;
  }

  // Update here to back-end conversion function to get top n matches
  void onSearchBarChanged(String input) {
    setState(() {
      if (input.isEmpty) {
        filteredList = currentList;
      } else {
        filteredList = currentList.where((item) {
          return item.location.toLowerCase().contains(input.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HistoricoAppbar(onChanged: onSearchBarChanged),
      body: HistoricoBody(list: filteredList),
    );
  }
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


      leading: Transform.translate(
        offset: const Offset(6, 0),  // Desloca o botão 10 pixels à direita
        child: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            size: 40,
          ),
        ),
      ),
      title: Expanded(
        child: SearchBar(
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search),
          onChanged: onChanged,
        ),
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
          padding: const EdgeInsets.all(12),
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

              child: HistoryWidget(data: historyItem),
          );
        }
      );
  }
}


class HistoryWidgetTile extends StatelessWidget {
  const HistoryWidgetTile({required this.data, super.key});
  final HistoryData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: HistoryItemImage(
          image: data.image, // Add default image
        ),
        title: HistoryItemText(historyData: data)
    );
  }
}

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({required this.data, super.key});
  final HistoryData data;

  Widget buildWidgetLayout() {
    return ClipRRect (
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
          color: Colors.white,
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
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {NavigationHelper.pushNavigatorNoTransition(context, HistoricoDetails(id: data.id))},
      child: buildWidgetLayout()
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (historyData.establishment != null)
            Text(
              historyData.establishment!,
              style: const TextStyle(fontWeight: FontWeight.bold), // Optional: Set a different style for the establishment
            ),

          Text(
            historyData.location,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text (
              getTimeDifference()
            )
          )
        ]
      )
    );


  }
}









