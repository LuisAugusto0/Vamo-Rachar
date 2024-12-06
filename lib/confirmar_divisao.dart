import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'novo_rachamento.dart';
import 'package:vamorachar/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';

class ConfirmarDivisao extends StatelessWidget {
  final List<Participante> participantes;
  final List<InstanciaItem> instancias;

  ConfirmarDivisao(
      {Key? key, required this.participantes, required this.instancias}) {
    for (int i = 0; i < instancias.length; i++) {
      for (int j = 0; j < participantes.length; j++) {
        if (instancias[i].participantes.contains(participantes[j])) {
          participantes[j].consumidos.add(instancias[i].item);
          participantes[j].totalPago +=
              (instancias[i].item.preco * instancias[i].item.quantidade);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Gastos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserExpensesPage(participantes: participantes),
    );
  }
}

class UserExpensesPage extends StatelessWidget {
  final List<Participante> participantes;
  final NavigationHelper _navigationHelper = NavigationHelper();

  UserExpensesPage({Key? key, required this.participantes});

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
          return UserCard(participante: participante);
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              NavigationHelper.pushNavigatorNoTransition(
                  context, NovoRachamento());
            },
            child: Text("cancelar"),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final Participante participante;
  List<String> itensConsumidos = [];

  UserCard({Key? key, required this.participante}) {
    for (int i = 0; i < participante.consumidos.length; i++) {
      itensConsumidos.add(participante.consumidos[i].nome +
          " - " +
          participante.consumidos[i].quantidade.toString());
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
            CustomDropdown(items: widget.itensConsumidos, onChanged: (value) {})
          ],
        ),
      ),
    );
  }
}
