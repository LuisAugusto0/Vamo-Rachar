import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'perfil_usuario.dart';

class Participants {
  const Participants({
    required this.name,
    required this.email,
    required this.image,
  });

  final String name;
  final String email; //Usado para buscar mais dados depois
  final String image;
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
}

final List<HistoryData> fallbackList = [
  HistoryData(
    location: "Central Park, NYC",
    dateTime: DateTime(2023, 5, 20, 15, 30),
    participants: [
      const Participants(
          name: "Alice Smith",
          email: "alice@example.com",
          image: "https://example.com/images/alice.jpg"),
      const Participants(
          name: "Bob Johnson",
          email: "bob@example.com",
          image: "https://example.com/images/bob.jpg"),
    ],
    establishment: "Park Cafe",
    image: "https://picsum.photos/200",
  ),
  HistoryData(
    location: "The Louvre, Paris",
    dateTime: DateTime(2023, 6, 15, 10, 0),
    participants: [
      const Participants(
          name: "Chloe Brown",
          email: "chloe@example.com",
          image: "https://example.com/images/chloe.jpg"),
      const Participants(
          name: "David Wilson",
          email: "david@example.com",
          image: "https://example.com/images/david.jpg"),
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
          image: "https://example.com/images/emily.jpg"),
      const Participants(
          name: "Frank Martinez",
          email: "frank@example.com",
          image: "https://example.com/images/frank.jpg"),
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
          image: "https://example.com/images/grace.jpg"),
      const Participants(
          name: "Henry Taylor",
          email: "henry@example.com",
          image: "https://example.com/images/henry.jpg"),
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
          image: "https://example.com/images/isabella.jpg"),
      const Participants(
          name: "Jack White",
          email: "jack@example.com",
          image: "https://example.com/images/jack.jpg"),
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
          image: "https://example.com/images/liam.jpg"),
      const Participants(
          name: "Mia Brown",
          email: "mia@example.com",
          image: "https://example.com/images/mia.jpg"),
    ],
    establishment: "Ristorante Aroma",
    image: "https://picsum.photos/200",
  ),
];

class Historico extends StatelessWidget {
  const Historico({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: HistoricoAppbar(),
        body: HistoricoBody()
    );
  }
}

class HistoricoAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HistoricoAppbar({super.key});

  // Implement preferredSize property to provide size for the AppBar
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

      // Ajuste a altura da AppBar aqui
      title: const SearchBar(
        padding: WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        leading: Icon(Icons.search),
      ),
    );
  }
}

class HistoricoSearchBar {

}

class HistoricoBody extends StatelessWidget {
  const HistoricoBody({super.key});

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
          child: HistoryList(list: fallbackList),
        ));
  }
}

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({required this.data, super.key});

  static const String defaultImage = "assets/images/NovoRachamentoicon.png";
  final HistoryData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HistoryImage(
            image: data.image ?? "", // Add default image
          ),
          Expanded(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                data.establishment ?? data.location,
                /*style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium ?? const TextStyle()*/
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(data.dateTime),
                    /*style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall ?? const TextStyle()*/
                  ))
            ]))
          ],
        )
    );
  }
}

class HistoryImage extends StatelessWidget {
  const HistoryImage({required this.image, super.key});

  final String image;

  Widget getImage() {
    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      );
    } else {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 300,
        child: Image.asset(
          image,
          fit: BoxFit.cover,
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
          return HistoryWidget(data: historyItem);
        });
  }
}
