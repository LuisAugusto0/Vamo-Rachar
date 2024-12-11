import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'database/database_helper.dart';
import 'database/sql_providers.dart';
import 'database/sql_tables.dart';
import 'novo_rachamento.dart';
import 'package:vamorachar/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
//import 'tela_inicial.dart';

class DatabaseAdder {
  static void _assertParticipanteInsideInstancia(
      Map<Participante, int> userIdMap, List<InstanciaItem> instancias) {
    for (final instancia in instancias) {
      for (final participant in instancia.participantes) {
        assert(
            userIdMap.containsKey(participant), "participante nao encontrado");
      }
    }
  }

  static Future<Map<Participante, int>> _addParicipantesAsUser(
      List<Participante> participantes, DatabaseHelper dbHelper) async {
    // Each annonymous user will receive its own entity on the database with unique uid
    List<UserSql> users = participantes
        .map((participante) => UserSql(name: participante.nome))
        .toList();
    UserProvider userProvider = UserProvider(dbHelper);
    Map<Participante, int> userIdMap = {};

    for (int i = 0; i < users.length; i++) {
      int id = await userProvider.insert(users[i]);

      // Map for later associations
      userIdMap[participantes[i]] = id;
    }

    return userIdMap;
  }

  static _assertItemInsideInstancia(
      Map<Item, int> itemIdMap, List<InstanciaItem> instancias) {
    for (final instancia in instancias) {
      assert(itemIdMap.containsKey(instancia.item), "item nao encontrado");
    }
  }

  static Future<Map<Item, int>> _addItemAsProduct(
      List<Item> items, int purchaseId, DatabaseHelper dbHelper) async {
    // Add in foreign key order -> purchase -> product -> productUnit -> contribution
    List<ProductSql> products = items
        .map((item) => ProductSql(
            name: item.nome, price: item.preco, fkeyPurchase: purchaseId))
        .toList();

    ProductProvider productProvider = ProductProvider(dbHelper);
    Map<Item, int> itemIdMap = {};

    for (int i = 0; i < products.length; i++) {
      // Insert
      int id = await productProvider.insert(products[i]);

      // associate item instances to their corresponding ids
      itemIdMap[items[i]] = id;
    }

    return itemIdMap;
  }

  //Função acessória para identificar se o usuário permite ou não o acesso à localização
  static Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Serviço de localização desativado');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização negada permanentemente');
    }
  }

  static void addToDatabase(
      List<Participante> participantes,
      List<InstanciaItem> instanciaItems,
      List<Item> items,
      String? estabelecimentoNome) async {
    debugPrint("ADD TO DATABASE SUBMIT");

    // For now the email for logins are ignored
    DatabaseHelper dbHelper = DatabaseHelper();

    Map<Participante, int> userIdMap =
        await _addParicipantesAsUser(participantes, dbHelper);
    _assertParticipanteInsideInstancia(userIdMap, instanciaItems);

    double? latitude;
    double? longitude;
    try {
      Position position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }

    PurchaseSql purchaseSql = PurchaseSql(
        dateTimeInUnix: DateTime.now().millisecondsSinceEpoch,
        establishmentName: estabelecimentoNome,

        // NOT IMPLEMENTED
        longitude: longitude,
        latitude: latitude,

        // NO LONGER USED. LINKED ALL TO ADMIN DUMMY USER
        fkeyLogin: 1);

    PurchaseProvider purchaseProvider = PurchaseProvider(dbHelper);
    int purchaseId = await purchaseProvider.insert(purchaseSql);

    Map<Item, int> itemIdMap =
        await _addItemAsProduct(items, purchaseId, dbHelper);
    _assertItemInsideInstancia(itemIdMap, instanciaItems);

    List<ContributionSql> contributions = [];
    ProductUnitProvider productUnitProvider = ProductUnitProvider(dbHelper);

    for (final instance in instanciaItems) {
      final item = instance.item;
      int? productId = itemIdMap[item];
      if (productId != null) {
        for (int i = 0; i < instance.quantidade; i++) {
          final sql = ProductUnitSql(fkeyProduct: productId);
          int unitId = await productUnitProvider.insert(sql);

          double paidPartitions = item.preco / instance.participantes.length;
          for (final contribution in instance.participantes) {
            int? userId = userIdMap[contribution];
            if (userId == null) {
              throw Exception("Key ${instance.item} not found in userIdMap.");
            }

            contributions.add(ContributionSql(
                paid: paidPartitions,
                fkeyProductUnit: unitId,
                fkeyUser: userId));
          }
        }
      } else {
        // Handle the case where the key doesn't exist
        throw Exception("Key ${instance.item} not found in itemIdMap.");
      }
    }

    ContributionProvider contributionProvider = ContributionProvider(dbHelper);
    for (final contribution in contributions) {
      contributionProvider.insert(contribution);
    }
  }

  static List<Item> getUniqueItems(List<InstanciaItem> instanciaItems) {
    final Set<Item> uniqueItemsSet = {};

    for (final instancia in instanciaItems) {
      uniqueItemsSet.add(instancia.item);
    }

    return uniqueItemsSet.toList();
  }
}

