import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'database/database_helper.dart';
import 'database/sql_providers.dart';
import 'database/sql_tables.dart';
import 'novo_rachamento.dart';
import 'package:vamorachar/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';

class DatabaseAdder {
  static void addToDatabase(List<Participante> participantes,
      List<InstanciaItem> instanciaItems, List<Item> items) async {
    debugPrint("ADD TO DATABASE SUBMIT");
    // For now the email for logins are ignored
    DatabaseHelper dbHelper = DatabaseHelper();

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

    PurchaseSql purchaseSql = PurchaseSql(
        dateTimeInUnix: DateTime.now().millisecondsSinceEpoch,

        // NOT IMPLEMENTED
        longitude: 0,
        latitude: 0,

        // FETCH THE KEY!
        fkeyLogin: 2);

    PurchaseProvider purchaseProvider = PurchaseProvider(dbHelper);
    int purchaseId = await purchaseProvider.insert(purchaseSql);

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

    List<ContributionSql> contributions = [];
    ProductUnitProvider productUnitProvider = ProductUnitProvider(dbHelper);

    for (final instance in instanciaItems) {
      final item = instance.item;
      int? productId = itemIdMap[item];
      if (productId != null) {
        final sql = ProductUnitSql(fkeyProduct: productId);
        int unitId = await productUnitProvider.insert(sql);

        double paidPartitions = item.preco / instance.participantes.length;
        for (final contribution in instance.participantes) {
          int? userId = userIdMap[contribution];
          if (userId == null)
            throw Exception("Key ${instance.item} not found in userIdMap.");

          contributions.add(ContributionSql(
              paid: paidPartitions, fkeyProductUnit: unitId, fkeyUser: userId));
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
    return UserExpensesPage(participantes: participantes, instancias: instancias);
  }
}

class UserExpensesPage extends StatelessWidget {
  final List<InstanciaItem> instancias;
  final List<Participante> participantes;
  final NavigationHelper _navigationHelper = NavigationHelper();

  UserExpensesPage({Key? key, required this.participantes, required this.instancias});

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
                //DatabaseAdder.addToDatabase(participantes, instanciaItems, items);
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
    for(int i = 0; i < instancias.length; i++) {
      if(instancias[i].participantes.contains(participante)) {
        String temp = instancias[i].item.nome + " - " + instancias[i].quantidade.toString();
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