class ConfirmarDivisao extends StatelessWidget {
  final List<Participante> participantes;
  final List<InstanciaItem> instancias;
  List<String> itensConsumidos = [];

  ConfirmarDivisao(
      {Key? key, required this.participantes, required this.instancias}) {
    debugPrint("Quantidade de instâncias: ${instancias.length}");

    for (int i = 0; i < instancias.length; i++) {
      for (int j = 0; j < participantes.length; j++) {
        if (instancias[i].participantes.contains(participantes[j])) {
          participantes[j].totalPago +=
              (instancias[i].precoPago * instancias[i].quantidade);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserExpensesPage(
        participantes: participantes, instancias: instancias);
  }
}

class UserExpensesPage extends StatelessWidget {
  final List<InstanciaItem> instancias;
  final List<Participante> participantes;
  final NavigationHelper _navigationHelper = NavigationHelper();

  UserExpensesPage(
      {Key? key, required this.participantes, required this.instancias});

  //Variável global para armazenar o nome do estabelecimento

  //Popup para adicionar o nome do estabelecimento antes de confirmar a divisão
  void _showDialog(BuildContext context) {
    String temp = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Antes de confirmar a divisão, precisamos que digite o nome do estabelecimento no campo abaixo:"),
          content: TextField(
            onChanged: (value) {
              temp = value;

              debugPrint("Nome do estabelecimento: ${temp} - $value");
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                DatabaseAdder.addToDatabase(participantes, instancias,
                    DatabaseAdder.getUniqueItems(instancias), temp);
                int count = 0;
                while (count < 4 && Navigator.canPop(context)) {
                  //Navigator.pop(context);
                  count++;
                }
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gastos dos Usuários'),
      ),
      body: ListView.builder(
        itemCount: participantes.length,
        itemBuilder: (context, index) {
          final participante = participantes[index];
          return UserCard(participante: participante, instancias: instancias);
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50,
              right: 15,
            ),
            child: ElevatedButton(
              onPressed: () {
                for (int i = 0; i < participantes.length; i++) {
                  participantes[i].totalPago = 0;
                }
                Navigator.pop(context);
              },
              child: Text(
                "cancelar",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50,
              right: 15,
            ),
            child: ElevatedButton(
              onPressed: () {
                DatabaseAdder.determinePosition();
                _showDialog(context);
              },
              child: Text(
                "enviar",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final Participante participante;
  final List<InstanciaItem> instancias;
  List<String> itensConsumidos = [];

  UserCard({Key? key, required this.participante, required this.instancias}) {
    for (int i = 0; i < instancias.length; i++) {
      if (instancias[i].participantes.contains(participante)) {
        String temp = instancias[i].item.nome +
            " - " +
            instancias[i].quantidade.toString();
        itensConsumidos.add(temp);
      }
    }
  }

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.participante.nome,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Gasto total: R\$ ${widget.participante.totalPago.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            CustomDropdown(
                hintText: "Itens Consumidos",
                items: widget.itensConsumidos,
                onChanged: (value) {})
          ],
        ),
      ),
    );
  }
}
